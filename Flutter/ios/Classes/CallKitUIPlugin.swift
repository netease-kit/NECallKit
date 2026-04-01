// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import NERtcCallKit
import os.log
import UIKit

@objc public class SwiftCallKitUIPlugin: NSObject, FlutterPlugin, NEBackToFlutterWidgetDelegate {
  let tag: String = "SwiftCallKitUIPlugin"

  private var audioPlayer: AVAudioPlayer?
  private var registrar: FlutterPluginRegistrar?
  /// OSLog 日志记录器
  private static let logger = OSLog(subsystem: "com.netease.yunxin.app.party", category: "CallKitUIPlugin")

  /// 是否处于 Incoming 状态（内存存储）
  private var lckIsInIncomingState: Bool = false

  /// 当前通话状态
  private var currentCallStatus: NECallStatus = .none

  /// 应用进入前台观察者
  private var appForegroundObserver: NSObjectProtocol?

  /// 应用进入后台观察者
  private var appBackgroundObserver: NSObjectProtocol?

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    NEFLTCallUIKitLog.setupLog()
    // 临时启用 OSLog（仅用于测试）
    NEFLTCallUIKitLog.infoLog("SwiftCallKitUIPlugin", desc: "🔔 [CallKitUIPlugin] register called")

    let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
    let instance = SwiftCallKitUIPlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)

    // 设置 NEWindowManager 的 delegate
    NEWindowManager.instance.backToFlutterWidgetDelegate = instance

    // 开始监听 Live Communication Kit 状态变化
    instance.startListeningToIncomingState()

    // 开始监听通话状态变化
    instance.registerObserveCallStatus()

    // 开始监听应用进入前台
    instance.setupAppForegroundObserver()

    // 开始监听应用进入后台
    instance.setupAppBackgroundObserver()

    NEFLTCallUIKitLog.infoLog("SwiftCallKitUIPlugin", desc: "🔔 [CallKitUIPlugin] register completed")
  }

  @objc public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog("SwiftCallKitUIPlugin", desc: "CallKitUIPlugin: handle method called - \(call.method)")
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "startForegroundService":
      handleStartForegroundService(result: result)
    case "stopForegroundService":
      handleStopForegroundService(result: result)
    case "startRing":
      handleStartRing(call, result: result)
    case "stopRing":
      handleStopRing(result: result)
    case "startFloatWindow":
      handleStartFloatWindow(result: result)
    case "stopFloatWindow":
      handleStopFloatWindow(result: result)
    case "hasFloatPermission":
      handleHasFloatPermission(result: result)
    case "hasPermissions":
      handleHasPermissions(call, result: result)
    case "requestPermissions":
      handleRequestPermissions(call, result: result)
    case "enableWakeLock":
      handleEnableWakeLock(call, result: result)
    case "updateCallStateToNative":
      handleUpdateCallStateToNative(call, result: result)
    case "setupPIP":
      handleSetupPIP(result: result)
    case "disposePIP":
      handleDisposePIP(result: result)
    case "startPIP":
      handleStartPIP(result: result)
    case "stopPIP":
      handleStopPIP(result: result)
    case "setIncomingBannerEnabled":
      handleSetIncomingBannerEnabled(call, result: result)
    case "showIncomingBanner":
      handleShowIncomingBanner(result: result)
    case "cancelIncomingBanner":
      handleCancelIncomingBanner(result: result)
    default:
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: method not implemented - \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Foreground Service Methods

  private func handleStartForegroundService(result: @escaping FlutterResult) {
    result(true)
  }

  private func handleStopForegroundService(result: @escaping FlutterResult) {
    result(true)
  }

  // MARK: - Permission Methods

  private func handleHasPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let permissionNumbers = args["permission"] as? [NSNumber] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "permission parameter is required", details: nil))
      return
    }

    // 将 NSNumber 数组转换为字符串数组
    let permissions = permissionNumbers.compactMap { number -> String? in
      switch number.intValue {
      case 0:
        return "camera"
      case 1:
        return "microphone"
      case 2:
        return "bluetooth"
      default:
        return nil
      }
    }

    let hasAllPermissions = PermissionManager.shared.checkAllPermissions(permissions: permissions)
    result(hasAllPermissions)
  }

  private func handleRequestPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let permissionNumbers = args["permission"] as? [NSNumber] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "permission parameter is required", details: nil))
      return
    }

    // 将 NSNumber 数组转换为字符串数组
    let permissions = permissionNumbers.compactMap { number -> String? in
      switch number.intValue {
      case 0:
        return "camera"
      case 1:
        return "microphone"
      case 2:
        return "bluetooth"
      default:
        return nil
      }
    }

    let title = args["title"] as? String ?? ""
    let description = args["description"] as? String ?? ""
    let settingsTip = args["settingsTip"] as? String ?? ""

    PermissionManager.shared.requestPermissions(permissions: permissions, title: title, description: description, settingsTip: settingsTip) { permissionResult in
      result(permissionResult.rawValue)
    }
  }

  // MARK: - Wake Lock Methods

  private func handleEnableWakeLock(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enable = args["enable"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "enable parameter is required", details: nil))
      return
    }

    if enable {
      UIApplication.shared.isIdleTimerDisabled = true
    } else {
      UIApplication.shared.isIdleTimerDisabled = false
    }

    result(true)
  }

  // MARK: - Float Window Methods

  private func handleStartFloatWindow(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: startFloatWindow called")
    NEWindowManager.instance.showFloatWindow()
    result(true)
  }

  private func handleStopFloatWindow(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: stopFloatWindow called")
    NEWindowManager.instance.closeFloatWindow()
    result(true)
  }

  private func handleHasFloatPermission(result: @escaping FlutterResult) {
    result(true)
  }

  // MARK: - Ring Methods

  private func handleStartRing(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "filePath is required", details: nil))
      return
    }

    // 如果处于 Incoming 状态，直接返回，此时使用lck自带铃声，不需要额外播放铃声
    if lckIsInIncomingState {
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Skipping startRing because in incoming state")
      result(true)
      return
    }

    stopRing()

    let isCalled = (args["isCalled"] as? Bool) ?? (NECallState.instance.selfUser.value.callRole == NECallRole.called)
    if isCalled {
      CallingVibrator.startVibration()
    }

    // 诊断：检查文件是否存在及大小
    let fileExists = FileManager.default.fileExists(atPath: filePath)
    var fileSize = 0
    if let attrs = try? FileManager.default.attributesOfItem(atPath: filePath),
       let size = attrs[.size] as? Int {
      fileSize = size
    }
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: startRing path=\(filePath) exists=\(fileExists) size=\(fileSize)")
    guard fileExists, fileSize > 0 else {
      NEFLTCallUIKitLog.errorLog(tag, desc: "CallKitUIPlugin: ring file missing or empty, path=\(filePath)")
      result(FlutterError(code: "FILE_NOT_FOUND", message: "Ring file missing or empty", details: filePath))
      return
    }

    do {
      // 配置音频会话
      try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
      try AVAudioSession.sharedInstance().setActive(true)
      // 创建音频播放器
      let url = URL(fileURLWithPath: filePath)
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1 // 无限循环
      audioPlayer?.volume = 1.0
      audioPlayer?.play()

      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Started playing ring tone from \(filePath)")
      result(true)
    } catch {
      NEFLTCallUIKitLog.errorLog(tag, desc: "CallKitUIPlugin: Failed to start ring tone - \(error.localizedDescription)")
      result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to start ring tone", details: error.localizedDescription))
    }
  }

  private func handleStopRing(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: stopRing called")
    stopRing()
    result(true)
  }

  private func stopRing() {
    CallingVibrator.stopVirbration()

    guard audioPlayer != nil else { return }

    audioPlayer?.stop()
    audioPlayer = nil

    // 不再反激活音频会话（setActive(false)），因为 RTC 引擎在通话中依赖音频会话保持激活状态。
    // 反激活会导致 RTC 引擎丢失音频输入/输出，造成通话中听不到声音。
    // RTC 引擎会在通话结束时自行管理音频会话的生命周期。
  }

  // MARK: - PIP Methods

  /// 设置画中画 UI
  private func handleSetupPIP(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: setupPIP called")

    if #available(iOS 15.0, *) {
      NEWindowManager.instance.setupPIP { success in
        if success {
          NEFLTCallUIKitLog.infoLog(self.tag, desc: "CallKitUIPlugin: PIP setup successfully")
        } else {
          NEFLTCallUIKitLog.errorLog(self.tag, desc: "CallKitUIPlugin: PIP setup failed")
        }
        result(success)
      }
    } else {
      result(false)
    }
  }

  /// 清理画中画资源
  private func handleDisposePIP(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: disposePIP called")

    if #available(iOS 15.0, *) {
      NEWindowManager.instance.disposePIP()
    }
    result(true)
  }

  /// 启动视频渲染
  private func handleStartPIP(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: startPIP called (start video rendering)")

    if #available(iOS 15.0, *) {
      NEWindowManager.instance.startVideoRendering()
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Start video rendering")
      result(true)
    } else {
      result(false)
    }
  }

  /// 停止视频渲染
  private func handleStopPIP(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: stopPIP called (stop video rendering)")

    if #available(iOS 15.0, *) {
      NEWindowManager.instance.stopVideoRendering()
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Stop video rendering")
    }
    result(true)
  }

  // MARK: - Incoming Banner Methods

  private func handleSetIncomingBannerEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enable = args["enable"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "enable parameter is required", details: nil))
      return
    }
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: setIncomingBannerEnabled enable=\(enable)")
    NEFlutterIncomingBannerHandler.setEnabled(enable)
    result(nil)
  }

  private func handleShowIncomingBanner(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: showIncomingBanner called")
    let remoteUser = NECallState.instance.remoteUser.value
    let callType = Int(NECallState.instance.mediaType.value.rawValue)
    NEFLTCallUIKitLog.infoLog(tag, desc: "showIncomingBanner callerId=\(remoteUser.id) callType=\(callType)")

    NEIncomingCallBannerWindow.shared.show(
      callerId: remoteUser.id,
      displayName: remoteUser.nickname,
      avatarUrl: remoteUser.avatar.isEmpty ? nil : remoteUser.avatar,
      callType: callType,
      onAccept: { [weak self] in
        NEFLTCallUIKitLog.infoLog("CallKitUIPlugin", desc: "bannerAcceptTapped → notify Dart")
        self?.invokeFlutterMethod("bannerAcceptTapped", arguments: nil)
      },
      onReject: { [weak self] in
        NEFLTCallUIKitLog.infoLog("CallKitUIPlugin", desc: "bannerRejectTapped → notify Dart")
        self?.invokeFlutterMethod("bannerRejectTapped", arguments: nil)
      },
      onBodyTap: { [weak self] in
        NEFLTCallUIKitLog.infoLog("CallKitUIPlugin", desc: "bannerBodyTapped → launchCallingPageFromIncomingBanner")
        self?.invokeFlutterMethod("launchCallingPageFromIncomingBanner", arguments: nil)
      }
    )
    result(nil)
  }

  private func handleCancelIncomingBanner(result: @escaping FlutterResult) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: cancelIncomingBanner called")
    NEFlutterIncomingBannerHandler.dismissIncomingBanner()
    NEIncomingCallBannerWindow.shared.dismiss()
    result(nil)
  }

  private func invokeFlutterMethod(_ method: String, arguments: Any?) {
    guard let registrar = registrar else { return }
    let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
    channel.invokeMethod(method, arguments: arguments)
  }

  // MARK: - Call State Methods

  private func handleUpdateCallStateToNative(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    parseAndUpdateCallState(args)
    result(true)
  }

  private func parseAndUpdateCallState(_ args: [String: Any]) {
    // 解析 selfUser
    if let selfUserData = args["selfUser"] as? [String: Any] {
      let selfUser = NECallUser()
      selfUser.id = selfUserData["id"] as? String ?? ""
      selfUser.avatar = selfUserData["avatar"] as? String ?? ""
      selfUser.nickname = selfUserData["nickname"] as? String ?? ""
      selfUser.callRole = NECallRole(rawValue: selfUserData["callRole"] as? Int ?? 0) ?? .none
      selfUser.callStatus = NECallStatus(rawValue: selfUserData["callStatus"] as? Int ?? 0) ?? .none
      selfUser.audioAvailable = selfUserData["audioAvailable"] as? Bool ?? false
      selfUser.videoAvailable = selfUserData["videoAvailable"] as? Bool ?? false
      selfUser.playOutVolume = selfUserData["playOutVolume"] as? Int ?? 0
      selfUser.viewID = selfUserData["viewID"] as? Int ?? 0

      NECallState.instance.selfUser.value = selfUser
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Self user updated - id: \(selfUser.id), status: \(String(describing: selfUser.callStatus)) callRole: \(String(describing: selfUser.callRole))")
    }

    // 解析 remoteUserList，如果存在且不为空，取第一个元素赋值给 remoteUser
    if let remoteUserList = args["remoteUserList"] as? [[String: Any]], !remoteUserList.isEmpty {
      let firstRemoteUserData = remoteUserList[0]
      let remoteUser = NECallUser()
      remoteUser.id = firstRemoteUserData["id"] as? String ?? ""
      remoteUser.avatar = firstRemoteUserData["avatar"] as? String ?? ""
      remoteUser.nickname = firstRemoteUserData["nickname"] as? String ?? ""
      remoteUser.callRole = NECallRole(rawValue: firstRemoteUserData["callRole"] as? Int ?? 0) ?? .none
      remoteUser.callStatus = NECallStatus(rawValue: firstRemoteUserData["callStatus"] as? Int ?? 0) ?? .none
      remoteUser.audioAvailable = firstRemoteUserData["audioAvailable"] as? Bool ?? false
      remoteUser.videoAvailable = firstRemoteUserData["videoAvailable"] as? Bool ?? false
      remoteUser.playOutVolume = firstRemoteUserData["playOutVolume"] as? Int ?? 0
      remoteUser.viewID = firstRemoteUserData["viewID"] as? Int ?? 0

      NECallState.instance.remoteUser.value = remoteUser
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Remote user updated - id: \(remoteUser.id), status: \(String(describing: remoteUser.callStatus)), videoAvailable: \(String(describing: remoteUser.videoAvailable))")
    }

    if let mediaTypeIndex = args["mediaType"] as? Int {
      let mediaType = NECallType(rawValue: UInt(mediaTypeIndex))
      NECallState.instance.mediaType.value = mediaType
    }

    if let startTimeValue = args["startTime"] as? Int {
      NECallState.instance.startTime = startTimeValue
    }

    if let isCameraOpenValue = args["isCameraOpen"] as? Bool {
      NECallState.instance.isCameraOpen.value = isCameraOpenValue
    }

    if let isMicrophoneMuteValue = args["isMicrophoneMute"] as? Bool {
      NECallState.instance.isMicrophoneMute.value = isMicrophoneMuteValue
    }

    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Call state updated - mediaType: \(String(describing: NECallState.instance.mediaType.value)), isCameraOpen: \(String(NECallState.instance.isCameraOpen.value)), isMicrophoneMute: \(String(NECallState.instance.isMicrophoneMute.value))")
  }

  @objc public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    stopRing() // 停止铃声播放
    stopListeningToIncomingState() // 停止监听状态变化
    unregisterObserveCallStatus() // 取消注册通话状态监听
    removeAppForegroundObserver() // 移除应用前台观察者
    removeAppBackgroundObserver() // 移除应用后台观察者
  }

  // MARK: - Live Communication Kit State Monitoring

  /// 开始监听 Live Communication Kit 的 Incoming 状态变化
  private func startListeningToIncomingState() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleIncomingStateChanged(_:)),
      name: NSNotification.Name("NELiveCommunicationKitIncomingStateChanged"),
      object: nil
    )
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Started listening to Live Communication Kit state changes")
  }

  /// 停止监听 Live Communication Kit 的 Incoming 状态变化
  private func stopListeningToIncomingState() {
    NotificationCenter.default.removeObserver(self)
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Stopped listening to Live Communication Kit state changes")
  }

  /// 处理 Incoming 状态变化
  @objc private func handleIncomingStateChanged(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let lckIsInIncomingState = userInfo["lckIsInIncomingState"] as? Bool else {
      return
    }
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Live Communication Kit incoming state changed to \(String(lckIsInIncomingState))")

    // 更新本地状态
    self.lckIsInIncomingState = lckIsInIncomingState

    // 根据状态执行相应操作
    if lckIsInIncomingState {
      handleLckEnterIncomingState()
    } else {
      handleLckExitIncomingState()
    }
  }

  /// 处理进入 LCK Incoming 状态
  private func handleLckEnterIncomingState() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Entered Live Communication Kit incoming state")
    // 停止铃声播放
    stopRing()
  }

  /// 处理退出 LCK Incoming 状态
  private func handleLckExitIncomingState() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Exited Live Communication Kit incoming state")
  }

  // MARK: - Call Status Monitoring

  /// 注册监听通话状态变化
  private func registerObserveCallStatus() {
    // 监听 selfUser 的变化
    NECallState.instance.selfUser.addObserver(self, options: [.new]) { [weak self] newUser, _ in
      guard let self = self else { return }

      // 检查通话状态变化
      if self.currentCallStatus == newUser.callStatus { return }
      let oldStatus = self.currentCallStatus
      self.currentCallStatus = newUser.callStatus
      NEFLTCallUIKitLog.infoLog(self.tag, desc: "CallKitUIPlugin: Call status changed from \(String(describing: oldStatus)) to \(String(describing: newUser.callStatus))")

      // 根据状态变化执行相应操作
      self.handleCallStatusChanged(from: oldStatus, to: newUser.callStatus)
    }
  }

  /// 取消注册通话状态监听
  private func unregisterObserveCallStatus() {
    NECallState.instance.selfUser.removeObserver(self)
  }

  /// 处理通话状态变化
  private func handleCallStatusChanged(from oldStatus: NECallStatus, to newStatus: NECallStatus) {
    // 只要不是 waiting 状态，就设置 lckIsInIncomingState 为 false
    if newStatus != .waiting {
      NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Live Communication Kit incoming state changed to false")
      lckIsInIncomingState = false
    }
  }

  // MARK: - App Foreground Monitoring

  /// 设置应用进入前台观察者
  private func setupAppForegroundObserver() {
    appForegroundObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.handleAppWillEnterForeground()
    }
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Setup app foreground observer")
  }

  /// 移除应用前台观察者
  private func removeAppForegroundObserver() {
    if let observer = appForegroundObserver {
      NotificationCenter.default.removeObserver(observer)
      appForegroundObserver = nil
    }
  }

  /// 处理应用即将进入前台
  private func handleAppWillEnterForeground() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: App will enter foreground, notifying Flutter")

    // 调用 Flutter 端的 appEnterForeground 方法
    if let registrar = registrar {
      let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
      channel.invokeMethod("appEnterForeground", arguments: nil)
    }
  }

  /// 设置应用进入后台观察者
  private func setupAppBackgroundObserver() {
    appBackgroundObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didEnterBackgroundNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.handleAppDidEnterBackground()
    }
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: Setup app background observer")
  }

  /// 移除应用后台观察者
  private func removeAppBackgroundObserver() {
    if let observer = appBackgroundObserver {
      NotificationCenter.default.removeObserver(observer)
      appBackgroundObserver = nil
    }
  }

  /// 处理应用进入后台
  private func handleAppDidEnterBackground() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: App did enter background, notifying Flutter")

    // 调用 Flutter 端的 appEnterBackground 方法
    if let registrar = registrar {
      let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
      channel.invokeMethod("appEnterBackground", arguments: nil)
    }
  }
}

extension SwiftCallKitUIPlugin {
  func backCallingPageFromFloatWindow() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "CallKitUIPlugin: backCallingPageFromFloatWindow called")
    // 调用 Flutter 端的 backCallingPageFromFloatWindow 方法
    if let registrar = registrar {
      let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
      channel.invokeMethod("backCallingPageFromFloatWindow", arguments: nil)
    }
  }
}
