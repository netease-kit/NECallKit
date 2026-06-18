<template>
  <view class="btn" @tap="handleSwitchVideo">
    <image class="btn-img" :style="[style]" :src="AUDIO_TO_VIDEO_SRC"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("switch video") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { t } from "../../callServices/locales";
import AUDIO_TO_VIDEO_SRC from "../assets/audio-to-video.png";

const props = defineProps({
  size: {
    type: Number,
    default: 24,
  },
  isShowText: {
    type: Boolean,
    default: false,
  },
});

const style = computed(() => ({
  width: props.size + "px",
  height: props.size + "px",
}));

const handleSwitchVideo = () => {
  uni.$NECallKit.switchAudioToVideo();
};
</script>

<style scoped>
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
