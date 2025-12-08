<template>
  <view class="button-panel-container" :style="{ width: viewWidth + 'px' }">
    <view
      class="button-group"
      v-if="callRole === CallRole.CALLER || callStatus === CallStatus.CONNECTED"
    >
        <view class="button-group-connected">
          <ne-microphone />
		  <ne-camera />
		  <hangup :size="32" :is-show-text="false" />
        </view>
    </view>
	
	<view
	  class="button-group"
	  v-if="callStatus === CallStatus.CALLING && callRole === CallRole.CALLEE"
	>
	  <view class="button-group-row">
	    <reject />
	    <accept :mediaType="mediaType" />
	  </view>
	</view>
  </view>
</template>

<script setup lang="ts">
import { onMounted, ref, toRefs, watch, defineProps } from "vue";
import {
  MediaType,
  CallStatus,
  CallRole,
} from "../../callServices/const/index";
import accept from "../button/accept.vue";
import hangup from "../button/hangup.vue";
import reject from "../button/reject.vue";
import neMicrophone from "../button/neMicrophone.vue";
import neHandsfree from "../button/neHandsfree.vue";
import neCamera from "../button/neCamera.vue";

const props = defineProps({
  callStatus: {
    type: CallStatus,
    default: CallStatus.IDLE,
  },
  mediaType: {
    type: MediaType,
    default: MediaType.UNKNOWN,
  },
  callRole: {
    type: CallRole,
    default: CallRole.UNKNOWN,
  },
});

const viewWidth = ref<number>(360);
const viewHeight = ref<number>(700);

onMounted(() => {
  viewWidth.value = uni.getWindowInfo().windowWidth;
  viewHeight.value = uni.getWindowInfo().windowHeight;
});
</script>

<style>
.button-panel-container {
  display: flex;
  justify-content: center;
}

.button-group {
  display: flex;
  flex-direction: column;
  justify-content: center;
  flex-wrap: wrap;
}

.button-group-row {
  display: flex;
  flex-direction: row;
  justify-content: space-around;
  align-items: center;
}

.button-group-connected {
  align-self: center;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  padding: 10px 15px;
  border-radius: 140px;
  background-color: rgba(0, 0, 0, 0.5);
}
</style>
