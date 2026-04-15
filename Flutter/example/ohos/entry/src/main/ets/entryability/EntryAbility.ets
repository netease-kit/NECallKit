import { FlutterAbility, FlutterEngine, MethodChannel, MethodResult, MethodCall } from '@ohos/flutter_ohos';
import { window } from '@kit.ArkUI';
import { AbilityConstant, Want, common } from '@kit.AbilityKit';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import CallkitPlugin from 'netease_callkit';
import CallkitUiPlugin from 'netease_callkit_ui';

export default class EntryAbility extends FlutterAbility {
  private urlLauncherChannel: MethodChannel | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 在 Flutter 引擎初始化前设置 UIAbilityContext
    CallkitPlugin.setUIAbilityContext(this.context);
    CallkitUiPlugin.setUIAbilityContext(this.context);
    console.info('[EntryAbility] onCreate: setUIAbilityContext called');
    super.onCreate(want, launchParam);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage);
    
    console.info('[EntryAbility] onWindowStageCreate called');
    
    // 设置 WindowStage 用于支持来电横幅功能
    try {
      CallkitUiPlugin.setWindowStage(windowStage);
      console.info('[EntryAbility] CallkitUiPlugin.setWindowStage called successfully');
    } catch (e) {
      console.error('[EntryAbility] CallkitUiPlugin.setWindowStage failed: ' + JSON.stringify(e));
    }
    
    try {
      const win = windowStage.getMainWindowSync();
      win.setWindowLayoutFullScreen(true);
      win.setWindowSystemBarEnable([]);
    } catch (e) {
      console.error('[EntryAbility] setWindowLayoutFullScreen failed: ' + JSON.stringify(e));
    }
  }

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    // 注册 URL Launcher MethodChannel
    this.urlLauncherChannel = new MethodChannel(
      flutterEngine.dartExecutor.getBinaryMessenger(),
      'com.netease.callkit/url_launcher'
    );
    this.urlLauncherChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        console.info('[EntryAbility] MethodCall received: method=' + call.method + ', args=' + JSON.stringify(call.args));
        if (call.method === 'openUrl') {
          // 尝试多种方式获取 URL 参数
          let url: string | null = null;
          
          if (call.args) {
            // 方式1: 直接从 args 对象获取
            if (typeof call.args === 'object') {
              const args = call.args as Record<string, ESObject>;
              url = args['url'] as string;
            }
            // 方式2: 使用 argument 方法获取
            if (!url) {
              try {
                url = call.argument('url') as string;
              } catch (e) {
                console.warn('[EntryAbility] call.argument failed: ' + JSON.stringify(e));
              }
            }
          }
          
          console.info('[EntryAbility] Extracted URL: ' + url);
          
          if (url && url.length > 0) {
            this.openUrlInBrowser(url, result);
          } else {
            result.error('INVALID_URL', 'URL is null or empty, args=' + JSON.stringify(call.args), null);
          }
        } else {
          result.notImplemented();
        }
      }
    });
    console.info('[EntryAbility] URL Launcher MethodChannel registered');
  }

  /**
   * 在浏览器中打开 URL
   */
  private openUrlInBrowser(url: string, result: MethodResult): void {
    try {
      const context = this.context as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: url
      };
      context.startAbility(want).then(() => {
        console.info('[EntryAbility] openUrlInBrowser success: ' + url);
        result.success(true);
      }).catch((err: Error) => {
        console.error('[EntryAbility] openUrlInBrowser failed: ' + JSON.stringify(err));
        result.error('LAUNCH_FAILED', 'Failed to open URL: ' + err.message, null);
      });
    } catch (e) {
      console.error('[EntryAbility] openUrlInBrowser exception: ' + JSON.stringify(e));
      result.error('EXCEPTION', 'Exception while opening URL: ' + JSON.stringify(e), null);
    }
  }
}
