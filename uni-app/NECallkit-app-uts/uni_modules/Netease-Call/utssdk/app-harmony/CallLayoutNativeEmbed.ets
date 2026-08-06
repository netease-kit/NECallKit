import {
  FrameNode,
  NodeController,
  NodeRenderType,
  UIContext
} from '@kit.ArkUI';
import {
  defineNativeEmbed,
  NativeEmbedBuilderOptions,
  NativeEmbedEvent
} from '@dcloudio/uni-app-runtime';
import {
  INECallLayoutStateProvider,
  NECallLayout,
  NECallLayoutRenderModel,
  NECallLayoutSnapshot,
  NECallLayoutStateObserver,
  NECallLayoutView,
  NEDefaultCallLayoutStateProvider
} from '@yunxin/callkit_ui';
import { NECallControls } from './NECallControls';

const UTS_DEFAULT_AVATAR_URL: string =
  'https://yx-web-nosdn.netease.im/common/8aaaf3fb0524d941d603f32c877d897d/default-avatar.png';
const SMALL_VIDEO_WIDTH: number = 90;
const SMALL_VIDEO_HEIGHT: number = 160;
const SMALL_VIDEO_INITIAL_TOP: number = 40;
const SMALL_VIDEO_INITIAL_RIGHT: number = 16;
const SMALL_VIDEO_SNAP_MARGIN: number = 20;
const SMALL_VIDEO_SNAP_ANIMATION_MS: number = 300;

class NECallLayoutUtsStateProvider implements INECallLayoutStateProvider {
  private readonly source: INECallLayoutStateProvider = new NEDefaultCallLayoutStateProvider();

  getSnapshot(): NECallLayoutSnapshot {
    const snapshot = this.source.getSnapshot();
    const usesSdkFallbackAvatar: boolean = snapshot.remoteAvatar === UTS_DEFAULT_AVATAR_URL;
    if (usesSdkFallbackAvatar) {
      snapshot.remoteAvatar = '';
    }
    console.log(
      `[NECallLayoutUTS] callType=${snapshot.callType}, callStatus=${snapshot.callStatus}, ` +
      `remoteUserId=${snapshot.remoteUserId}, remoteUserName=${snapshot.remoteUserName}, ` +
      `avatarSource=${usesSdkFallbackAvatar ? 'generated' : 'remote'}`
    );
    return snapshot;
  }

  addObserver(observer: NECallLayoutStateObserver): void {
    this.source.addObserver(observer);
  }

  removeObserver(observer: NECallLayoutStateObserver): void {
    this.source.removeObserver(observer);
  }
}

@Component
struct NECallLayoutHost {
  controller: NECallLayoutEmbedController = new NECallLayoutEmbedController();
  @State model: NECallLayoutRenderModel = new NECallLayoutRenderModel();

  aboutToAppear(): void {
    this.model = this.controller.getRenderModel();
  }

  aboutToDisappear(): void {
    this.controller.dispose();
  }

  build() {
    NECallLayoutView({
      model: this.model
    })
      .width('100%')
      .height('100%')
  }
}

@Component
struct NECallSmallVideoHitProxy {
  controller: NECallLayoutEmbedController = new NECallLayoutEmbedController();
  containerWidth: number = 0;
  containerHeight: number = 0;
  statusBarHeight: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private startOffsetX: number = 0;
  private startOffsetY: number = 0;

  private clampOffsetX(offsetX: number): number {
    const minOffset = -(
      Math.max(0, this.containerWidth - SMALL_VIDEO_WIDTH - SMALL_VIDEO_INITIAL_RIGHT)
    );
    return Math.max(minOffset, Math.min(offsetX, SMALL_VIDEO_INITIAL_RIGHT));
  }

  private clampOffsetY(offsetY: number): number {
    const maxOffset = Math.max(
      0,
      this.containerHeight - SMALL_VIDEO_HEIGHT - SMALL_VIDEO_INITIAL_TOP
    );
    return Math.max(-SMALL_VIDEO_INITIAL_TOP, Math.min(offsetY, maxOffset));
  }

