#include "crash_monitor.h"

#include <Windows.h>
#include <DbgHelp.h>
#include <shellapi.h>

#include <cstdint>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <string>

namespace {

constexpr wchar_t kCrashMonitorFlag[] = L"--crash-monitor";
constexpr DWORD kDebugContinue = DBG_CONTINUE;
constexpr DWORD kDebugUnhandled = DBG_EXCEPTION_NOT_HANDLED;

std::wstring GetExecutablePath() {
  wchar_t path[MAX_PATH];
  const DWORD length = GetModuleFileNameW(nullptr, path, MAX_PATH);
  return std::wstring(path, length);
}

std::wstring ResolveLogDirectory() {
  wchar_t* local_app_data = nullptr;
  size_t len = 0;
  if (_wdupenv_s(&local_app_data, &len, L"LOCALAPPDATA") == 0 &&
      local_app_data != nullptr && len > 0) {
    std::wstring path(local_app_data);
    free(local_app_data);
    return path + L"\\NIM\\log\\CallKitCore";
  }

  wchar_t* user_profile = nullptr;
  if (_wdupenv_s(&user_profile, &len, L"USERPROFILE") == 0 &&
      user_profile != nullptr && len > 0) {
    std::wstring path(user_profile);
    free(user_profile);
    return path + L"\\AppData\\Local\\NIM\\log\\CallKitCore";
  }

  return L".\\logs";
}

std::wstring GetTimestamp() {
  std::time_t now = std::time(nullptr);
  std::tm local_time = {};
  localtime_s(&local_time, &now);

  wchar_t buffer[32];
  wcsftime(buffer, sizeof(buffer) / sizeof(wchar_t), L"%Y%m%d_%H%M%S",
           &local_time);
  return buffer;
}

std::wstring BuildDumpFilePath(DWORD process_id, const std::wstring& suffix) {
  const std::wstring log_directory = ResolveLogDirectory();
  std::error_code mkdir_error;
  std::filesystem::create_directories(log_directory, mkdir_error);
  return log_directory + L"\\callkit_example_crash_" + GetTimestamp() + L"_" +
         std::to_wstring(process_id) + L"_" + suffix + L".dmp";
}

std::wstring FormatExceptionCode(DWORD exception_code) {
  wchar_t buffer[16];
  swprintf_s(buffer, L"%08lx", static_cast<unsigned long>(exception_code));
  return std::wstring(L"seh_") + buffer;
}

bool ShouldAutoContinueFirstChance(DWORD exception_code) {
  return exception_code == EXCEPTION_BREAKPOINT ||
         exception_code == EXCEPTION_SINGLE_STEP ||
         exception_code == DBG_CONTROL_C;
}

bool WriteCrashDump(HANDLE process_handle,
                    DWORD process_id,
                    DWORD thread_id,
                    const EXCEPTION_DEBUG_INFO& exception_info) {
  const std::wstring dump_path =
      BuildDumpFilePath(process_id,
                        FormatExceptionCode(
                            exception_info.ExceptionRecord.ExceptionCode));
  HANDLE dump_file =
      CreateFileW(dump_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                  FILE_ATTRIBUTE_NORMAL, nullptr);
  if (dump_file == INVALID_HANDLE_VALUE) {
    return false;
  }

  HANDLE thread_handle = OpenThread(
      THREAD_GET_CONTEXT | THREAD_QUERY_INFORMATION, FALSE, thread_id);
  CONTEXT thread_context = {};
  thread_context.ContextFlags = CONTEXT_ALL;
  bool has_thread_context =
      thread_handle != nullptr && GetThreadContext(thread_handle, &thread_context);

  EXCEPTION_RECORD exception_record = exception_info.ExceptionRecord;
  EXCEPTION_POINTERS exception_pointers = {
      &exception_record, has_thread_context ? &thread_context : nullptr};
  MINIDUMP_EXCEPTION_INFORMATION dump_exception_info = {
      thread_id, has_thread_context ? &exception_pointers : nullptr, FALSE};

  const BOOL dump_written = MiniDumpWriteDump(
      process_handle, process_id, dump_file,
      static_cast<MINIDUMP_TYPE>(MiniDumpNormal | MiniDumpWithThreadInfo |
                                 MiniDumpWithUnloadedModules |
                                 MiniDumpWithProcessThreadData |
                                 MiniDumpWithHandleData),
      has_thread_context ? &dump_exception_info : nullptr, nullptr, nullptr);

  if (thread_handle != nullptr) {
    CloseHandle(thread_handle);
  }
  CloseHandle(dump_file);
  return dump_written == TRUE;
}

int RunCrashMonitor(DWORD target_pid) {
  HANDLE process_handle = OpenProcess(
      PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | SYNCHRONIZE, FALSE,
      target_pid);
  if (process_handle == nullptr) {
    return EXIT_FAILURE;
  }

  if (!DebugActiveProcess(target_pid)) {
    CloseHandle(process_handle);
    return EXIT_FAILURE;
  }

  DebugSetProcessKillOnExit(FALSE);

  bool should_exit = false;
  bool dump_attempted = false;
  while (!should_exit) {
    DEBUG_EVENT debug_event = {};
    if (!WaitForDebugEvent(&debug_event, INFINITE)) {
      break;
    }

    DWORD continue_status = kDebugContinue;
    switch (debug_event.dwDebugEventCode) {
      case EXCEPTION_DEBUG_EVENT: {
        const EXCEPTION_DEBUG_INFO& exception_info = debug_event.u.Exception;
        if (exception_info.dwFirstChance != 0) {
          continue_status = ShouldAutoContinueFirstChance(
                                exception_info.ExceptionRecord.ExceptionCode)
                                ? kDebugContinue
                                : kDebugUnhandled;
          break;
        }

        if (!dump_attempted) {
          dump_attempted = true;
          WriteCrashDump(process_handle, target_pid, debug_event.dwThreadId,
                         exception_info);
        }
        continue_status = kDebugUnhandled;
        break;
      }
      case EXIT_PROCESS_DEBUG_EVENT:
        should_exit = true;
        break;
      default:
        break;
    }

    ContinueDebugEvent(debug_event.dwProcessId, debug_event.dwThreadId,
                       continue_status);
  }

  DebugActiveProcessStop(target_pid);
  CloseHandle(process_handle);
  return EXIT_SUCCESS;
}

}  // namespace

