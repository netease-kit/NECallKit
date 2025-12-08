<template>
  <view class="container">
    <view style="flex:auto;display: flex;flex-direction: column;padding: 0 10px;background-color: #1f1f26;">
      <view
        style="display: flex;flex-direction: row;padding: 10px 0px;align-items: center;justify-content: space-between;color: white;">
        <view style="flex:none;" @click="handleCancle">
          取消
        </view>
        <view style="flex:auto;text-align: center;">
          一对一音视频通话
        </view>
        <view style="flex:none;" @click="handleSetting">
          <image style="width: 20px;height: 20px;flex: none;" src="../../static/setting.png"></image>
        </view>
      </view>

      <view style="display: flex;align-items: center;padding: 10px 0;color:rgba(255, 255, 255, 0.5);">
        <label>{{ "您的ID" }}</label>
        <view style="margin-left: 10px;">
          {{ user.userID }}
        </view>
      </view>

      <view class="search">
        <view class="input-box">
          <input class="input-search-user" v-model="invitee" maxlength="50" type="text" placeholder="请输入账号ID" />
        </view>
        <view class="btn-search" @click="call">{{ "呼叫" }}</view>
      </view>

      <view style="display: flex;flex-direction: row;align-items: center;color: white;padding: 10px 0;">
        <view>呼叫类型</view>
        <radio-group style="margin-left: 15px;display: flex;flex-direction: row;align-items: center;"
          @change="handleCallTypeChange">
          <label style="display: flex;flex-direction: row;align-items: center;">
            <view>
              <radio :value="MediaType.VIDEO" :checked="callType === MediaType.VIDEO " />
            </view>
            <view>视频呼叫</view>
          </label>
          <label style="margin-left: 15px;display: flex;flex-direction: row;align-items: center;">
            <view>
              <radio :value="MediaType.AUDIO" :checked="callType === MediaType.AUDIO " />
            </view>
            <view>音频呼叫</view>
          </label>
        </radio-group>
      </view>

      <view style="display: flex;flex-direction: column;margin-top: 25px;color: white;flex: auto;">
        <view>通话记录</view>
        <scroll-view scroll-y="true" style="display: flex;flex-direction: column;height: 500rpx;padding: 10px 0;">
          <view
            style="display: flex;flex-direction: row;align-items: center;justify-content: space-between;padding-bottom: 10px;"
            v-for="(item, index) in message.messages" :key="index" :id="index" @click="quickCall">
            <view style="display: flex;flex-direction: row;align-items: center;">
              <image v-if="item.attachment.status == 1 && !item.isSelf && item.attachment.type == 1" class="order-icon"
                src="../../static/audio_in_normal.png"></image>
              <image v-if="item.attachment.status == 1 && !item.isSelf && item.attachment.type == 2" class="order-icon"
                src="../../static/video_in_normal.png"></image>
              <image v-if="item.attachment.status == 1 && item.isSelf && item.attachment.type == 1" class="order-icon"
                src="../../static/audio_out_normal.png"></image>
              <image v-if="item.attachment.status == 1 && item.isSelf && item.attachment.type == 2" class="order-icon"
                src="../../static/video_out_normal.png"></image>
              <image v-if="item.attachment.status != 1 && !item.isSelf && item.attachment.type == 1" class="order-icon"
                src="../../static/audio_in_failed.png"></image>
              <image v-if="item.attachment.status != 1 && !item.isSelf && item.attachment.type == 2" class="order-icon"
                src="../../static/video_in_failed.png"></image>
              <image v-if="item.attachment.status != 1 && item.isSelf && item.attachment.type == 1" class="order-icon"
                src="../../static/audio_out_failed.png"></image>
              <image v-if="item.attachment.status != 1 && item.isSelf && item.attachment.type == 2" class="order-icon"
                src="../../static/video_out_failed.png"></image>
              <view style="margin-left: 10px;font-size: 14px;"
                :style="{color: item.attachment.status == 1 ? 'white' : '#FF5D54'}">
                {{ item.isSelf ? item.receiverId : item.senderId }}
              </view>
            </view>
            <view
              style="display: flex;flex-direction: row;align-items: center;color: rgba(255, 255, 255, 0.7);font-size: 12px;">
              <view :style="{color: item.attachment.status != 1 ? '#FF5D54' : 'rgba(255, 255, 255, 0.7)'}">
                {{ timestampToTime(item.createTime - 1000 * (item.attachment?.durations[0]?.duration ?? 0)) }}
              </view>
              <view v-if="item.attachment.status == 1" style="margin-left: 10px;">
                {{ secToTime(item.attachment?.durations[0]?.duration) }}
              </view>
            </view>
          </view>
        </scroll-view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from "vue";
