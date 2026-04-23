# Flutter 桌面端集成指南

本文面向接入 `NECallKitUI` 的客户应用，基于当前仓库桌面端实现整理，适用于 Flutter `macOS` 和 `Windows` 客户端的一对一音视频通话集成。

## 1. 适用范围

- 当前桌面端支持 `macOS` 和 `Windows`。
- 当前桌面端交付范围为 `1v1` 音频通话和视频通话。
- 当前桌面端不作为群呼交付版本。现有代码在桌面登录成功后会跳过群呼初始化。
- 当前桌面端不使用移动端的来电横幅、应用外悬浮窗、离线推送证书接入方案。
- 推荐客户接入 `含 UI` 的 `netease_callkit_ui`，不建议桌面端从 Demo 代码整体复制。

## 2. 接入前准备

- 开通云信应用，并确认应用已开通信令和音视频通话能力。
- Flutter 工程已启用桌面平台。
- `macOS` 需要本机具备 `Xcode`、`CocoaPods`。
- `Windows` 需要本机具备 `Visual Studio C++ Desktop Development` 工具链和 `CMake`。

建议先执行：

```bash
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

## 3. 依赖接入

推荐只接入 `UI` 包，`netease_callkit_ui` 会自动依赖 `netease_callkit`：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  netease_callkit_ui: ^4.5.0
```

说明：

- 客户项目不要使用本仓库示例中的 `path` 依赖写法。
- 如需显式锁定版本，建议同时锁定：

```yaml
dependencies:
  netease_callkit_ui: 4.5.0
  netease_callkit: 4.5.0
```

- `netease_callkit_ui 4.5.0` 会自动依赖 `netease_callkit 4.5.0`，常规客户项目只声明 `netease_callkit_ui` 即可。

## 4. Flutter 层最小接入

### 4.1 `MaterialApp` 必须挂载本地化和导航观察者

桌面端通话页由 `NECallKitUI.navigatorObserver` 驱动，如果未挂载，来电后 Flutter 通话页无法正常拉起。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    NECallKitUI.delegate,
  ],
  supportedLocales: const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ],
  navigatorObservers: <NavigatorObserver>[
    NECallKitUI.navigatorObserver,
  ],
  home: const HomePage(),
);
```

### 4.2 登录推荐直接使用 `NECallKitUI`

对于含 UI 集成，推荐直接调用 `NECallKitUI.instance.login(...)`。
当前实现中，登录成功后会自动完成内部 `setupEngine`，客户侧不要再重复手动调用一次 `NECallEngine.setup(...)`。

```dart
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

Future<void> loginCallKit({
  required String appKey,
  required String userId,
  required String token,
}) async {
  final result = await NECallKitUI.instance.login(
    appKey,
    userId,
    token,
    extraConfig: NEExtraConfig(
      lckConfig: NELCKConfig(
        enableLiveCommunicationKit: true,
        ringtoneName: 'avchat_ring.mp3',
      ),
    ),
  );

  if (result.code != 0) {
    throw Exception('CallKit login failed: ${result.message}');
  }
}
```

说明：

- 桌面端通常不需要接入移动端的 `APNs/VoIP` 证书配置。
- 登录成功后可按业务需要调用 `NECallKitUI.instance.setSelfInfo(...)` 同步昵称和头像。

### 4.3 发起和接听通话

```dart
Future<void> startVideoCall(String peerUserId) async {
  final result = await NECallKitUI.instance.call(
    peerUserId,
    NECallType.video,
  );
  if (result.code != 0) {
    throw Exception('start call failed: ${result.message}');
  }
}

Future<void> startAudioCall(String peerUserId) async {
  final result = await NECallKitUI.instance.call(
    peerUserId,
    NECallType.audio,
  );
  if (result.code != 0) {
    throw Exception('start call failed: ${result.message}');
  }
}
```

来电、接听、挂断、切换音视频等通话内操作由 `NECallKitUI` 通话页处理；若需要监听业务事件，可额外注册 `NECallEngineDelegate`。

## 5. 桌面端退出清理

桌面端和移动端有一个关键差异：应用退出前，必须先做引擎销毁和桌面 SDK 释放，否则容易出现退出阶段资源未释放干净的问题。

Flutter 层建议增加统一的退出清理：

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:nim_core_v2/nim_core.dart';

const MethodChannel _desktopShutdownChannel =
    MethodChannel('callkit_example/app_shutdown');

bool _desktopShutdownPrepared = false;

void registerDesktopShutdownHandler() {
  _desktopShutdownChannel.setMethodCallHandler((call) async {
    if (call.method == 'prepareForExit') {
      await prepareForDesktopExit();
    }
    return null;
  });
}

Future<void> prepareForDesktopExit() async {
  if (_desktopShutdownPrepared) {
    return;
  }
  _desktopShutdownPrepared = true;

  if (!(Platform.isMacOS || Platform.isWindows)) {
    return;
  }

  await NECallEngine.instance.destroy();
  await NimCore.instance.releaseDesktop();

  if (Platform.isMacOS) {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
```

建议在 `main()` 的 `runApp()` 之前注册这段逻辑。

说明：

- `callkit_example/app_shutdown` 只是示例 channel 名称，客户项目可以自定义。
- Flutter 层、`macOS` 宿主层、`Windows` 宿主层必须使用同一个 channel 名称。

## 6. macOS 宿主工程改造

### 6.1 权限声明

在 `macos/Runner/Info.plist` 中补充：

```xml
<key>NSCameraUsageDescription</key>
<string>应用需要访问摄像头以进行视频通话</string>
<key>NSMicrophoneUsageDescription</key>
<string>应用需要访问麦克风以进行语音通话</string>
```

在 `macos/Runner/DebugProfile.entitlements` 和 `macos/Runner/Release.entitlements` 中补充：

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

