import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let shutdownChannelName = "callkit_example/app_shutdown"
  private var shutdownChannel: FlutterMethodChannel?
  private var terminationPreparationInProgress = false
  private var terminationPreparationCompleted = false

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

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
        guard let self = self else {
          NSApp.reply(toApplicationShouldTerminate: true)
          return
        }
        self.terminationPreparationInProgress = false
        self.terminationPreparationCompleted = true
        NSApp.reply(toApplicationShouldTerminate: true)
      }
    }
    return .terminateLater
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
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
