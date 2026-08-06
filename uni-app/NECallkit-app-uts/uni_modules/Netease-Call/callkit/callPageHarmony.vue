<template>
  <view :style="callKitStyle" class="call-kit">
    <call-view
      :style="callViewStyle"
      :call-status="callStatus"
      :call-role="callRole"
      :media-type="mediaType"
      :call-duration="callDuration"
      :status-bar-height="statusBarHeight"
      :is-group-call="isGroupCall"
      :is-local-mic-open="isLocalMicOpen"
      :is-local-camera-open="isLocalCameraOpen"
      :is-speakerphone-on="isSpeakerphoneOn"
      :enable-floating-window="enableFloatingWindow"
      :support-audio-to-video="supportAudioToVideo"
      :support-video-to-audio="supportVideoToAudio"
      :microphone-text="t('microphone')"
      :speaker-text="t('speaker')"
      :hangup-text="t('hangup')"
      :accept-text="t('accept')"
      :reject-text="t('reject')"
      @accept="handleAccept"
      @reject="handleHangup"
      @hangup="handleHangup"
      @microphonetoggle="handleMicrophoneToggle"
      @cameratoggle="handleCameraToggle"
      @speakertoggle="handleSpeakerToggle"
      @switchcamera="handleSwitchCamera"
      @switchaudio="handleSwitchAudio"
      @switchvideo="handleSwitchVideo"
      @floatingwindow="handleFloatingWindow"
    />
  </view>
</template>

<script setup lang="ts">
import { onBackPress, onShow } from '@dcloudio/uni-app';
import { computed, onMounted, onUnmounted, ref } from 'vue';
import {
  AudioPlaybackDevice,
  CallRole,
  CallStatus,
  MediaType,
  NAME,
  StoreName,
} from './callServices/const';
import { t } from './callServices/locales';

const windowInfo = uni.getWindowInfo();
const viewWidth = ref<number>(windowInfo.windowWidth);
const viewHeight = ref<number>(windowInfo.windowHeight);
const statusBarHeight = ref<number>(windowInfo.statusBarHeight);
const callStatus = ref<CallStatus>(uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS));
const callRole = ref<CallRole>(uni.$NEStore.getData(StoreName.CALL, NAME.CALL_ROLE));
const mediaType = ref<MediaType>(uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE));
const isGroupCall = ref<boolean>(uni.$NEStore.getData(StoreName.CALL, NAME.IS_GROUP_CALL));
const callDuration = ref<string>(
  uni.$NEStore.getData(StoreName.CALL, NAME.CALL_DURATION) ?? '00:00'
);
const isLocalMicOpen = ref<boolean>(
  uni.$NEStore.getData(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN) !== false
);
const isLocalCameraOpen = ref<boolean>(
  uni.$NEStore.getData(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN) !== false
);
const isSpeakerphoneOn = ref<boolean>(
  uni.$NEStore.getData(StoreName.CALL, NAME.CURRENT_SPEAKER_STATUS) ===
    AudioPlaybackDevice.Speakerphone
);
const enableFloatingWindow = ref<boolean>(getApp().globalData?.enableFloatingWindow !== false);
const supportAudioToVideo = ref<boolean>(getApp().globalData?.supportAudioToVideo !== false);
const supportVideoToAudio = ref<boolean>(getApp().globalData?.supportVideoToAudio !== false);
const isFrontCamera = ref<boolean>(true);
let isSystemBackHandling = false;

const watchOptions = {
  [NAME.CALL_STATUS]: (value: CallStatus) => {
    callStatus.value = value;
  },
  [NAME.CALL_ROLE]: (value: CallRole) => {
    callRole.value = value;
  },
  [NAME.MEDIA_TYPE]: (value: MediaType) => {
    mediaType.value = value;
  },
  [NAME.IS_GROUP_CALL]: (value: boolean) => {
    isGroupCall.value = value;
  },
  [NAME.CALL_DURATION]: (value: string) => {
    callDuration.value = value;
  },
  [NAME.IS_LOCAL_MIC_OPEN]: (value: boolean) => {
    isLocalMicOpen.value = value;
  },
  [NAME.IS_LOCAL_CAMERA_OPEN]: (value: boolean) => {
    isLocalCameraOpen.value = value;
  },
  [NAME.CURRENT_SPEAKER_STATUS]: (value: AudioPlaybackDevice) => {
    isSpeakerphoneOn.value = value === AudioPlaybackDevice.Speakerphone;
  },
};

const callViewStyle = computed(() => {
  return {
    width: viewWidth.value + 'px',
    height: viewHeight.value + 'px',
  };
});

