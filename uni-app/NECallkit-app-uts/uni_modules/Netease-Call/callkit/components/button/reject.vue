<template>
  <view class="btn" @tap="handleReject">
    <image class="btn-img" :src="REJECT_SRC"></image>
    <text class="btn-text" v-if="isShowText">
      {{ t("reject") }}
    </text>
  </view>
</template>

<script setup lang="ts">
import { t } from "../../callServices/locales";
import REJECT_SRC from "../assets/hangup.png";

const props = defineProps({
  isShowText: {
    type: Boolean,
    default: true,
  },
});

const handleReject = () => {
  uni.$NECallKit.hangup();
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
