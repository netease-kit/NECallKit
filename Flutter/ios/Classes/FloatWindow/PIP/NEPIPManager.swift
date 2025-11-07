// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFoundation
import AVKit
import NERtcCallKit
import NERtcSDK
import os.log
import UIKit

/// 应用外小窗（画中画）管理器
@available(iOS 15.0, *)
class NEPIPManager: NSObject {
  /// 单例
  static let instance = NEPIPManager()
  /// 统一日志 tag
  let tag: String = "NEPIPManager"

  /// 画中画容器视图
  private var pipContainerView: UIView?

  /// 画中画视频通话视图控制器
  private var videoCallViewController: AVPictureInPictureVideoCallViewController?

  /// 视频显示视图
  private var displayView: UIView?

  /// 画中画控制器
  private var pipController: AVPictureInPictureController?

  /// 是否已启用画中画
  private var isPIPEnabled: Bool = false

  /// 视频渲染器（用于接收远端视频流）
  private var videoRenderer: NECallKitPIPRenderer?

  let remoteUserObserver = NEObserver()

  override private init() {
    super.init()
  }

  deinit {
    cleanup()
  }

  /// 设置画中画
  /// - Parameter completion: 完成回调
  func setupPIP(completion: @escaping (Bool) -> Void) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: setupPIP called")

    // 只有在通话建立时才设置画中画
    guard NECallState.instance.selfUser.value.callStatus == .accept else {
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Call not established, skipping PIP setup")
      completion(false)
      return
    }

    // 检查设备是否支持画中画
    guard AVPictureInPictureController.isPictureInPictureSupported() else {
      NEFLTCallUIKitLog.errorLog(tag, desc: "NEPIPManager: Device does not support Picture-in-Picture")
      completion(false)
      return
    }

    // 创建容器视图
    if pipContainerView == nil {
      pipContainerView = UIView(frame: getMainWindow().bounds)
      pipContainerView?.backgroundColor = UIColor.clear
      pipContainerView?.isUserInteractionEnabled = false
    }

    let containerView = pipContainerView!

    // 添加到主窗口
    if !containerView.isDescendant(of: getMainWindow()) {
      getMainWindow().addSubview(containerView)
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Added pipContainerView to window")
    }

    // 创建视频通话视图控制器
    let videoCallVC = AVPictureInPictureVideoCallViewController()
    videoCallVC.preferredContentSize = CGSize(
      width: containerView.frame.size.height / 16.0 * 9.0,
      height: containerView.frame.size.height
    )
    videoCallVC.view.backgroundColor = UIColor.black

    // 创建显示视图
    let displayContentView = createDisplayView()
    displayContentView.backgroundColor = UIColor.black

    // 添加显示视图到视频通话视图控制器
    displayContentView.translatesAutoresizingMaskIntoConstraints = false
    videoCallVC.view.addSubview(displayContentView)
    NSLayoutConstraint.activate([
      displayContentView.topAnchor.constraint(equalTo: videoCallVC.view.topAnchor),
      displayContentView.leadingAnchor.constraint(equalTo: videoCallVC.view.leadingAnchor),
      displayContentView.trailingAnchor.constraint(equalTo: videoCallVC.view.trailingAnchor),
      displayContentView.bottomAnchor.constraint(equalTo: videoCallVC.view.bottomAnchor),
    ])

    videoCallViewController = videoCallVC
    displayView = displayContentView

    // 创建内容源
    let contentSource = AVPictureInPictureController.ContentSource(
      activeVideoCallSourceView: containerView,
      contentViewController: videoCallVC
    )

    pipController = AVPictureInPictureController(contentSource: contentSource)
    pipController?.delegate = self

    pipController?.canStartPictureInPictureAutomaticallyFromInline = true

    isPIPEnabled = true