import { MediaType, CallStatus, NAME, StoreName } from "@/uni_modules/Netease-Call/callkit/callServices/const/index";
import { secToTime } from "@/utils/index.js";
import { useUserStore } from "@/stores/user";
import { useMessageStore } from "@/stores/message";

const user = useUserStore();
const message = useMessageStore();

const invitee = ref("");
const callType = ref(MediaType.VIDEO);

const handleCancle = () => {
  uni.navigateBack();
};

const handleSetting = () => {
  uni.navigateTo({
    url: "/pages/settings/settings",
  });
};

const handleCallTypeChange = (e) => {
  callType.value = e.detail.value;
};

const isCalling = () => {
  return uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS) != CallStatus.IDLE;
}

const call = () => {
  if (isCalling()) {
    uni.showToast({
      title: "正在通话中",
      position: "bottom",
    });
    return;
  }
  if (!invitee.value) {
    uni.showToast({
      title: "请输入账号ID",
      position: "bottom",
    });
    return;
  }
  if (user.userID === invitee.value) {
    uni.showToast({
      title: "不能呼叫自己",
      position: "bottom",
    });
    return;
  }
  try {
    uni.$NECallKit.call({
      accountId: invitee.value.trim(),
      callType: callType.value,
      params: {
        rtcChannelName: getApp().globalData.channelName,
      },
    });
  } catch (error) {
    console.error("call error: ", error);
  }
};

const quickCall = (e) => {
  if (isCalling()) {
    uni.showToast({
      title: "正在通话中",
      position: "bottom",
    });
    return;
  }
  const item = message.messages[e.currentTarget.id];
  try {
    uni.$NECallKit.call({
      accountId: item.isSelf ? item.receiverId : item.senderId,
      callType: item.attachment.type,
      params: {
        rtcChannelName: getApp().globalData.channelName,
      },
    });
  } catch (error) {
    console.error("call error: ", error);
  }
};

const timestampToTime = (timestamp) => {
  const date = new Date(timestamp);
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const seconds = date.getSeconds().toString().padStart(2, "0");
  return `${hours}:${minutes}:${seconds}`;
};
</script>

<style scoped>
  .container {
    width: 100vw;
    height: 100vh;
    overflow: hidden;
    margin: 0;
    padding-top: 40px;
    background-color: black;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }

  .search {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-sizing: border-box;
    padding: 20px 0;
  }

  .btn-search {
    text-align: center;
    width: 60px;
    height: 40px;
    line-height: 40px;
    background: #337eff;
    border-radius: 10px;
    color: white;
  }

  .input-box {
    flex: 1;
    box-sizing: border-box;
    margin-right: 20px;
    height: 40px;
    background: #f4f5f9;
    color: #666666;
    border-radius: 10px;
    padding: 9px 16px;
    display: flex;
    align-items: center;
  }

  .input-search-user {
    flex: 1;
    box-sizing: border-box;
  }

  .input-search-user[placeholder] {
    font-family: PingFangSC-Regular;
    font-size: 16px;
    color: #8a898e;
    letter-spacing: 0;
    font-weight: 400;
  }

  .order-icon {
    width: 20px;
    height: 20px;
    flex: none;
  }
</style>