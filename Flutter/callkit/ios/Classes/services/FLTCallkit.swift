// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import NERtcCallKit
import NIMSDK
import UIKit

let frameworkFlutter = "Flutter"

class FLTCallkit: NSObject, FLTCallKitApi, NECallEngineDelegate, NERecordProvider, NECallEngineRtcDelegateEx, NERtcEngineDelegateEx, FLTLiveCommunicationKitEventDelegate {
  private var _listener: FLTCallKitEventSink?

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - 接口实现

  func setupConfig(_ config: FLTSetupConfig, completion: @escaping (FLTSimpleResponse?, FlutterError?) -> Void) {
    let context = NESetupConfig(appkey: config.appKey)
    let logSetting = NERtcLogSetting()
    logSetting.logLevel = .info
    let rtcInfo = NERtcEngineContext()
    rtcInfo.logSetting = logSetting
    context.rtcInfo = rtcInfo
    // flutter
    context.framework = frameworkFlutter

    // 转换 FLTCallInitRtcMode 到 NECallInitRtcMode
    switch config.initRtcMode {
    case .global:
      context.initRtcMode = .GlobalInitRtc
    case .inNeed:
      context.initRtcMode = .InitRtcInNeed
    case .inNeedDelayToAccept:
      context.initRtcMode = .InitRtcInNeedDelayToAccept
    default:
      context.initRtcMode = .GlobalInitRtc
    }

    // 处理 Live Communication Kit 配置
    if let lckConfig = config.lckConfig {
      // 初始化 Live Communication Kit
      let lckManager = FLTLiveCommunicationKitManager.shared
      let lckConfigObj = FLTLiveCommunicationKit(
        enableLiveCommunicationKit: lckConfig.enableLiveCommunicationKit.boolValue,
        ringtoneName: lckConfig.ringtoneName
      )
      lckManager.initialize(with: lckConfigObj)
      lckManager.eventDelegate = self
    } else {
      // 使用默认配置初始化 Live Communication Kit（默认关闭）
      let lckManager = FLTLiveCommunicationKitManager.shared
      let defaultConfig = FLTLiveCommunicationKit(
        enableLiveCommunicationKit: false,
        ringtoneName: nil
      )
      lckManager.initialize(with: defaultConfig)
      lckManager.eventDelegate = nil
    }

    NECallEngine.sharedInstance().engineDelegate = self
    NECallEngine.sharedInstance().setup(context)

    NECallEngine.sharedInstance().removeCall(self)
    NECallEngine.sharedInstance().addCall(self)

    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "success", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func getVersionWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    NECallEngine.getVersion()
  }

  func getUserWithRtcUidUid(_ uid: NSNumber, completion: @escaping @Sendable (FLTUserInfo?, FlutterError?) -> Void) {
    let user = NECallEngine.sharedInstance().getUserWithRtcUid(UInt64(uid))
    if let userInfo = user {
      completion(FLTUserInfo.make(withAccId: userInfo.accId, uid: NSNumber(value: userInfo.uid)), nil)
    } else {
      completion(nil, nil)
    }
  }