  private snapToNearestEdge(): void {
    if (this.containerWidth <= 0 || this.containerHeight <= 0) {
      return;
    }
    const initialLeft: number = this.containerWidth - SMALL_VIDEO_WIDTH -
      SMALL_VIDEO_INITIAL_RIGHT;
    const currentCenterX: number = initialLeft + this.offsetX + SMALL_VIDEO_WIDTH / 2;
    const currentCenterY: number = SMALL_VIDEO_INITIAL_TOP + this.offsetY +
      SMALL_VIDEO_HEIGHT / 2;
    const distanceToLeft: number = currentCenterX;
    const distanceToRight: number = this.containerWidth - currentCenterX;
    const distanceToTop: number = currentCenterY;
    const distanceToBottom: number = this.containerHeight - currentCenterY;
    const minDistance: number = Math.min(
      distanceToLeft,
      distanceToRight,
      distanceToTop,
      distanceToBottom
    );
    let targetOffsetX: number = this.offsetX;
    let targetOffsetY: number = this.offsetY;

    if (minDistance === distanceToLeft) {
      targetOffsetX = SMALL_VIDEO_SNAP_MARGIN - initialLeft;
    } else if (minDistance === distanceToRight) {
      targetOffsetX = this.containerWidth - SMALL_VIDEO_WIDTH - SMALL_VIDEO_SNAP_MARGIN -
        initialLeft;
    } else if (minDistance === distanceToTop) {
      targetOffsetY = this.statusBarHeight + SMALL_VIDEO_SNAP_MARGIN - SMALL_VIDEO_INITIAL_TOP;
    } else {
      targetOffsetY = this.containerHeight - SMALL_VIDEO_HEIGHT - SMALL_VIDEO_SNAP_MARGIN -
        SMALL_VIDEO_INITIAL_TOP;
    }

    targetOffsetX = this.clampOffsetX(targetOffsetX);
    targetOffsetY = this.clampOffsetY(targetOffsetY);
    const applyTargetPosition = (): void => {
      this.offsetX = targetOffsetX;
      this.offsetY = targetOffsetY;
      this.controller.moveSmallVideo(this.offsetX, this.offsetY);
    };
    this.getUIContext()?.animateTo(
      { duration: SMALL_VIDEO_SNAP_ANIMATION_MS, curve: Curve.EaseOut },
      applyTargetPosition
    );
  }

  build() {
    Column()
      .width(SMALL_VIDEO_WIDTH)
      .height(SMALL_VIDEO_HEIGHT)
      .position({ top: SMALL_VIDEO_INITIAL_TOP, right: SMALL_VIDEO_INITIAL_RIGHT })
      .translate({ x: this.offsetX, y: this.offsetY })
      .backgroundColor(Color.Transparent)
      .hitTestBehavior(HitTestMode.Block)
      .gesture(
        PanGesture()
          .onActionStart(() => {
            this.startOffsetX = this.offsetX;
            this.startOffsetY = this.offsetY;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetX = this.clampOffsetX(this.startOffsetX + event.offsetX);
            this.offsetY = this.clampOffsetY(this.startOffsetY + event.offsetY);
            this.controller.moveSmallVideo(this.offsetX, this.offsetY);
          })
          .onActionEnd(() => this.snapToNearestEdge())
      )
      .onClick(() => this.controller.switchVideoSize())
  }
}

class NECallActionEventDetail {
  action: string;

  constructor(action: string) {
    this.action = action;
  }
}

class NECallToggleEventDetail {
  enabled: boolean;

  constructor(enabled: boolean) {
    this.enabled = enabled;
  }
}

class NECallLayoutEmbedController extends NodeController {
  private callLayout: NECallLayout | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    return null;
  }

  getRenderModel(): NECallLayoutRenderModel {
    console.log('[NECallLayoutEmbed] getRenderModel');
    return this.ensureCallLayout().getRenderModel();
  }

  getRenderRevision(): number {
    return this.ensureCallLayout().getRenderRevision();
  }

  switchVideoSize(): void {
    console.log('[NECallLayoutEmbed] switchVideoSize');
    this.getRenderModel().params.onSwitch();
  }

  moveSmallVideo(offsetX: number, offsetY: number): void {
    this.ensureCallLayout().moveSmallVideo(offsetX, offsetY);
  }

  addRenderObserver(observer: (revision: number) => void): void {
    this.ensureCallLayout().addRenderObserver(observer);
  }

  removeRenderObserver(observer: (revision: number) => void): void {
    this.callLayout?.removeRenderObserver(observer);
  }

  aboutToDisappear(): void {
    console.log('[NECallLayoutEmbed] aboutToDisappear');
    this.dispose();
  }

  dispose(): void {
    this.callLayout?.dispose();
    this.callLayout = null;
  }

  private ensureCallLayout(): NECallLayout {
    if (this.callLayout === null) {
      this.callLayout = new NECallLayout(new NECallLayoutUtsStateProvider());
    }
    return this.callLayout;
  }
}