### 6.2 退出前通知 Flutter 做资源释放

建议在 `macos/Runner/AppDelegate.swift` 中拦截应用退出，把退出事件通过 `MethodChannel` 发送给 Flutter：

```swift
import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let shutdownChannelName = "callkit_example/app_shutdown"
  private var shutdownChannel: FlutterMethodChannel?
  private var terminationPreparationInProgress = false
  private var terminationPreparationCompleted = false

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if terminationPreparationCompleted {
      return .terminateNow
    }
    if terminationPreparationInProgress {
      return .terminateLater
    }

    guard let channel = desktopShutdownChannel() else {
      terminationPreparationCompleted = true
      return .terminateNow
    }

    terminationPreparationInProgress = true
    channel.invokeMethod("prepareForExit", arguments: nil) { [weak self] _ in
      DispatchQueue.main.async {
        self?.terminationPreparationInProgress = false
        self?.terminationPreparationCompleted = true
        NSApp.reply(toApplicationShouldTerminate: true)
      }
    }
    return .terminateLater
  }

  private func desktopShutdownChannel() -> FlutterMethodChannel? {
    if let shutdownChannel {
      return shutdownChannel
    }
    guard let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return nil
    }
    let channel = FlutterMethodChannel(
      name: shutdownChannelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    shutdownChannel = channel
    return channel
  }
}
```

### 6.3 构建运行 `macOS`

客户项目通常直接执行即可：

```bash
flutter pub get
flutter run -d macos
```

## 7. Windows 宿主工程改造

### 7.1 关闭窗口前通知 Flutter 做资源释放

建议在 `windows/runner/flutter_window.cpp` 中拦截 `WM_CLOSE`，先走 Flutter 清理，再真正关闭窗口：

```cpp
namespace {
constexpr char kShutdownChannelName[] = "callkit_example/app_shutdown";
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_CLOSE:
      if (exit_preparation_completed_) {
        break;
      }
      if (exit_preparation_in_progress_) {
        return 0;
      }
      PrepareForExit();
      return 0;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
```

`PrepareForExit()` 中通过 `MethodChannel` 调用 Flutter 侧 `prepareForExit`，待 Flutter 清理完成后再真正执行关闭。

### 7.2 Windows 构建说明

客户项目通常直接执行即可：

```bash
flutter pub get
flutter run -d windows
```

## 8. 可选的桌面设备管理接口

桌面端额外提供设备枚举和切换接口，适合接入“摄像头/麦克风/扬声器设置”页面：

```dart
final cameras = await NECallEngine.instance.getVideoCaptureDevices();
final currentCameraId =
    await NECallEngine.instance.getCurrentVideoCaptureDeviceId();
await NECallEngine.instance.setVideoCaptureDevice('<camera-device-id>');

final microphones = await NECallEngine.instance.getAudioRecordingDevices();
final currentMicId =
    await NECallEngine.instance.getCurrentAudioRecordingDeviceId();
await NECallEngine.instance.setAudioRecordingDevice('<microphone-device-id>');

final speakers = await NECallEngine.instance.getAudioPlaybackDevices();
final currentSpeakerId =
    await NECallEngine.instance.getCurrentAudioPlaybackDeviceId();
await NECallEngine.instance.setAudioPlaybackDevice('<speaker-device-id>');
```

## 9. 当前桌面端能力边界

- 当前桌面端主线能力为 `1v1 音视频通话`。
- 群呼相关能力在当前桌面实现中未作为交付能力启用。
- `ASR 字幕`、`虚拟背景状态回调` 等部分接口在桌面端不会回调。
- 来电 UI 依赖 `navigatorObserver` 自动拉起，若客户使用自定义路由框架，必须保证根 `Navigator` 对观察者可见。

## 10. 常见问题

### 10.1 macOS 构建失败

原因：

- 常见原因包括本机 Flutter 环境异常、Xcode/CocoaPods 环境异常，或本地构建缓存异常。

处理方式：

```bash
flutter pub get
flutter run -d macos
```

如果仍然失败，优先检查 Flutter SDK、Xcode、CocoaPods 和本机网络环境是否正常。

### 10.2 来电后 Flutter 通话页没有弹出

优先检查：

- `MaterialApp` 是否挂载了 `NECallKitUI.navigatorObserver`。
- `main()` 中是否在 `runApp()` 前完成初始化。
- 客户自定义路由是否绕过了根 `Navigator`。

### 10.3 应用退出时卡住或异常退出

优先检查：

- Flutter 层是否调用了 `NECallEngine.instance.destroy()`。
- Flutter 层是否调用了 `NimCore.instance.releaseDesktop()`。
- `macOS` 或 `Windows` 宿主层是否把窗口关闭事件转发到了 Flutter。

### 10.4 摄像头或麦克风无法使用

优先检查：

- `macOS` 的 `Info.plist` 和 `entitlements` 是否已补齐。
- 系统隐私设置中是否授予应用摄像头和麦克风权限。
- 客户应用是否在登录成功后才发起通话。

## 11. 推荐接入顺序

1. 先在一个干净的 Flutter 桌面工程中接入 `netease_callkit_ui`。
2. 挂载 `NECallKitUI.delegate` 和 `NECallKitUI.navigatorObserver`。
3. 完成 `login -> call -> hangup -> logout` 主流程打通。
4. 增加 `macOS` / `Windows` 宿主退出清理逻辑。
5. 再补充设备选择、昵称头像同步、业务页面跳转等定制能力。

## 12. 交付建议

- 客户文档中统一使用占位符，例如 `<appKey>`、`<userId>`、`<token>`、`<peerUserId>`。
- 不要把 Demo 中的测试账号、测试 token、测试域名、内部下载地址写入对外文档。
