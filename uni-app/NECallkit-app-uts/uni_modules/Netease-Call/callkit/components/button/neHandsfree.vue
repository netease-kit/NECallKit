<template>
  <view class="btn" @tap="handleSwitchAudioPlay">
    <image class="btn-img" :style="[style]" :src="handsFreeSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("speaker") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from "vue";
import {
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const";
import { t } from "../../callServices/locales";
import HANDSFREE_ON_SRC from "../assets/handsfree-on.png";
import HANDSFREE_OFF_SRC from "../assets/handsfree-off.png";
import HANDSFREE_ON_LARGE_SRC from "../assets/handsfree-on-large.png";
import HANDSFREE_OFF_LARGE_SRC from "../assets/handsfree-off-large.png";
import { AudioPlaybackDevice, MediaType } from "../../../utssdk/interface";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: false,
  },
  size: {
    type: String,
    default: 'small',
  },
});

const style = computed(() => ({
  width: props.size == 'small' ? 24 : 75 + "px",
  height: props.size == 'small' ? 24 : 75 + "px",
}));

const isEarPhone = ref();


const handsFreeSrc = computed(() => {
  return isEarPhone.value ? (props.size == 'small' ? HANDSFREE_OFF_SRC : HANDSFREE_OFF_LARGE_SRC) : (props.size == 'small' ? HANDSFREE_ON_SRC : HANDSFREE_ON_LARGE_SRC);
});

const handleSwitchAudioPlay = () => {
  const targetAudioPlay = isEarPhone.value
    ? AudioPlaybackDevice.Speakerphone
    : AudioPlaybackDevice.Earpiece;
  uni.$NECallKit.selectAudioPlaybackDevice(targetAudioPlay == AudioPlaybackDevice.Speakerphone);
  isEarPhone.value = !isEarPhone.value;
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.IS_LOCAL_SPEAKER_OPEN,
    isEarPhone.value
  );
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS,
    targetAudioPlay
  );
};

onMounted(() => {
  const savedSpeakerStatus = uni.$NEStore.getData(
    StoreName.CALL,
    NAME.CURRENT_SPEAKER_STATUS
  );
  const currentType = uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);

  if (savedSpeakerStatus !== undefined) {
    isEarPhone.value = savedSpeakerStatus === AudioPlaybackDevice.Earpiece;
  } else {
    const targetAudioPlay = currentType === MediaType.Audio
      ? AudioPlaybackDevice.Earpiece
      : AudioPlaybackDevice.Speakerphone;
    uni.$NECallKit.selectAudioPlaybackDevice(targetAudioPlay == AudioPlaybackDevice.Speakerphone);
    
    isEarPhone.value = currentType === MediaType.Audio;
  }
});
</script>

<style>
.btn {
  margin: 0px 15px;
}

.btn-img {
  width: 24px;
  height: 24px;
}

.btn-text {
  font-size: 14px;
  color: #fff;
  font-weight: 400;
  text-align: center;
  margin-top: 10px;
}
</style>
