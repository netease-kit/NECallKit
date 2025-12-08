<template>
  <view class="btn" @tap="handleAccept">
    <image class="btn-img" :src="imgSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("accept") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import {
  MediaType,
} from "../../callServices/const/index";
import { t } from "../../callServices/locales";
import ACCEPT_AUDIO_SRC from "../assets/accept-audio.png";
import ACCEPT_VIDEO_SRC from "../assets/accept-video.png";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: true,
  },
  mediaType: {
    type: MediaType,
    default: MediaType.UNKNOWN,
  },
});

const imgSrc = computed(() => {
  if (props.mediaType === MediaType.AUDIO) {
    return ACCEPT_AUDIO_SRC;
  }
  if (props.mediaType === MediaType.VIDEO) {
    return ACCEPT_VIDEO_SRC;
  }
  return ACCEPT_AUDIO_SRC;
});

const handleAccept = () => {
  uni.$NECallKit.accept();
};
</script>

<style scoped>
.btn-img {
  width: 75px;
  height: 75px;
  border-radius: 140px;
}

.btn-text {
  font-size: 14px;
  color: #fff;
  font-weight: 400;
  text-align: center;
  margin-top: 10px;
}
</style>
