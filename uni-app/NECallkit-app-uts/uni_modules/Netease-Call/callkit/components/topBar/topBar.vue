<template>
  <view class="top-bar">
    <view class="top-bar-time">
      <timer></timer>
    </view>
    <template v-if="!isGroupCall">
<!--      <view class="button-group-row" v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLER">
        <float-window />
      </view> -->
      <view class="button-group-row" v-if="callStatus === CallStatus.CONNECTED">
        <float-window v-if="enableFloatingWindow"></float-window>
        <switch-camera v-if="mediaType === MediaType.VIDEO" />
      </view>
    </template>
    <template v-if="isGroupCall">
      <view class="button-group-row">
        <switch-camera />
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
  import { onMounted, ref } from "vue";
  import {
    MediaType,
    CallStatus,
    CallRole,
  } from "../../callServices/const/index";
  import timer from "../timer/timer.vue";
  import floatWindow from "../button/floatWindow.vue";
  import switchCamera from "../button/switchCamera.vue";

  const props = defineProps({
    mediaType: {
      type: MediaType,
      default: MediaType.UNKNOWN,
    },
    callStatus: {
      type: CallStatus,
      default: CallStatus.IDLE,
    },
    callRole: {
      type: CallRole,
      default: CallRole.UNKNOWN,
    },
    isGroupCall: {
      type: Boolean,
      default: false,
    },
  });

  const enableFloatingWindow = ref<boolean>(true);

  onMounted(() => {
    enableFloatingWindow.value = getApp().globalData?.enableFloatingWindow !== false;
  });
</script>

<style scoped>
  .top-bar {
    position: absolute;
    left: 0;
    right: 0;
    top: 40px;
    height: 100rpx;
    flex-direction: row;
    align-items: center;
    display: flex;
  }

  .button-group-row {
    margin-left: 0;
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0 10px;
  }

  .top-bar-time {
    position: absolute;
    left: 0;
    right: 0;
    display: flex;
    flex-direction: row;
    justify-content: center;
  }
</style>