    updateDisplayView()
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP setup completed successfully, canStartAutomatically: true")
    completion(true)
  }

  func disposePIP() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: disposePIP called")

    if let containerView = pipContainerView, containerView.superview != nil {
      containerView.removeFromSuperview()
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Removed containerView from window")
    }

    if let controller = pipController, controller.isPictureInPictureActive {
      controller.stopPictureInPicture()
    }

    NECallState.instance.remoteUser.removeObserver(remoteUserObserver)

    stopVideoRendering()
    pipContainerView = nil
    videoCallViewController = nil
    displayView = nil
    pipController = nil
    isPIPEnabled = false

    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP disposed")
  }

  func isPIPActive() -> Bool {
    pipController?.isPictureInPictureActive ?? false
  }

  /// 启动视频渲染
  func startVideoRendering() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: startVideoRendering called")
    guard NECallState.instance.mediaType.value == .video else {
      return
    }

    let remoteUser = NECallState.instance.remoteUser.value
    let userUuid = remoteUser.id

    if videoRenderer != nil, videoRenderer?.userUuid == userUuid {
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Video renderer already started for user: \(userUuid)")
      return
    }

    // 创建渲染器
    videoRenderer = NECallKitPIPRenderer.render(withUserUuid: userUuid)

    // 设置渲染结果回调
    videoRenderer?.renderResult = { [weak self] userUuid, width, height, bufferRef in
      self?.onVideoFrame(userUuid: userUuid, width: width, height: height, buffer: bufferRef)
    }

    // 使用 NERtcCallKit 设置远端视频渲
    if let canvas = createVideoCanvas() {
      setupRemoteVideoWithCanvas(canvas, userUuid: userUuid)
    }
  }

  /// 停止视频渲染
  func stopVideoRendering() {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: stopVideoRendering called")
    guard NECallState.instance.mediaType.value == .video else {
      return
    }

    // 清理视频渲染器
    NECallEngine.sharedInstance().setupRemoteView(nil)
    videoRenderer = nil
  }

  /// 创建视频画布
  private func createVideoCanvas() -> NERtcVideoCanvas? {
    guard let renderer = videoRenderer else { return nil }

    let canvas = NERtcVideoCanvas()
    canvas.useExternalRender = true
    canvas.externalVideoRender = renderer
    return canvas
  }

  /// 设置远端视频画布并订阅视频流
  private func setupRemoteVideoWithCanvas(_ canvas: NERtcVideoCanvas, userUuid: String) {
    NECallEngine.sharedInstance().setupRemoteView(nil)
    NECallEngine.sharedInstance().setupRemoteCanvas(canvas)
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Setup remote video canvas with external render for user: \(userUuid)")
  }

  /// 视频帧回调
  private func onVideoFrame(userUuid: String, width: UInt32, height: UInt32, buffer: CMSampleBuffer?) {
    guard let buffer = buffer else { return }

    // 将视频帧渲染到显示视图
    guard let displayView = displayView else { return }

    // 使用 AVSampleBufferDisplayLayer 显示视频帧
    if let layer = displayView.layer as? AVSampleBufferDisplayLayer {
      if layer.status == .failed {
        layer.flush()
      }
      layer.enqueue(buffer)
    }
  }

  /// 获取主窗口
  private func getMainWindow() -> UIWindow {
    if #available(iOS 13.0, *) {
      for scene in UIApplication.shared.connectedScenes {
        if let windowScene = scene as? UIWindowScene,
           windowScene.activationState == .foregroundActive {
          return windowScene.windows.first ?? UIWindow()
        }
      }
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        return windowScene.windows.first ?? UIWindow()
      }
    }
    return UIApplication.shared.windows.first ?? UIWindow()
  }

  /// 创建画中画容器视图
  private func getPipContainerView() -> UIView {
    if pipContainerView == nil {
      let window = getMainWindow()
      pipContainerView = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.size.width, height: window.frame.size.height))
      pipContainerView?.backgroundColor = UIColor.clear
      pipContainerView?.isUserInteractionEnabled = false
    }
    return pipContainerView!
  }

  /// 创建显示视图（使用 NECallKitSampleBufferDisplayView）
  private func createDisplayView() -> UIView {
    let view = NECallKitSampleBufferDisplayView(frame: .zero)

    // 配置 AVSampleBufferDisplayLayer
    if let layer = view.layer as? AVSampleBufferDisplayLayer {
      layer.videoGravity = .resizeAspectFill
    }
    // 监听远程用户状态变化
    NECallState.instance.remoteUser.addObserver(remoteUserObserver, options: [.new]) { [weak self] newUser, _ in
      self?.updateDisplayView()
    }
    return view
  }

  /// 更新显示视图
  private func updateDisplayView() {
    guard let displayView = displayView as? NECallKitSampleBufferDisplayView else { return }

    let remoteUser = NECallState.instance.remoteUser.value

    if remoteUser.videoAvailable {
      // 显示视频 - 视频流会通过 onVideoFrame 回调播放
      displayView.setAvatarHidden(true)
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Showing video for user: \(remoteUser.id)")
    } else {
      // 显示头像
      displayView.setAvatarHidden(false)
      displayView.setAvatarURL(remoteUser.avatar)
      NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: Showing avatar for user: \(remoteUser.nickname)")
    }
  }

  /// 清理资源
  private func cleanup() {
    disposePIP()
  }
}

// MARK: - AVPictureInPictureControllerDelegate

@available(iOS 15.0, *)
extension NEPIPManager: AVPictureInPictureControllerDelegate {
  func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP will start")
  }

  func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    startVideoRendering()
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP did start, isActive: \(String(pictureInPictureController.isPictureInPictureActive))")
  }

  func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP will stop")
  }

  func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP did stop")
  }

  func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
    NEFLTCallUIKitLog.errorLog(tag, desc: "NEPIPManager: PIP failed to start - \(error.localizedDescription)")
  }

  func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    NEFLTCallUIKitLog.infoLog(tag, desc: "NEPIPManager: PIP restore user interface for stop")
    completionHandler(true)
  }
}
