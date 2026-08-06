const CALL_STATUS_CALLING: string = 'calling';
const CALL_STATUS_CONNECTED: string = 'connected';
const CALL_ROLE_CALLEE: string = 'callee';
const MEDIA_TYPE_AUDIO: number = 1;
const MEDIA_TYPE_VIDEO: number = 2;

@Component
export struct NECallControls {
  @Prop callStatus: string = 'idle';
  @Prop callRole: string = 'unknown';
  @Prop mediaType: number = 0;
  @Prop callDuration: string = '00:00';
  @Prop isGroupCall: boolean = false;
  @Prop @Watch('syncLocalMicOpen') isLocalMicOpen: boolean = true;
  @Prop @Watch('syncLocalCameraOpen') isLocalCameraOpen: boolean = true;
  @Prop @Watch('syncSpeakerphoneOn') isSpeakerphoneOn: boolean = false;
  @Prop enableFloatingWindow: boolean = true;
  @Prop supportAudioToVideo: boolean = true;
  @Prop supportVideoToAudio: boolean = true;
  @Prop microphoneText: string = '';
  @Prop speakerText: string = '';
  @Prop hangupText: string = '';
  @Prop acceptText: string = '';
  @Prop rejectText: string = '';

  @State localMicOpen: boolean = true;
  @State localCameraOpen: boolean = true;
  @State speakerphoneOn: boolean = false;

  onAccept: () => void = () => {};
  onReject: () => void = () => {};
  onHangup: () => void = () => {};
  onMicrophoneToggle: (enabled: boolean) => void = () => {};
  onCameraToggle: (enabled: boolean) => void = () => {};
  onSpeakerToggle: (enabled: boolean) => void = () => {};
  onSwitchCamera: () => void = () => {};
  onSwitchAudio: () => void = () => {};
  onSwitchVideo: () => void = () => {};
  onFloatingWindow: () => void = () => {};

  aboutToAppear(): void {
    this.syncLocalMicOpen();
    this.syncLocalCameraOpen();
    this.syncSpeakerphoneOn();
  }

  private syncLocalMicOpen(): void {
    this.localMicOpen = this.isLocalMicOpen;
  }

  private syncLocalCameraOpen(): void {
    this.localCameraOpen = this.isLocalCameraOpen;
  }

  private syncSpeakerphoneOn(): void {
    this.speakerphoneOn = this.isSpeakerphoneOn;
  }

  private toggleMicrophone(): void {
    const enabled = !this.localMicOpen;
    this.localMicOpen = enabled;
    console.log(`[NECallControls] microphone enabled=${enabled}`);
    this.onMicrophoneToggle(enabled);
  }

  private toggleCamera(): void {
    const enabled = !this.localCameraOpen;
    this.localCameraOpen = enabled;
    console.log(`[NECallControls] camera enabled=${enabled}`);
    this.onCameraToggle(enabled);
  }

  private toggleSpeaker(): void {
    const enabled = !this.speakerphoneOn;
    this.speakerphoneOn = enabled;
    console.log(`[NECallControls] speakerphone enabled=${enabled}`);
    this.onSpeakerToggle(enabled);
  }

  build() {
    Stack() {
      this.TopControls()
      this.BottomControls()
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  TopControls() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.callStatus === CALL_STATUS_CONNECTED) {
        Stack({ alignContent: Alignment.Center }) {
          Text(this.callDuration)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#D5E0F2')

          Row() {
            if (this.enableFloatingWindow) {
              this.TopIcon($r('app.media.necall_float_window'), this.onFloatingWindow)
            }

            if (this.mediaType === MEDIA_TYPE_VIDEO) {
              this.TopIcon($r('app.media.necall_switch_camera'), this.onSwitchCamera)
            }
          }
          .width('100%')
        }
        .width('100%')
        .height(56)
        .hitTestBehavior(HitTestMode.Transparent)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10, top: 40 })
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  TopIcon(icon: Resource, action: () => void) {
    Column() {
      Image(icon)
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
    }
    .width(50)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(action)
  }

