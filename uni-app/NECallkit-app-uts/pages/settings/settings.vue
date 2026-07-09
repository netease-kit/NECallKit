<template>
  <view class="container">
    <scroll-view
      scroll-y="true"
      class="settings-scroll">
      <view class="settings-content">
        <view class="nav-row">
          <view class="nav-action" @click="handleCancle">
            取消
          </view>
          <view class="nav-title">
            设置
          </view>
          <view class="nav-action" @click="handleSetting">
            完成
          </view>
        </view>

        <view class="setting-row first-row">
          <label class="setting-label">设置呼叫超时时间（秒）：</label>
          <view class="input-box compact-input">
            <input class="input-timeout" v-model="timeout" maxlength="10" type="number" />
          </view>
        </view>
      
        <view class="setting-row">
          <label class="setting-label">自定义channelName：</label>
          <view class="input-box flex-input">
            <input class="setting-input" v-model="channelName" maxlength="50" type="text"/>
          </view>
        </view>
      
        <view class="setting-row column-row">
          <label class="setting-label">自定义RtcUid（重新登录生效）：</label>
          <view class="input-box full-input">
            <input class="setting-input" v-model="rtcUid" maxlength="20" type="number"/>
          </view>
        </view>

        <view class="switch-row">
          <label class="setting-label">开启来电横幅：</label>
          <switch :checked="enableIncomingBanner" @change="handleIncomingBannerChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">开启浮窗：</label>
          <switch :checked="enableFloatingWindow" @change="handleFloatingWindowChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">home展示浮窗：</label>
          <switch :checked="enableAutoFloatingWindowWhenHome" @change="handleAutoFloatingWindowWhenHomeChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">开启LiveCommunicationKit（重新登录生效）：</label>
          <switch :checked="liveCommunicationKitEnabled" @change="handleLiveCommunicationKitChange" color="#16C36A" />
        </view>

        <view class="setting-row column-row">
          <label class="setting-label">VoIP证书名（重新登录生效）：</label>
          <view class="input-box full-input">
            <input class="setting-input" v-model="voipCerName" maxlength="80" type="text" placeholder="PushKit/VoIP证书名" />
          </view>
        </view>

        <view class="setting-row column-row">
          <label class="setting-label">系统来电铃声文件名（重新登录生效）：</label>
          <picker
            class="input-box full-input"
            mode="selector"
            :range="liveCommunicationKitRingtoneOptions"
            range-key="label"
            :value="liveCommunicationKitRingtoneIndex"
            @change="handleLiveCommunicationKitRingtoneChange">
            <view class="picker-value">
              {{ liveCommunicationKitRingtoneOptions[liveCommunicationKitRingtoneIndex].label }}
            </view>
          </picker>
        </view>

        <view class="switch-row">
          <label class="setting-label">是否支持音频转视频：</label>
          <switch :checked="supportAudioToVideo" @change="handleSupportAudioToVideoChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">是否支持视频转音频：</label>
          <switch :checked="supportVideoToAudio" @change="handleSupportVideoToAudioChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">音频转视频是否需要确认：</label>
          <switch :checked="audioToVideoConfirm" @change="handleAudioToVideoConfirmChange" color="#16C36A" />
        </view>

        <view class="switch-row">
          <label class="setting-label">视频转音频是否需要确认：</label>
          <switch :checked="videoToAudioConfirm" @change="handleVideoToAudioConfirmChange" color="#16C36A" />
        </view>

        <view class="section-title">推送设置</view>

        <view class="switch-row">
          <label class="setting-label">启用推送：</label>
          <switch :checked="pushEnabled" @change="handlePushEnabledChange" color="#16C36A" />
        </view>

        <view class="setting-row">
          <label class="setting-label">推送标题：</label>
          <view class="input-box flex-input">
            <input class="setting-input" v-model="pushTitle" maxlength="50" type="text" placeholder="推送标题" />
          </view>
        </view>

        <view class="setting-row">
          <label class="setting-label">推送内容：</label>
          <view class="input-box flex-input">
            <input class="setting-input" v-model="pushContent" maxlength="80" type="text" placeholder="推送内容" />
          </view>
        </view>

        <view class="setting-row column-row">
          <label class="setting-label">推送Payload：</label>
          <view class="input-box full-input">
            <input class="setting-input" v-model="pushPayload" maxlength="200" type="text" placeholder='{"userID":"xxx"}' />
          </view>
        </view>

        <view class="switch-row">
          <label class="setting-label">计入角标：</label>
          <switch :checked="needBadge" @change="handleNeedBadgeChange" color="#16C36A" />
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script>
  const LIVE_COMMUNICATION_KIT_CONFIG_KEY = "NECallKit_UTS_LiveCommunicationKit_Config";
  const LIVE_COMMUNICATION_KIT_RINGTONE_OPTIONS = [
    { label: "默认铃声（lck_incoming_ring.mp3）", value: "lck_incoming_ring.mp3" },
    { label: "备用铃声（lck_incoming_ring_alt.mp3）", value: "lck_incoming_ring_alt.mp3" },
  ];
  const DEFAULT_LIVE_COMMUNICATION_KIT_RINGTONE_NAME =
    LIVE_COMMUNICATION_KIT_RINGTONE_OPTIONS[0].value;

  function getRingtoneIndex(ringtoneName) {
    const index = LIVE_COMMUNICATION_KIT_RINGTONE_OPTIONS.findIndex(
      (item) => item.value === ringtoneName
    );
    return index >= 0 ? index : 0;
  }

  export default {
    data() {
      const ringtoneIndex = getRingtoneIndex(getApp().globalData.liveCommunicationKitRingtoneName);
      return {
        timeout: getApp().globalData.timeout,
        channelName: getApp().globalData.channelName,
        rtcUid: getApp().globalData.rtcUid,
        enableIncomingBanner: getApp().globalData.enableIncomingBanner,
        enableFloatingWindow: getApp().globalData.enableFloatingWindow,
        enableAutoFloatingWindowWhenHome: getApp().globalData.enableAutoFloatingWindowWhenHome,
        liveCommunicationKitEnabled: getApp().globalData.liveCommunicationKitEnabled,
        voipCerName: getApp().globalData.voipCerName,
        liveCommunicationKitRingtoneOptions: LIVE_COMMUNICATION_KIT_RINGTONE_OPTIONS,
        liveCommunicationKitRingtoneIndex: ringtoneIndex,
        liveCommunicationKitRingtoneName:
          LIVE_COMMUNICATION_KIT_RINGTONE_OPTIONS[ringtoneIndex]?.value ||
          DEFAULT_LIVE_COMMUNICATION_KIT_RINGTONE_NAME,
        supportAudioToVideo: getApp().globalData.supportAudioToVideo,
        supportVideoToAudio: getApp().globalData.supportVideoToAudio,
        audioToVideoConfirm: getApp().globalData.audioToVideoConfirm,
        videoToAudioConfirm: getApp().globalData.videoToAudioConfirm,
        pushEnabled: getApp().globalData.pushEnabled,
        pushTitle: getApp().globalData.pushTitle,
        pushContent: getApp().globalData.pushContent,
        pushPayload: getApp().globalData.pushPayload,
        needBadge: getApp().globalData.needBadge
      };
    },
    computed: {
      isValidTimeout() {
        const num = Number(this.timeout);
        return !isNaN(num) && num > 0;
      }
    },
    methods: {
      handleCancle() {
        uni.navigateBack();
      },
      handleIncomingBannerChange(event) {
        this.enableIncomingBanner = event.detail.value;
      },
      handleFloatingWindowChange(event) {
        this.enableFloatingWindow = event.detail.value;
      },
      handleAutoFloatingWindowWhenHomeChange(event) {
        this.enableAutoFloatingWindowWhenHome = event.detail.value;
      },
      handleLiveCommunicationKitChange(event) {
        this.liveCommunicationKitEnabled = event.detail.value;
      },
      handleLiveCommunicationKitRingtoneChange(event) {
        const index = Number(event.detail.value);
        this.liveCommunicationKitRingtoneIndex = index;
        this.liveCommunicationKitRingtoneName =
          this.liveCommunicationKitRingtoneOptions[index]?.value ||
          DEFAULT_LIVE_COMMUNICATION_KIT_RINGTONE_NAME;
      },
      handleSupportAudioToVideoChange(event) {
        this.supportAudioToVideo = event.detail.value;
      },
      handleSupportVideoToAudioChange(event) {
        this.supportVideoToAudio = event.detail.value;
      },
      handleAudioToVideoConfirmChange(event) {
        this.audioToVideoConfirm = event.detail.value;
      },
      handleVideoToAudioConfirmChange(event) {
        this.videoToAudioConfirm = event.detail.value;
      },
      handlePushEnabledChange(event) {
        this.pushEnabled = event.detail.value;
      },
      handleNeedBadgeChange(event) {
        this.needBadge = event.detail.value;
      },
      handleSetting() {
        const needRelogin =
          this.rtcUid != getApp().globalData.rtcUid ||
          this.liveCommunicationKitEnabled != getApp().globalData.liveCommunicationKitEnabled ||
          this.voipCerName != getApp().globalData.voipCerName ||
          this.liveCommunicationKitRingtoneName != getApp().globalData.liveCommunicationKitRingtoneName;

        if (this.timeout != getApp().globalData.timeout) {
          if (this.isValidTimeout) {
            uni.$NECallKit.setTimeout(Number(this.timeout) * 1000);
            getApp().globalData.timeout = Number(this.timeout);
          } else {
            uni.showToast({
              title: "设置失败，超时时间必须大于0！",
              position: "bottom",
            });
            return;
          }
        }
        
        if (this.channelName !=  getApp().globalData.channelName) {
          getApp().globalData.channelName = this.channelName;
        }

        getApp().globalData.pushEnabled = this.pushEnabled;
        getApp().globalData.enableFloatingWindow = this.enableFloatingWindow;
        getApp().globalData.enableAutoFloatingWindowWhenHome =
          this.enableFloatingWindow && this.enableAutoFloatingWindowWhenHome;
        getApp().globalData.liveCommunicationKitEnabled = this.liveCommunicationKitEnabled;
        getApp().globalData.voipCerName = this.voipCerName;
        getApp().globalData.liveCommunicationKitRingtoneName = this.liveCommunicationKitRingtoneName;
        try {
          uni.setStorageSync(LIVE_COMMUNICATION_KIT_CONFIG_KEY, {
            enabled: this.liveCommunicationKitEnabled,
            voipCerName: this.voipCerName,
            ringtoneName: this.liveCommunicationKitRingtoneName,
          });
        } catch (error) {
          console.error("保存LiveCommunicationKit配置失败", error);
        }
        getApp().globalData.supportAudioToVideo = this.supportAudioToVideo;
        getApp().globalData.supportVideoToAudio = this.supportVideoToAudio;
        getApp().globalData.audioToVideoConfirm = this.audioToVideoConfirm;
        getApp().globalData.videoToAudioConfirm = this.videoToAudioConfirm;
        uni.$NECallKit.setSwitchCallTypeConfirm(this.audioToVideoConfirm, this.videoToAudioConfirm);
        uni.$NECallKit.setAutoFloatingWindowWhenHomeEnabled(
          getApp().globalData.enableAutoFloatingWindowWhenHome
        );
        getApp().globalData.pushTitle = this.pushTitle;
        getApp().globalData.pushContent = this.pushContent;
        getApp().globalData.pushPayload = this.pushPayload;
        getApp().globalData.needBadge = this.needBadge;
        
        if (needRelogin) {
          getApp().globalData.rtcUid = Number(this.rtcUid);
          getApp().globalData.enableIncomingBanner = this.enableIncomingBanner;
          uni.$NECallKit.enableIncomingBanner(this.enableIncomingBanner);
          uni.navigateBack();
          uni.showToast({
            title: "设置成功，需重新登录生效",
            position: "bottom",
          });
        } else {
          getApp().globalData.enableIncomingBanner = this.enableIncomingBanner;
          uni.$NECallKit.enableIncomingBanner(this.enableIncomingBanner);
          uni.navigateBack();
          uni.showToast({
            title: "设置成功",
            position: "bottom",
          });
        }
      },
    },
  };
