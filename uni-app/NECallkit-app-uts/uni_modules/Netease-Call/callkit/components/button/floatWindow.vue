<template>
  <view class="btn" @tap="startFloatWindow">
    <image class="btn-img" :src="FLOAT_WINDOW_SRC"></image>
  </view>
</template>

<script setup lang="ts">
import FLOAT_WINDOW_SRC from "../assets/float-window.png";

const startFloatWindow = () => {
  uni.$NECallKit.startFloatWindow();
};
</script>

<style scoped>
.btn {
  margin: 0px 5px;
}

.btn-img {
  width: 40px;
  height: 40px;
  border-radius: 140px;
}
</style>