interface CallLayoutNativeEmbedBuilderOptions extends NativeEmbedBuilderOptions {
  controller: NECallLayoutEmbedController;
  callStatus: string;
  callRole: string;
  mediaType: number;
  callDuration: string;
  statusBarHeight: number;
  isGroupCall: boolean;
  isLocalMicOpen: boolean;
  isLocalCameraOpen: boolean;
  isSpeakerphoneOn: boolean;
  enableFloatingWindow: boolean;
  supportAudioToVideo: boolean;
  supportVideoToAudio: boolean;
  microphoneText: string;
  speakerText: string;
  hangupText: string;
  acceptText: string;
  rejectText: string;
}

function emitAction(options: CallLayoutNativeEmbedBuilderOptions, eventName: string): void {
  const callback = options.on?.get(eventName);
  if (callback !== undefined) {
    callback({ detail: new NECallActionEventDetail(eventName) } as NativeEmbedEvent);
  }
}

function emitToggle(
  options: CallLayoutNativeEmbedBuilderOptions,
  eventName: string,
  enabled: boolean
): void {
  const callback = options.on?.get(eventName);
  if (callback !== undefined) {
    callback({ detail: new NECallToggleEventDetail(enabled) } as NativeEmbedEvent);
  }
}

@Builder
function CallLayoutNativeEmbedBuilder(options: CallLayoutNativeEmbedBuilderOptions) {
  Stack() {
    NECallLayoutHost({ controller: options.controller })
      .width('100%')
      .height('100%')

    NECallControls({
      callStatus: options.callStatus,
      callRole: options.callRole,
      mediaType: options.mediaType,
      callDuration: options.callDuration,
      isGroupCall: options.isGroupCall,
      isLocalMicOpen: options.isLocalMicOpen,
      isLocalCameraOpen: options.isLocalCameraOpen,
      isSpeakerphoneOn: options.isSpeakerphoneOn,
      enableFloatingWindow: options.enableFloatingWindow,
      supportAudioToVideo: options.supportAudioToVideo,
      supportVideoToAudio: options.supportVideoToAudio,
      microphoneText: options.microphoneText,
      speakerText: options.speakerText,
      hangupText: options.hangupText,
      acceptText: options.acceptText,
      rejectText: options.rejectText,
      onAccept: () => emitAction(options, 'accept'),
      onReject: () => emitAction(options, 'reject'),
      onHangup: () => emitAction(options, 'hangup'),
      onMicrophoneToggle: (enabled: boolean) => emitToggle(options, 'microphonetoggle', enabled),
      onCameraToggle: (enabled: boolean) => emitToggle(options, 'cameratoggle', enabled),
      onSpeakerToggle: (enabled: boolean) => emitToggle(options, 'speakertoggle', enabled),
      onSwitchCamera: () => emitAction(options, 'switchcamera'),
      onSwitchAudio: () => emitAction(options, 'switchaudio'),
      onSwitchVideo: () => emitAction(options, 'switchvideo'),
      onFloatingWindow: () => emitAction(options, 'floatingwindow')
    })
      .width('100%')
      .height('100%')

    if (options.callStatus === 'connected' && options.mediaType === 2) {
      NECallSmallVideoHitProxy({
        controller: options.controller,
        containerWidth: options.width,
        containerHeight: options.height,
        statusBarHeight: options.statusBarHeight
      })
    }
  }
  .position({
    x: options.x,
    y: options.y
  })
  .width(options.width)
  .height(options.height)
  .visibility(options.visibility)
}

let registered: boolean = false;

export function registerCallLayoutNativeEmbed(): void {
  if (registered) {
    return;
  }
  defineNativeEmbed('necall-page', {
    builder: CallLayoutNativeEmbedBuilder,
    controller: NECallLayoutEmbedController,
    nodeRenderType: NodeRenderType.RENDER_TYPE_DISPLAY
  });
  registered = true;
}