int MaybeRunCrashMonitorMode() {
  int argc = 0;
  LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return -1;
  }

  int exit_code = -1;
  if (argc >= 3 && std::wstring(argv[1]) == kCrashMonitorFlag) {
    const std::uint32_t target_pid = wcstoul(argv[2], nullptr, 10);
    exit_code = RunCrashMonitor(static_cast<DWORD>(target_pid));
  }

  LocalFree(argv);
  return exit_code;
}

void StartCrashMonitorProcess() {
  const std::wstring executable_path = GetExecutablePath();
  const DWORD current_pid = GetCurrentProcessId();
  std::wstring command_line = L"\"" + executable_path + L"\" " +
                              kCrashMonitorFlag + L" " +
                              std::to_wstring(current_pid);

  STARTUPINFOW startup_info = {};
  startup_info.cb = sizeof(startup_info);
  startup_info.dwFlags = STARTF_USESHOWWINDOW;
  startup_info.wShowWindow = SW_HIDE;

  PROCESS_INFORMATION process_info = {};
  if (CreateProcessW(executable_path.c_str(), command_line.data(), nullptr,
                     nullptr, FALSE, CREATE_NO_WINDOW, nullptr, nullptr,
                     &startup_info, &process_info)) {
    CloseHandle(process_info.hThread);
    CloseHandle(process_info.hProcess);
  }
}
