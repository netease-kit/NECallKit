<template>
  <view class="btn" @tap="handleBlur">
    <image class="btn-img" :style="[style]" :src="blurSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("virtual-background") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { t } from "../../callServices/locales";
import BLUR_ON_SRC from "../assets/blur-on.png";
import BLUR_OFF_SRC from "../assets/blur-off.png";
import { StoreName, NAME } from "../../callServices/const";

const isBlur = ref<boolean>(
  uni.$NEStore.getData(StoreName.CALL, NAME.IS_LOCAL_BLUR_OPEN)
);

const blurSrc = computed(() => {
  return isBlur.value ? BLUR_ON_SRC : BLUR_OFF_SRC;
});

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

const handleBlur = () => {
  if (isBlur.value) {
    uni.$NECallKit.setBlurBackground(0);
  } else {
    uni.$NECallKit.setBlurBackground(3);
  }
  isBlur.value = !isBlur.value;
  uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_BLUR_OPEN, isBlur.value);
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
