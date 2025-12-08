<template>
  <div class="btn" @tap="handleMic">
    <image class="btn-img" :style="[style]" :src="micSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("microphone") }}
    </text>
  </div>
</template>

<script setup lang="ts">
import { watch, ref, computed, onMounted } from "vue";
import {
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const";
import { t } from "../../callServices/locales";
import MIC_ON_SRC from "../assets/mic-on.png";
import MIC_OFF_SRC from "../assets/mic-off.png";
import MIC_ON_LARGE_SRC from "../assets/mic-on-large.png";
import MIC_OFF_LARGE_SRC from "../assets/mic-off-large.png";

const isOpenMic = ref(
  uni.$NEStore.getData(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN)
);
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

const micSrc = computed(() => {
  return !isOpenMic.value ? (props.size == 'small' ? MIC_OFF_SRC : MIC_OFF_LARGE_SRC) : (props.size == 'small' ? MIC_ON_SRC : MIC_ON_LARGE_SRC);
});

const handleMic = () => {
  if (isOpenMic.value) {
    uni.$NECallKit.closeMicrophone();
  } else {
    uni.$NECallKit.openMicrophone();
  }
  isOpenMic.value = !isOpenMic.value;
  uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN, isOpenMic.value);
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