</script>

<style scoped>
  .container {
    width: 100%;
    height: 100vh;
    overflow: hidden;
    margin: 0;
    padding-top: 40px;
    background-color: black;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }

  .settings-scroll {
    height: 100%;
    width: 100%;
    background-color: #1f1f26;
    box-sizing: border-box;
  }

  .settings-content {
    box-sizing: border-box;
    width: 100%;
    max-width: 100%;
    padding: 0 10px 24px;
    color: white;
    overflow: hidden;
  }

  .nav-row {
    width: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: row;
    padding: 10px 0;
    align-items: center;
    justify-content: space-between;
  }

  .nav-action {
    flex: none;
  }

  .nav-title {
    flex: 1;
    min-width: 0;
    text-align: center;
  }

  .section-title {
    padding: 24px 0 6px;
    color: rgba(255, 255, 255, 0.65);
    font-size: 14px;
  }

  .setting-row {
    box-sizing: border-box;
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    padding: 16px 0;
  }

  .first-row {
    margin-top: 20px;
  }

  .column-row {
    flex-direction: column;
    align-items: stretch;
  }

  .switch-row {
    box-sizing: border-box;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 0;
  }

  .setting-label {
    flex: 1;
    min-width: 0;
    font-size: 16px;
    line-height: 22px;
  }

  .input-box {
    box-sizing: border-box;
    height: 40px;
    background: #393945;
    border-radius: 10px;
    padding: 10px 15px;
    display: flex;
    align-items: center;
  }

  .compact-input {
    width: 100%;
    margin-top: 10px;
  }

  .flex-input {
    width: 100%;
    margin-top: 10px;
  }

  .full-input {
    width: 100%;
    margin-top: 10px;
  }

  .setting-input,
  .input-timeout,
  .picker-value {
    flex: 1;
    width: 100%;
    min-width: 0;
    box-sizing: border-box;
  }

  .picker-value {
    font-size: 16px;
    line-height: 20px;
    color: white;
  }

  .input-timeout[placeholder] {
    font-family: PingFangSC-Regular;
    font-size: 16px;
    color: #8a898e;
    letter-spacing: 0;
    font-weight: 400;
  }
</style>
