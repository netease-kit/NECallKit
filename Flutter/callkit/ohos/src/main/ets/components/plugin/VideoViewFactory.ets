import { BinaryMessenger, PlatformView, PlatformViewFactory, StandardMessageCodec } from '@ohos/flutter_ohos';
import { VideoView } from './VideoView';
import { common } from '@kit.AbilityKit';

// 3.1: VideoViewFactory 参考 ohos_platform/VideoViewFactory.ets
export class VideoViewFactory extends PlatformViewFactory {
  private messenger: BinaryMessenger | null = null;
  private appContext: common.Context | null = null;

  // 3.2: 静态 videoViewMap，供 CallKitPlatform 查表
  static videoViewMap: Map<number, VideoView> = new Map();

  // 3.4: 构造函数接收 BinaryMessenger 和 Context
  constructor(msg: BinaryMessenger, context: common.Context) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = msg;
    this.appContext = context;
  }

  // 3.3: create() 创建 VideoView 并注册到 videoViewMap
  public create(context: Context, viewId: number, args: ESObject): PlatformView {
    let params: Map<string, ESObject> = args as Map<string, ESObject>;
    let videoView = new VideoView(context, this.appContext!, this.messenger!, viewId, params);
    VideoViewFactory.videoViewMap.set(viewId, videoView);
    return videoView;
  }
}