  @Builder
  BottomControls() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.isGroupCall && this.callStatus === CALL_STATUS_CONNECTED) {
          this.CompactPanel(true)
        } else if (this.callStatus === CALL_STATUS_CALLING && this.callRole === CALL_ROLE_CALLEE) {
          this.IncomingActions()
        } else if (this.callStatus === CALL_STATUS_CALLING) {
          this.OutgoingActions()
        } else if (this.callStatus === CALL_STATUS_CONNECTED) {
          this.CompactPanel(false)
        }
      }
      .width('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 60 })
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  IncomingActions() {
    Row() {
      this.LargeButton($r('app.media.necall_hangup'), this.rejectText, 105, this.onReject)
      this.LargeButton(
        this.mediaType === MEDIA_TYPE_VIDEO
          ? $r('app.media.necall_accept_video')
          : $r('app.media.necall_accept_audio'),
        this.acceptText,
        105,
        this.onAccept
      )
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  OutgoingActions() {
    if (this.mediaType === MEDIA_TYPE_AUDIO) {
      Row() {
        if (this.localMicOpen) {
          this.LargeButton(
            $r('app.media.necall_mic_on_large'),
            this.microphoneText,
            105,
            () => this.toggleMicrophone()
          )
        } else {
          this.LargeButton(
            $r('app.media.necall_mic_off_large'),
            this.microphoneText,
            105,
            () => this.toggleMicrophone()
          )
        }
        this.LargeButton($r('app.media.necall_hangup'), this.hangupText, 105, this.onHangup)
        if (this.speakerphoneOn) {
          this.LargeButton(
            $r('app.media.necall_handsfree_on_large'),
            this.speakerText,
            105,
            () => this.toggleSpeaker()
          )
        } else {
          this.LargeButton(
            $r('app.media.necall_handsfree_off_large'),
            this.speakerText,
            105,
            () => this.toggleSpeaker()
          )
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      Row() {
        this.LargeButton($r('app.media.necall_hangup'), this.hangupText, 105, this.onHangup)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  CompactPanel(groupCall: boolean) {
    Row() {
      if (this.localMicOpen) {
        this.CompactButton(
          $r('app.media.necall_mic_on'),
          24,
          () => this.toggleMicrophone()
        )
      } else {
        this.CompactButton(
          $r('app.media.necall_mic_off'),
          24,
          () => this.toggleMicrophone()
        )
      }

      if (this.mediaType === MEDIA_TYPE_VIDEO || groupCall) {
        if (this.localCameraOpen) {
          this.CompactButton(
            $r('app.media.necall_camera_on'),
            24,
            () => this.toggleCamera()
          )
        } else {
          this.CompactButton(
            $r('app.media.necall_camera_off'),
            24,
            () => this.toggleCamera()
          )
        }
      }

      if (this.speakerphoneOn) {
        this.CompactButton(
          $r('app.media.necall_handsfree_on'),
          24,
          () => this.toggleSpeaker()
        )
      } else {
        this.CompactButton(
          $r('app.media.necall_handsfree_off'),
          24,
          () => this.toggleSpeaker()
        )
      }

      if (!groupCall && this.mediaType === MEDIA_TYPE_AUDIO && this.supportAudioToVideo) {
        this.CompactButton($r('app.media.necall_audio_to_video'), 24, this.onSwitchVideo)
      }
      if (!groupCall && this.mediaType === MEDIA_TYPE_VIDEO && this.supportVideoToAudio) {
        this.CompactButton($r('app.media.necall_video_to_audio'), 24, this.onSwitchAudio)
      }

      this.CompactButton($r('app.media.necall_hangup'), 32, this.onHangup)
    }
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .borderRadius(48)
    .backgroundColor(
      this.mediaType === MEDIA_TYPE_AUDIO
        ? 'rgba(255, 255, 255, 0.1)'
        : 'rgba(0, 0, 0, 0.5)'
    )
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  CompactButton(icon: Resource, size: number, action: () => void) {
    Column() {
      Image(icon)
        .width(size)
        .height(size)
        .objectFit(ImageFit.Contain)
    }
    .width(size === 32 ? 62 : 54)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(action)
  }

  @Builder
  LargeButton(icon: Resource, label: string, width: number, action: () => void) {
    Column() {
      Image(icon)
        .width(75)
        .height(75)
        .objectFit(ImageFit.Contain)
      if (label.length > 0) {
        Text(label)
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 10 })
      }
    }
    .width(width)
    .alignItems(HorizontalAlign.Center)
    .hitTestBehavior(HitTestMode.Block)
    .onClick(action)
  }
}
