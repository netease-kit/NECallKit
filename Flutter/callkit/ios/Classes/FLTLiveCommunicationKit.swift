// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFAudio
import Foundation
import NERtcCallKit
import NERtcSDK
import NIMSDK
import PushKit

protocol FLTLiveCommunicationKitEventDelegate: AnyObject {
  func onLCKAccept(code: Int, msg: String?, callInfo: NECallInfo?)
  func onLCKHangup(code: Int, msg: String?)
}

/// Live Communication Kit 配置类
@objc public class FLTLiveCommunicationKit: NSObject {
  /// 是否启用 Live Communication Kit
  @objc public var enableLiveCommunicationKit: Bool = true

  /// 铃声名称
  @objc public var ringtoneName: String?

  /// 初始化方法
  @objc public init(enableLiveCommunicationKit: Bool = true, ringtoneName: String? = nil) {
    self.enableLiveCommunicationKit = enableLiveCommunicationKit
    self.ringtoneName = ringtoneName
    super.init()
  }

  /// 从字典初始化
  @objc public static func fromDictionary(_ dict: [String: Any]) -> FLTLiveCommunicationKit? {
    guard let enable = dict["enableLiveCommunicationKit"] as? Bool else {
      return nil
    }

    let ringtoneName = dict["ringtoneName"] as? String

    return FLTLiveCommunicationKit(
      enableLiveCommunicationKit: enable,
      ringtoneName: ringtoneName
    )
  }

  /// 转换为字典
  @objc public func toDictionary() -> [String: Any] {
    var dict: [String: Any] = [
      "enableLiveCommunicationKit": enableLiveCommunicationKit,
    ]

    if let ringtoneName = ringtoneName {
      dict["ringtoneName"] = ringtoneName
    }

    return dict
  }
}

/// Live Communication Kit 管理器
@objc public class FLTLiveCommunicationKitManager: NSObject, PKPushRegistryDelegate {
  /// 单例
  @objc public static let shared = FLTLiveCommunicationKitManager()

  weak var eventDelegate: FLTLiveCommunicationKitEventDelegate?

  /// 当前配置
  @objc public var currentConfig: FLTLiveCommunicationKit?

  /// 通知名称常量
  private static let incomingStateChangedNotification = "NELiveCommunicationKitIncomingStateChanged"

  override private init() {
    super.init()
  }

  /// 初始化 Live Communication Kit
  @objc public func initialize(with config: FLTLiveCommunicationKit) {
    currentConfig = config

    if config.enableLiveCommunicationKit {
      if #available(iOS 17.4, *) {
        registerPushKit()
      }
    }
  }

  /// 销毁 Live Communication Kit
  @objc public func destroy() {
    currentConfig = nil
  }

  /// 检查是否启用
  @objc public func isEnabled() -> Bool {
    currentConfig?.enableLiveCommunicationKit ?? false
  }

  /// 获取铃声名称
  @objc public func getRingtoneName() -> String? {
    currentConfig?.ringtoneName
  }

  func registerPushKit() {
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.global(qos: .default))
    pushRegistry.delegate = self
    pushRegistry.desiredPushTypes = [.voIP]
  }

  // MARK: - PKPushRegistryDelegate

  public func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    if pushCredentials.token.isEmpty {
      return
    }

    NIMSDK.shared().updatePushKitToken(pushCredentials.token)
  }

  public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
    // 判断是否是云信发的payload
    if payload.dictionaryPayload["nim"] == nil {
      return
    }

    let param = NECallSystemIncomingCallParam()
    param.payload = payload.dictionaryPayload
    param.ringtoneName = currentConfig?.ringtoneName

    if #available(iOS 17.4, *) {
      // 在后台需要先设置playback，规避后台启动失败的问题
      DispatchQueue.main.async {
        if UIApplication.shared.applicationState != .active {
          do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
          } catch {
            print("AVAudioSession setCategory playback error \(error.localizedDescription)")
          }
        }
      }

      // 在主线程发送 Incoming 状态开始通知
      DispatchQueue.main.async {
        NotificationCenter.default.post(
          name: NSNotification.Name("NELiveCommunicationKitIncomingStateChanged"),
          object: nil,
          userInfo: ["lckIsInIncomingState": true]
        )
        print("FLTLiveCommunicationKit: Incoming state started")
      }

      // 调用 reportIncomingCall 接口
      NECallEngine.sharedInstance().reportIncomingCall(with: param) { [weak self] error, callInfo in
        let nsError = error as NSError?
        self?.eventDelegate?.onLCKAccept(
          code: nsError?.code ?? 0,
          msg: nsError?.localizedDescription,
          callInfo: callInfo
        )
      } hangupCompletion: { [weak self] error in
        let nsError = error as NSError?
        self?.eventDelegate?.onLCKHangup(
          code: nsError?.code ?? 0,
          msg: nsError?.localizedDescription
        )
      } muteCompletion: { error, mute in
        if let err = error {}
      }
    }

    completion()
  }
}
