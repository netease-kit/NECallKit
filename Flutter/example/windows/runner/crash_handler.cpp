#include "crash_handler.h"

#include <Windows.h>
#include <DbgHelp.h>

#include <csignal>
#include <cstdlib>
#include <ctime>
#include <exception>
#include <filesystem>
#include <string>

namespace {

LONG WINAPI UnhandledExceptionHandler(EXCEPTION_POINTERS* exception_pointers);
void TerminateHandler();
void SignalHandler(int signal_number);
bool WriteMiniDump(EXCEPTION_POINTERS* exception_pointers,
                   const wchar_t* suffix);
std::wstring ResolveLogDirectory();
std::wstring BuildDumpFilePath(const std::wstring& log_directory,
                               const wchar_t* suffix);
std::wstring GetTimestamp();

LONG WINAPI UnhandledExceptionHandler(EXCEPTION_POINTERS* exception_pointers) {
  WriteMiniDump(exception_pointers, L"seh");
  return EXCEPTION_EXECUTE_HANDLER;
}

void TerminateHandler() {
  WriteMiniDump(nullptr, L"terminate");
  abort();
}

void SignalHandler(int signal_number) {
  switch (signal_number) {
    case SIGABRT:
      WriteMiniDump(nullptr, L"sigabrt");
      break;
    case SIGSEGV:
      WriteMiniDump(nullptr, L"sigsegv");
      break;
    case SIGILL:
      WriteMiniDump(nullptr, L"sigill");
      break;
    case SIGFPE:
      WriteMiniDump(nullptr, L"sigfpe");
      break;
    default:
      WriteMiniDump(nullptr, L"signal");
      break;
  }
  std::signal(signal_number, SIG_DFL);
  std::raise(signal_number);
}

bool WriteMiniDump(EXCEPTION_POINTERS* exception_pointers,
                   const wchar_t* suffix) {
  static LONG handled = 0;
  if (InterlockedCompareExchange(&handled, 1, 0) != 0) {
    return false;
  }

  const std::wstring log_directory = ResolveLogDirectory();
  std::error_code mkdir_error;
  std::filesystem::create_directories(log_directory, mkdir_error);

  const std::wstring dump_path = BuildDumpFilePath(log_directory, suffix);
  HANDLE dump_file =
      CreateFileW(dump_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                  FILE_ATTRIBUTE_NORMAL, nullptr);
  if (dump_file == INVALID_HANDLE_VALUE) {
    return false;
  }

  MINIDUMP_EXCEPTION_INFORMATION exception_info;
  exception_info.ThreadId = GetCurrentThreadId();
  exception_info.ExceptionPointers = exception_pointers;
  exception_info.ClientPointers = FALSE;

  const BOOL dump_written = MiniDumpWriteDump(
      GetCurrentProcess(), GetCurrentProcessId(), dump_file,
      static_cast<MINIDUMP_TYPE>(MiniDumpNormal | MiniDumpWithThreadInfo |
                                 MiniDumpWithUnloadedModules),
      exception_pointers != nullptr ? &exception_info : nullptr, nullptr,
      nullptr);

  CloseHandle(dump_file);
  return dump_written == TRUE;
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

std::wstring BuildDumpFilePath(const std::wstring& log_directory,
                               const wchar_t* suffix) {
  return log_directory + L"\\callkit_example_crash_" + GetTimestamp() + L"_" +
         std::to_wstring(GetCurrentProcessId()) + L"_" + suffix + L".dmp";
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

}  // namespace

void InstallCrashHandler() {
  SetUnhandledExceptionFilter(UnhandledExceptionHandler);
  std::set_terminate(TerminateHandler);
  std::signal(SIGABRT, SignalHandler);
  std::signal(SIGSEGV, SignalHandler);
  std::signal(SIGILL, SignalHandler);
  std::signal(SIGFPE, SignalHandler);
}