  func callParam(_ param: FLTCallParam, completion: @escaping @Sendable (FLTCallResponse?, FlutterError?) -> Void) {
    let callParam = NECallParam()
    callParam.accId = param.accId
    callParam.extraInfo = param.extraInfo
    callParam.rtcChannelName = param.rtcChannelName
    callParam.globalExtraCopy = param.globalExtraCopy
    // 根据 callType 设置通话类型
    callParam.callType = param.callType == .video ? .video : .audio

    // 处理 pushConfig 参数
    if let pushConfig = param.pushConfig {
      // 如果 NECallParam 有 pushConfig 属性，则设置它
      // 注意：这里需要根据实际的 NECallParam 定义来调整
      // 如果 NECallParam 没有 pushConfig 属性，可能需要通过其他方式传递
      print("CallKit: pushConfig received - needPush: \(pushConfig.needPush), needBadge: \(pushConfig.needBadge), title: \(pushConfig.pushTitle ?? "nil"), content: \(pushConfig.pushContent ?? "nil"), payload: \(pushConfig.pushPayload ?? "nil")")

      // 如果 NECallParam 有 pushConfig 属性，可以这样设置：
      callParam.pushConfig = NECallPushConfig()
      if let pushTitle = pushConfig.pushTitle {
        callParam.pushConfig?.pushTitle = pushTitle
      }
      if let pushContent = pushConfig.pushContent {
        callParam.pushConfig?.pushContent = pushContent
      }
      callParam.pushConfig?.needBadge = pushConfig.needBadge.boolValue
      callParam.pushConfig?.needPush = pushConfig.needPush.boolValue
      // 将 String 转换为 NSMutableDictionary
      if let pushPayloadString = pushConfig.pushPayload {
        // 尝试将 JSON 字符串转换为字典
        if let data = pushPayloadString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          callParam.pushConfig?.pushPayload = NSMutableDictionary(dictionary: jsonObject)
        } else {
          // 如果转换失败，创建一个包含原始字符串的字典
          callParam.pushConfig?.pushPayload = NSMutableDictionary(object: pushPayloadString, forKey: "payload" as NSString)
        }
      }
    }

