<template>
  <view class="btn" @tap="handleSwitchAudio">
    <image class="btn-img" :style="[style]" :src="VIDEO_TO_AUDIO_SRC"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("switch audio") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { t } from "../../callServices/locales";
import VIDEO_TO_AUDIO_SRC from "../assets/video-to-audio.png";

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

const handleSwitchAudio = () => {
  uni.$NECallKit.switchVideoToAudio();
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
