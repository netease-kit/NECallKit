<template>
  <div class="btn" @tap="handleCamera">
    <image class="btn-img" :src="imgSrc"></image>
    <text class="btn-text" v-if="isShowText">
      {{ isOpenCamera ? t("camera enabled") : t("camera disabled") }}
    </text>
  </div>
</template>

<script setup lang="ts">
import { computed, watch, ref, onMounted } from "vue";
import { t } from "../../callServices/locales";
import {
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const";
import CAMERA_ON_SRC from "../assets/camera-on.png";
import CAMERA_OFF_SRC from "../assets/camera-off.png";
import { MediaType } from "../../../utssdk/interface";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: false,
  },
  defaultOpen: {
    type: Boolean,
    default: true,
  },
});

const isOpenCamera = ref(
  uni.$NEStore.getData(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN)
);

const imgSrc = computed(() => {
  return !isOpenCamera.value ? CAMERA_OFF_SRC : CAMERA_ON_SRC;
});

const handleCamera = () => {
  if (isOpenCamera.value) {
    uni.$NECallKit.closeCamera();
  } else {
    uni.$NECallKit.openCamera();
  }
  isOpenCamera.value = !isOpenCamera.value;
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.IS_LOCAL_CAMERA_OPEN,
    isOpenCamera.value
  );
  uni.$NEStore.update(
    StoreName.CALL,
    NAME.CURRENT_CAMERA_IS_OPEN,
    isOpenCamera.value
  );
};

onMounted(() => {
  const savedCameraIsOpen = uni.$NEStore.getData(
    StoreName.CALL,
    NAME.CURRENT_CAMERA_IS_OPEN
  );
  const currentMediaType = uni.$NEStore.getData(
    StoreName.CALL,
    NAME.MEDIA_TYPE
  );
  if (currentMediaType === MediaType.Video) return;
  if (savedCameraIsOpen !== undefined) {
    isOpenCamera.value = savedCameraIsOpen;
  } else {
    isOpenCamera.value = false;
    uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN, false);
    uni.$NEStore.update(StoreName.CALL, NAME.CURRENT_CAMERA_IS_OPEN, false);
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