    NECallEngine.sharedInstance().call(callParam) { error, callInfo in
      if let nsError = error as? NSError {
        let response = FLTCallResponse.make(withCode: NSNumber(value: nsError.code), msg: nsError.localizedDescription, callInfo: nil)
        completion(response, nil)
      } else {
        // 转换 NECallInfo 到 FLTCallInfo
        let fltCallInfo = self._convertCallInfo(callInfo)
        let response = FLTCallResponse.make(withCode: NSNumber(value: 0), msg: "Call successful", callInfo: fltCallInfo)
        completion(response, nil)
      }
    }
  }

  func accept(completion: @escaping @Sendable (FLTCallResponse?, FlutterError?) -> Void) {
    NECallEngine.sharedInstance().accept { error, callInfo in
      if let nsError = error as? NSError {
        let response = FLTCallResponse.make(withCode: NSNumber(value: nsError.code), msg: nsError.localizedDescription, callInfo: nil)
        completion(response, nil)
      } else {
        // 转换 NECallInfo 到 FLTCallInfo
        let fltCallInfo = self._convertCallInfo(callInfo)
        let response = FLTCallResponse.make(withCode: NSNumber(value: 0), msg: "Accept successful", callInfo: fltCallInfo)
        completion(response, nil)
      }
    }
  }

  func hangupParam(_ param: FLTHangupParam, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let hangupParam = NEHangupParam()
    hangupParam.channelId = param.channelId ?? ""
    hangupParam.extraString = param.extraString

    NECallEngine.sharedInstance().hangup(hangupParam) { error in
      if let nsError = error as? NSError {
        let response = FLTSimpleResponse.make(withCode: NSNumber(value: nsError.code), msg: nsError.localizedDescription, data1: nil, data2: nil, data3: nil)
        completion(response, nil)
      } else {
        let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Hangup successful", data1: nil, data2: nil, data3: nil)
        completion(response, nil)
      }
    }
  }

  func switchCallTypeParam(_ param: FLTSwitchParam, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let switchParam = NESwitchParam()
    // 根据 callType 设置通话类型
    switchParam.callType = param.callType == .video ? .video : .audio
    // 根据 state 设置切换状态
    switch param.state {
    case .invite:
      switchParam.state = .invite
    case .agree:
      switchParam.state = .agree
    case .reject:
      switchParam.state = .reject
    default:
      switchParam.state = .invite
    }

    NECallEngine.sharedInstance().switchCallType(switchParam) { error in
      if let nsError = error as? NSError {
        let response = FLTSimpleResponse.make(withCode: NSNumber(value: nsError.code), msg: nsError.localizedDescription, data1: nil, data2: nil, data3: nil)
        completion(response, nil)
      } else {
        let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Switch call type successful", data1: nil, data2: nil, data3: nil)
        completion(response, nil)
      }
    }
  }

  func setTimeoutTime(_ time: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    NECallEngine.sharedInstance().setTimeout(Int32(time.intValue))
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Set timeout successful", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func setupLocalViewParam(_ param: FLTViewParam, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    // 根据 viewId 获取对应的 UIView
    var targetView: UIView?

    if let viewId = param.viewId {
      // 通过 viewId 查找对应的 UIView
      targetView = _findViewByViewId(Int(viewId))
      print("setupLocalViewParam: viewId=\(viewId), found view=\(targetView != nil)")
    }

    let result = NECallEngine.sharedInstance().setupLocalView(targetView)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: result), msg: result == 0 ? "Setup local view successful" : "Setup local view failed", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func setupRemoteViewParam(_ param: FLTViewParam, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    // 根据 viewId 获取对应的 UIView
    var targetView: UIView?

    if let viewId = param.viewId {
      // 通过 viewId 查找对应的 UIView
      targetView = _findViewByViewId(Int(viewId))
      print("setupRemoteViewParam: viewId=\(viewId), found view=\(targetView != nil)")
    }

    let result = NECallEngine.sharedInstance().setupRemoteView(targetView)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: result), msg: result == 0 ? "Setup remote view successful" : "Setup remote view failed", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  /// 根据 viewId 查找对应的 UIView
  private func _findViewByViewId(_ viewId: Int) -> UIView? {
    // 使用视图管理器查找视图
    let view = FLTCallKitViewManager.shared.findView(withId: viewId)
    print("_findViewByViewId: viewId=\(viewId), found=\(view != nil)")
    return view
  }

  func enableLocalVideoEnable(_ enable: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let result = NECallEngine.sharedInstance().enableLocalVideo(enable.boolValue)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: result), msg: result == 0 ? "Enable local video successful" : "Enable local video failed", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func muteLocalVideoMuted(_ muted: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let result = NECallEngine.sharedInstance().muteLocalVideo(muted.boolValue)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: result), msg: result == 0 ? "Mute local video successful" : "Mute local video failed", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func muteLocalAudioMuted(_ muted: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let result = NECallEngine.sharedInstance().muteLocalAudio(muted.boolValue)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: result), msg: result == 0 ? "Mute local audio successful" : "Mute local audio failed", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func switchCamera(completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    NECallEngine.sharedInstance().switchCamera()
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Switch camera successful", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func isSpeakerphoneOn(completion: @escaping @Sendable (NSNumber?, FlutterError?) -> Void) {
    let isSpeakerphoneOn = NECallEngine.sharedInstance().isSpeakerphoneOn()
    completion(NSNumber(value: isSpeakerphoneOn), nil)
  }

  func setSpeakerphoneOnEnable(_ enable: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    NECallEngine.sharedInstance().setSpeakerphoneOn(enable.boolValue)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Set speakerphone on successful", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func setCallConfigConfig(_ config: FLTCallConfig, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let callConfig = NECallConfig()
    // 根据 enableVideo 设置切换视频确认
    callConfig.enableSwitchVideoConfirm = config.enableSwitchVideoConfirm.boolValue
    // 根据 enableAudio 设置切换音频确认
    callConfig.enableSwitchAudioConfirm = config.enableSwitchAudioConfirm.boolValue
    // 默认支持离线
    callConfig.enableOffline = config.enableOffline.boolValue

    NECallEngine.sharedInstance().setCallConfig(callConfig)
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Set call config successful", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  func getCallInfo(completion: @escaping @Sendable (FLTCallInfo?, FlutterError?) -> Void) {
    let callInfo = NECallEngine.sharedInstance().getCallInfo()
    let fltCallInfo = _convertCallInfo(callInfo)
    completion(fltCallInfo, nil)
  }

  func getCallConfig(completion: @escaping @Sendable (FLTCallConfig?, FlutterError?) -> Void) {
    let callConfig = NECallEngine.sharedInstance().getCallConfig()
    let response = FLTCallConfig.make(withEnableOffline: NSNumber(value: callConfig.enableOffline), enableSwitchVideoConfirm: NSNumber(value: callConfig.enableSwitchVideoConfirm), enableSwitchAudioConfirm: NSNumber(value: callConfig.enableSwitchAudioConfirm))
    completion(response, nil)
  }

  func destroy(completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    NECallEngine.sharedInstance().destroy()
    let response = FLTSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Destroy successful", data1: nil, data2: nil, data3: nil)
    completion(response, nil)
  }

  // MARK: - ASR Caption 方法实现

  func start(_ config: FLTNERtcASRCaptionConfig, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    // 创建 NERtcASRCaptionConfig
    let nertcConfig = NERtcASRCaptionConfig()

    // 设置源语言
    if let srcLanguage = config.srcLanguage {
      nertcConfig.srcLanguage = srcLanguage
    }

    // 设置多个源语言
    if let srcLanguages = config.srcLanguages {
      nertcConfig.srcLanguages = srcLanguages
    }

    // 设置目标语言（已废弃，但保留兼容性）
    if let dstLanguage = config.dstLanguage {
      nertcConfig.dstLanguage = dstLanguage
    }

    // 设置多个目标语言
    if let dstLanguages = config.dstLanguages {
      nertcConfig.dstLanguages = dstLanguages
    }

    // 设置是否需要翻译相同语言
    if let needTranslateSameLanguage = config.needTranslateSameLanguage {
      nertcConfig.needTranslateSameLanguage = needTranslateSameLanguage.boolValue
    }

    // 调用 startASRCaption
    let ret = NECallEngine.sharedInstance().startASRCaption(nertcConfig)
    let response = FLTSimpleResponse.make(
      withCode: ret as NSNumber,
      msg: ret == 0 ? "Success" : "Failed",
      data1: nil,
      data2: nil,
      data3: nil
    )
    completion(response, nil)
  }

  func stopASRCaption(completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    let ret = NECallEngine.sharedInstance().stopASRCaption()
    let response = FLTSimpleResponse.make(
      withCode: ret as NSNumber,
      msg: ret == 0 ? "Success" : "Failed",
      data1: nil,
      data2: nil,
      data3: nil
    )
    completion(response, nil)
  }

  func setCallRecordProviderEnable(_ enable: NSNumber, completion: @escaping @Sendable (FLTSimpleResponse?, FlutterError?) -> Void) {
    if enable.boolValue {
      // 设置 FLTCallkit 自己作为话单提供者
      // 这样当需要发送话单时，NECallEngine 会调用 FLTCallkit.onRecordSend
      // 然后通过 _listener?.onRecordSend 传递到 Flutter
      NECallEngine.sharedInstance().setCall(self)
      print("CallKit: setCallRecordProvider enabled, FLTCallkit will handle record sending")
    } else {
      // 清除话单提供者，恢复默认流程
      NECallEngine.sharedInstance().setCall(nil)
      print("CallKit: setCallRecordProvider disabled, using default record flow")
    }
    let response = FLTSimpleResponse.make(
      withCode: NSNumber(value: 0),
      msg: "Set call record provider successful",
      data1: nil,
      data2: nil,
      data3: nil
    )
    completion(response, nil)
  }

  // MARK: - 转换辅助方法

  /// 转换 NECallInfo 到 FLTCallInfo
  private func _convertCallInfo(_ callInfo: NECallInfo?) -> FLTCallInfo? {
    guard let callInfo = callInfo else {
      return nil
    }

    // 创建主叫方信息
    let callerInfo = FLTUserInfo.make(
      withAccId: callInfo.callerInfo.accId,
      uid: NSNumber(value: callInfo.callerInfo.uid)
    )

    // 创建被叫方信息
    let calleeInfo = FLTUserInfo.make(
      withAccId: callInfo.calleeInfo.accId,
      uid: NSNumber(value: callInfo.calleeInfo.uid)
    )

    // 创建信令信息
    let signalInfo = FLTSignalInfo.make(
      withChannelId: callInfo.signalInfo.channelId,
      requestId: callInfo.signalInfo.requestId,
      channelName: callInfo.signalInfo.channelName,
      extraInfo: callInfo.signalInfo.extraInfo,
      globalExtraCopy: callInfo.signalInfo.globalExtraCopy
    )

    // 创建RTC信息
    let rtcInfo = FLTRtcInfo.make(
      withChannelName: callInfo.rtcInfo.channelName,
      token: callInfo.rtcInfo.token,
      uid: NSNumber(value: callInfo.rtcInfo.channelId),
      cid: NSNumber(value: callInfo.rtcInfo.cid)
    )

    // 转换通话类型枚举
    let callType: FLTCallType = callInfo.callType == .video ? .video : .audio

    // 转换通话状态枚举
    let callStatus: FLTCallEngineStatus
    switch callInfo.callStatus {
    case .statusIdle:
      callStatus = .idle
    case .statusCalling:
      callStatus = .calling
    case .statusCalled:
      callStatus = .called
    case .statusInCall:
      callStatus = .inCall
    @unknown default:
      callStatus = .idle
    }

    // 创建并返回 FLTCallInfo
    return FLTCallInfo.make(
      withCallId: callInfo.callId,
      currentAccId: callInfo.currentAccId,
      callerInfo: callerInfo,
      calleeInfo: calleeInfo,
      callType: callType,
      signalInfo: signalInfo,
      rtcInfo: rtcInfo,
      call: callStatus
    )
  }

  // MARK: - NECallEngineDelegate 回调实现

  func onReceiveInvited(_ info: NEInviteInfo) {
    // 创建 Flutter 回调参数
    let inviteInfo = FLTInviteInfo.make(
      withCallerAccId: info.callerAccId,
      callType: info.callType == .video ? .video : .audio,
      extraInfo: info.extraInfo,
      channelId: info.channelId
    )

    // 直接调用 Flutter 回调
    _listener?.onReceiveInvitedInfo(inviteInfo) { error in
      if let error = error {
        print("onReceiveInvited callback error: \(error)")
      }
    }
    print("onReceiveInvited: callerAccId=\(info.callerAccId)")
  }

  func onCallEnd(_ info: NECallEndInfo) {
    // 转换 reasonCode 为枚举
    let reasonCode: FLTCallTerminalCode
    switch info.reasonCode {
    case .TerminalCodeNormal:
      reasonCode = .normal
    case .TerminalCodeTokenError:
      reasonCode = .tokenError
    case .TerminalCodeTimeOut:
      reasonCode = .timeOut
    case .TerminalCodeBusy:
      reasonCode = .busy
    case .TerminalCodeRtcInitError:
      reasonCode = .rtcInitError
    case .TerminalCodeJoinRtcError:
      reasonCode = .joinRtcError
    case .TerminalCodeCancelErrorParam:
      reasonCode = .cancelErrorParam
    case .TerminalCodeCallFailed:
      reasonCode = .callFailed
    case .TerminalCodeKicked:
      reasonCode = .kicked
    case .TerminalCodeEmptyUid:
      reasonCode = .emptyUid
    case .TerminalRtcDisconnected:
      reasonCode = .rtcDisconnected
    case .TerminalCallerCancel:
      reasonCode = .callerCancel
    case .TerminalCalleeCancel:
      reasonCode = .calleeCancel
    case .TerminalCalleeReject:
      reasonCode = .calleeReject
    case .TerminalCallerRejcted:
      reasonCode = .callerRejected
    case .TerminalHuangUp:
      reasonCode = .hangUp
    case .TerminalBeHuangUp:
      reasonCode = .beHangUp
    case .TerminalOtherRejected:
      reasonCode = .otherRejected
    case .TerminalOtherAccepted:
      reasonCode = .otherAccepted
    case .TerminalUserRtcDisconnected:
      reasonCode = .userRtcDisconnected
    case .TerminalUserRtcLeave:
      reasonCode = .userRtcLeave
    case .TerminalAcceptFail:
      reasonCode = .acceptFail
    default:
      reasonCode = .normal
    }

    // 创建 Flutter 回调参数
    let endInfo = FLTCallEndInfo.make(
      withReasonCode: reasonCode,
      extraString: info.extraString,
      message: info.message
    )

    // 直接调用 Flutter 回调
    _listener?.onCallEndInfo(endInfo) { error in
      if let error = error {
        print("onCallEnd callback error: \(error)")
      }
    }
    print("onCallEnd: reasonCode=\(info.reasonCode.rawValue)")
  }

  func onCallConnected(_ info: NECallInfo) {
    // 使用统一的转换方法
    let callInfo = _convertCallInfo(info)

    guard let callInfo = callInfo else {
      return
    }

    // 默认开启本地音频（参考群呼逻辑）
    NERtcEngine.shared().enableLocalAudio(true)

    // 直接调用 Flutter 回调
    _listener?.onCallConnectedInfo(callInfo) { error in
      if let error = error {
        print("onCallConnected callback error: \(error)")
      }
    }
    print("onCallConnected: callId=\(callInfo.callId)")
  }
  func onCallTypeChange(_ info: NECallTypeChangeInfo) {
    // 创建 Flutter 回调参数
    let changeInfo = FLTCallTypeChangeInfo.make(
      with: info.callType == .video ? .video : .audio,
      state: info.state == .invite ? .invite : (info.state == .agree ? .agree : .reject)
    )

    // 直接调用 Flutter 回调
    _listener?.onCallTypeChangeInfo(changeInfo) { error in
      if let error = error {
        print("onCallTypeChange callback error: \(error)")
      }
    }
    print("onCallTypeChange: callType=\(info.callType.rawValue), state=\(info.state.rawValue)")
  }

  func onLCKAccept(code: Int, msg: String?, callInfo: NECallInfo?) {
    let response = FLTCallResponse.make(
      withCode: NSNumber(value: code),
      msg: msg,
      callInfo: _convertCallInfo(callInfo)
    )
    _listener?.onLCKAccept(response) { error in
      if let error = error {
        print("onLCKAccept callback error: \(error)")
      }
    }
    print("onLCKAccept: code=\(code), msg=\(msg ?? "success")")
  }

  func onLCKHangup(code: Int, msg: String?) {
    let response = FLTSimpleResponse.make(
      withCode: NSNumber(value: code),
      msg: msg,
      data1: nil,
      data2: nil,
      data3: nil
    )
    _listener?.onLCKHangupResponse(response) { error in
      if let error = error {
        print("onLCKHangup callback error: \(error)")
      }
    }
    print("onLCKHangup: code=\(code), msg=\(msg ?? "success")")
  }

  func onVideoAvailable(_ available: Bool, userID: String) {
    // 直接调用 Flutter 回调
    _listener?.onVideoAvailableAvailable(NSNumber(value: available), userID: userID) { error in
      if let error = error {
        print("onVideoAvailable callback error: \(error)")
      }
    }
    print("onVideoAvailable: available=\(available), userID=\(userID)")
  }

  func onVideoMuted(_ muted: Bool, userID: String) {
    // 直接调用 Flutter 回调
    _listener?.onVideoMutedMuted(NSNumber(value: muted), userID: userID) { error in
      if let error = error {
        print("onVideoMuted callback error: \(error)")
      }
    }
    print("onVideoMuted: muted=\(muted), userID=\(userID)")
  }

  func onAudioMuted(_ muted: Bool, userID: String) {
    // 直接调用 Flutter 回调
    _listener?.onAudioMutedMuted(NSNumber(value: muted), userID: userID) { error in
      if let error = error {
        print("onAudioMuted callback error: \(error)")
      }
    }
    print("onAudioMuted: muted=\(muted), userID=\(userID)")
  }

  func onLocalAudioMuted(_ muted: Bool) {
    // 直接调用 Flutter 回调
    _listener?.onLocalAudioMutedMuted(NSNumber(value: muted)) { error in
      if let error = error {
        print("onLocalAudioMuted callback error: \(error)")
      }
    }
    print("onLocalAudioMuted: muted=\(muted)")
  }

  func onRtcInitEnd() {
    // 直接调用 Flutter 回调
    _listener?.onRtcInitEnd { error in
      if let error = error {
        print("onRtcInitEnd callback error: \(error)")
      }
    }
    print("onRtcInitEnd")
  }

  // MARK: - NERecordProvider 回调实现

  func onRecordSend(_ config: NERecordConfig) {
    // 转换 callState 为枚举
    let callState: FLTNIMRtcCallStatus
    switch config.callState {
    case .complete:
      callState = .completed
    case .canceled:
      callState = .cancelled
    case .rejected:
      callState = .rejected
    case .timeout:
      callState = .timeout
    case .busy:
      callState = .busy
    default:
      callState = .completed
    }

    // 创建 Flutter 回调参数
    let recordConfig = FLTRecordConfig.make(
      withAccId: config.accId,
      callType: config.callType == .video ? .video : .audio,
      callState: callState
    )

    // 直接调用 Flutter 回调
    _listener?.onRecordSend(recordConfig) { error in
      if let error = error {
        print("onRecordSend callback error: \(error)")
      }
    }
    print("onRecordSend: accId=\(config.accId)")
  }

  // MARK: - NECallEngineRtcDelegateEx 回调实现

  func onNERtcEngineVirtualBackgroundSourceEnabled(_ enabled: Bool, reason: NERtcVirtualBackgroundSourceStateReason) {
    // 直接调用 Flutter 回调
    _listener?.onNERtcEngineVirtualBackgroundSourceEnabledEnabled(NSNumber(value: enabled), reason: NSNumber(value: reason.rawValue)) { error in
      if let error = error {
        print("onNERtcEngineVirtualBackgroundSourceEnabled callback error: \(error)")
      }
    }
    print("onNERtcEngineVirtualBackgroundSourceEnabled: enabled=\(enabled), reason=\(reason.rawValue)")
  }

  // MARK: - NERtcEngineDelegateEx 实现

  func onNERtcEngineAsrCaptionResult(_ results: [NERtcAsrCaptionResult]?) {
    guard let asrResults = results, asrResults.count > 0 else {
      return
    }

    // 转换 NERtcAsrCaptionResult 到 FLTNERtcAsrCaptionResult
    var resultList: [FLTNERtcAsrCaptionResult] = []
    let resultCount = asrResults.count
    for i in 0 ..< resultCount {
      let nativeResult = asrResults[i]
      let uid = NSNumber(value: nativeResult.uid)
      let isLocalUser = NSNumber(value: nativeResult.isLocalUser)
      let timestamp = NSNumber(value: nativeResult.timestamp)
      let haveTranslation = NSNumber(value: nativeResult.haveTranslation)
      let isFinal = NSNumber(value: nativeResult.isFinal)
      let flutterResult = FLTNERtcAsrCaptionResult.make(
        withUid: uid,
        isLocalUser: isLocalUser,
        timestamp: timestamp,
        content: nativeResult.content,
        language: nativeResult.language,
        haveTranslation: haveTranslation,
        translatedText: nativeResult.translatedText,
        translationLanguage: nativeResult.translationLanguage,
        isFinal: isFinal
      )
      resultList.append(flutterResult)
    }

    // 调用 Flutter 回调
    _listener?.onAsrCaptionResultResult(resultList) { error in
      if let error = error {
        print("onAsrCaptionResult callback error: \(error)")
      }
    }
    print("onAsrCaptionResult: resultCount=\(resultCount)")
  }

  func onNERtcEngineAsrCaptionStateChanged(_ state: NERtcAsrCaptionState, code: Int32, message: String) {
    // 调用 Flutter 回调
    _listener?.onAsrCaptionStateChangedAsrState(
      NSNumber(value: state.rawValue),
      code: NSNumber(value: code),
      message: message
    ) { error in
      if let error = error {
        print("onAsrCaptionStateChanged callback error: \(error)")
      }
    }
    print("onAsrCaptionStateChanged: state=\(state.rawValue), code=\(code), message=\(message)")
  }
}

extension FLTCallkit: FLTAssociativeWrapper {
  func onAttachedToEngine(_ registrar: FlutterPluginRegistrar) {
    _listener = FLTCallKitEventSink(binaryMessenger: registrar.messenger())
    FLTCallKitApiSetup(registrar.messenger(), self)

    // 注册 PlatformView 工厂
    let factory = FLTCallKitPlatformViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "callkit_video_view")
  }

  func onDetachedFromEngine(_ registrar: FlutterPluginRegistrar) {
    NECallEngine.sharedInstance().removeCall(self)
    _listener = nil
    FLTCallKitApiSetup(registrar.messenger(), nil)
  }
}
