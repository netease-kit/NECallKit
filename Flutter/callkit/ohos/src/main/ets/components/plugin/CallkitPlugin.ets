import {
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { CallKitApi, GroupCallKitApi, SimpleResponse, GroupSimpleResponse } from './Pigeon';
import { CallKitPlatform } from './CallKitPlatform';
import { GroupCallKitPlatform } from './GroupCallKitPlatform';
import { VideoViewFactory } from './VideoViewFactory';

const VIEW_TYPE = "callkit_video_view";

// Result 接口定义
interface DestroyResult {
  success(value: SimpleResponse): void;
  error(error: Error): void;
}

// DestroyResult 类实现
class DestroyResultImpl implements DestroyResult {
  success(_value: SimpleResponse): void {
    // fire-and-forget
  }
  error(_error: Error): void {
    // fire-and-forget
  }
}

// GroupReleaseResult 接口定义
interface GroupReleaseResult {
  success(value: GroupSimpleResponse): void;
  error(error: Error): void;
}

// GroupReleaseResult 类实现
class GroupReleaseResultImpl implements GroupReleaseResult {
  success(_value: GroupSimpleResponse): void {
    // fire-and-forget
  }
  error(_error: Error): void {
    // fire-and-forget
  }
}

/** CallkitPlugin —— 鸿蒙端通话插件入口 (支持 P2P 和群呼) **/
export default class CallkitPlugin implements FlutterPlugin {
  private callKitPlatform: CallKitPlatform | null = null;
  private groupCallKitPlatform: GroupCallKitPlatform | null = null;
  
  // 静态变量保存 UIAbilityContext（由宿主应用设置）
  private static uiAbilityContext: common.UIAbilityContext | null = null;
  
  /**
   * 设置 UIAbilityContext（必须在 Flutter 引擎初始化前调用）
   * 宿主应用需要在 EntryAbility 中调用此方法
   * @param context UIAbilityContext
   */
  public static setUIAbilityContext(context: common.UIAbilityContext): void {
    CallkitPlugin.uiAbilityContext = context;
    console.info('[CallkitPlugin] setUIAbilityContext called');
  }
  
  /**
   * 获取 UIAbilityContext
   * @returns UIAbilityContext 或 null
   */
  public static getUIAbilityContext(): common.UIAbilityContext | null {
    return CallkitPlugin.uiAbilityContext;
  }

  constructor() {}

  getUniqueClassName(): string {
    return "CallkitPlugin";
  }

  // 6.2 & 6.3: onAttachedToEngine —— 注册 CallKitApi、GroupCallKitApi 和 VideoViewFactory
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    const messenger = binding.getBinaryMessenger();
    
    // 优先使用通过 setUIAbilityContext 设置的 UIAbilityContext
    // 如果未设置，则回退使用 ApplicationContext（可能导致 RTC 初始化失败）
    let context: common.Context;
    if (CallkitPlugin.uiAbilityContext) {
      context = CallkitPlugin.uiAbilityContext;
      console.info('[CallkitPlugin] Using UIAbilityContext');
    } else {
      context = binding.getApplicationContext() as common.Context;
      console.warn('[CallkitPlugin] UIAbilityContext not set, falling back to ApplicationContext. This may cause RTC initialization to fail.');
    }

    // 创建 CallKitPlatform（内部持有 CallKitEventSink）
    this.callKitPlatform = new CallKitPlatform(messenger, context);

    // 注册 Pigeon CallKitApi 消息处理器
    CallKitApi.setup(messenger, this.callKitPlatform);

    // 创建 GroupCallKitPlatform（内部持有 GroupCallKitEventSink）
    this.groupCallKitPlatform = new GroupCallKitPlatform(messenger, context);

    // 注册 Pigeon GroupCallKitApi 消息处理器
    GroupCallKitApi.setup(messenger, this.groupCallKitPlatform);

    // 注册视频 PlatformView 工厂
    const videoViewFactory = new VideoViewFactory(messenger, context);
    binding.getPlatformViewRegistry()?.registerViewFactory(VIEW_TYPE, videoViewFactory);
  }

  // 6.4: onDetachedFromEngine —— 注销处理器，释放资源
  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    const messenger = binding.getBinaryMessenger();
    
    // 注销 CallKitApi 消息处理器
    CallKitApi.setup(messenger, null);
    const destroyResult: DestroyResult = new DestroyResultImpl();
    this.callKitPlatform?.destroy(destroyResult);
    this.callKitPlatform = null;
    
    // 注销 GroupCallKitApi 消息处理器
    GroupCallKitApi.setup(messenger, null);
    const releaseResult: GroupReleaseResult = new GroupReleaseResultImpl();
    this.groupCallKitPlatform?.release(releaseResult);
    this.groupCallKitPlatform = null;
  }
}