const callKitStyle = computed(() => ({
  width: viewWidth.value + 'px',
  height: viewHeight.value + 'px',
}));

const updateWindowSize = (width: number, height: number) => {
  if (width > 0) {
    viewWidth.value = width;
  }
  if (height > 0) {
    viewHeight.value = height;
  }
};

const handleWindowResize = (_event: any) => {
  const currentWindowInfo = uni.getWindowInfo();
  updateWindowSize(currentWindowInfo.windowWidth, currentWindowInfo.windowHeight);
  statusBarHeight.value = currentWindowInfo.statusBarHeight;
};

const initializeAudioPlaybackDevice = () => {
  const savedSpeakerStatus = uni.$NEStore.getData(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS
  );
  if (savedSpeakerStatus !== undefined) {
    isSpeakerphoneOn.value = savedSpeakerStatus === AudioPlaybackDevice.Speakerphone;
    return;
  }

  const enableSpeakerphone = mediaType.value === MediaType.VIDEO;
  uni.$NECallKit.selectAudioPlaybackDevice(enableSpeakerphone);
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS,
    enableSpeakerphone ? AudioPlaybackDevice.Speakerphone : AudioPlaybackDevice.Earpiece
  );
  isSpeakerphoneOn.value = enableSpeakerphone;
};

onShow(() => {
  const callEngine = uni.$NECallKit.getNECallEngineInstance();
  if (
    callStatus.value === CallStatus.CONNECTED &&
    mediaType.value === MediaType.VIDEO &&
    !callEngine.isFloatWindowVisible()
  ) {
    callEngine.refreshCallLayoutVideoViews();
  }
});

onBackPress((options) => {
  if (options?.from !== 'backbutton') {
    return false;
  }
  if (callStatus.value === CallStatus.IDLE) {
    return false;
  }
  if (!isSystemBackHandling) {
    isSystemBackHandling = true;
    uni.$NECallKit.hangup();
  }
  return true;
});

onMounted(() => {
  uni.onWindowResize(handleWindowResize);
  uni.$NECallKit.setCallPageFullScreen(true);
  const currentWindowInfo = uni.getWindowInfo();
  updateWindowSize(currentWindowInfo.windowWidth, currentWindowInfo.windowHeight);
  statusBarHeight.value = currentWindowInfo.statusBarHeight;
  initializeAudioPlaybackDevice();
  uni.$NEStore.watch(StoreName.CALL, watchOptions);
});

const handleAccept = () => {
  uni.$NECallKit.accept();
};

const handleHangup = () => {
  uni.$NECallKit.hangup();
};

const readEnabled = (event: any): boolean => Boolean(event?.detail?.enabled);

const handleMicrophoneToggle = (event: any) => {
  const enabled = readEnabled(event);
  enabled ? uni.$NECallKit.openMicrophone() : uni.$NECallKit.closeMicrophone();
  uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN, enabled);
};

const handleCameraToggle = (event: any) => {
  const enabled = readEnabled(event);
  enabled ? uni.$NECallKit.openCamera() : uni.$NECallKit.closeCamera();
  uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN, enabled);
  uni.$NEStore.update(StoreName.CALL, NAME.CURRENT_CAMERA_IS_OPEN, enabled);
};

const handleSpeakerToggle = (event: any) => {
  const enabled = readEnabled(event);
  uni.$NECallKit.selectAudioPlaybackDevice(enabled);
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS,
    enabled ? AudioPlaybackDevice.Speakerphone : AudioPlaybackDevice.Earpiece
  );
};

const handleSwitchCamera = () => {
  uni.$NECallKit.switchCamera(isFrontCamera.value ? 1 : 0);
  isFrontCamera.value = !isFrontCamera.value;
};

const handleSwitchAudio = () => {
  uni.$NECallKit.switchVideoToAudio();
};

const handleSwitchVideo = () => {
  uni.$NECallKit.switchAudioToVideo();
};

const handleFloatingWindow = () => {
  uni.$NECallKit.startFloatWindow();
};

onUnmounted(() => {
  uni.$NECallKit.setCallPageFullScreen(false);
  const enableFloatWindow = uni.$NEStore.getData(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW);
  if (
    !isSystemBackHandling &&
    callStatus.value !== CallStatus.IDLE &&
    !enableFloatWindow
  ) {
    uni.$NECallKit.handleExceptionExit();
  }
  uni.offWindowResize(handleWindowResize);
  uni.$NEStore.unwatch(StoreName.CALL, watchOptions);
});
</script>

<style scoped>
.call-kit {
  position: relative;
  overflow: hidden;
  background-color: transparent;
}
</style>
