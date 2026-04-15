import { BinaryMessenger, MethodCall, PlatformView } from '@ohos/flutter_ohos';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { common } from '@kit.AbilityKit';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { NERtcVideoView, NERtcConstants } from '@nertc/nertc_sdk';
import { VideoViewFactory } from './VideoViewFactory';

const TAG = "CallkitVideoView";

@Component
struct VideoViewComponent {
  @Prop params: Params
  videoView: VideoView = this.params.platformView as VideoView
  @State canvasId: string = this.videoView.getCanvasId()

  build() {
    NERtcVideoView({
      canvasId: this.canvasId,
      onLoad: () => {
        this.videoView.onLoad()
      },
    })
  }
}

@Builder
function VideoViewBuilder(params: Params) {
  VideoViewComponent({ params: params })
}

@Observed
export class VideoView extends PlatformView implements MethodCallHandler {
  private context: common.Context | null = null;
  private appContext: common.Context | null = null;
  private canvasId: string = "";
  private channel: MethodChannel | null = null;
  private viewId: number = -1;

  constructor(ctx: common.Context, appContext: common.Context,
    messenger: BinaryMessenger, id: number, params: Map<string, ESObject>) {
    super();
    this.context = ctx;
    this.appContext = appContext;
    this.viewId = id;
    this.canvasId = params.get("canvasId") as string ?? String(id);
    // 修复：使用与 Flutter 端一致的 Channel 名称
    this.channel = new MethodChannel(messenger, "ne_call_kit/video_view_" + id);
    this.channel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "destroyVideoView":
        // 新增：处理 destroyVideoView 方法
        this.handleDestroyVideoView();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  // 新增：处理视频视图销毁
  private handleDestroyVideoView(): void {
    console.info(TAG, `destroyVideoView called for viewId: ${this.viewId}`);
    VideoViewFactory.videoViewMap.delete(this.viewId);
  }

  public onLoad = () => {
    this.channel?.invokeMethod("onLoad", new Map());
  }

  // 2.4: getCanvasId() 供 CallKitPlatform 查询
  getCanvasId(): string {
    return this.canvasId;
  }

  // 获取 NERtcVideoCanvas 对象
  // 参考Android端的SCALE_ASPECT_BALANCED，设置scalingMode为Fit模式
  getCanvas(): NERtcConstants.NERtcVideoCanvas {
    return {
      canvasId: this.canvasId,
      scalingMode: NERtcConstants.NERtcVideoScalingMode.kNERtcVideoScaleCropFill
    };
  }

  // 2.5: getView() 返回 WrappedBuilder
  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(VideoViewBuilder);
  }

  // 2.6: dispose() 注销 MethodChannel 并从 videoViewMap 移除
  dispose(): void {
    console.info(TAG, `[Native] dispose() called for viewId: ${this.viewId}`);
    this.channel?.setMethodCallHandler(null);
    console.info(TAG, `[Native] setMethodCallHandler(null) done for viewId: ${this.viewId}`);
    VideoViewFactory.videoViewMap.delete(this.viewId);
    console.info(TAG, `[Native] videoViewMap.delete done for viewId: ${this.viewId}`);
  }
}