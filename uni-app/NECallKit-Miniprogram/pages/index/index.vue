<template>
  <view class="container-box">
    <!-- uni-app 中不支持 style 属性中使用动态表达式 -->
    <!-- 需要通过计算属性或 data 传递 -->
    <view class='title' :style="{'padding-top': titlePaddingTop + 'px'}">
      <view>呼叫</view>
    </view>
    <view class="input-wrapper">
      <!-- uni-app 中使用 v-model 双向绑定 -->
      <input 
        type="text" 
        v-model="imAccid" 
        placeholder="输入对方账号" 
      />
    </view>
    <view class="sub-title">
      <!-- uni-app 中使用 radio-group -->
      <radio-group @change="changeCallType" class="radio-group-no-box">
        <label 
          v-for="(item, index) in callTypeArr" 
          :key="index" 
          class="radio-item" 
          :class="{ selected: callType == item.value }"
        >
          <radio :value="item.value" :checked="item.checked" />
          {{ item.title }}
        </label>
      </radio-group>
    </view>
    <view class='bottom-btn'>
      <!-- uni-app 中使用 @tap 代替 bindtap -->
      <button class="btn" @tap="startCall" :hover-class="'none'">发起呼叫</button>
    </view>
  </view>
</template>

<script lang="ts">
// 导入类型定义
// 注意：需要确保 SignalControllerCallType 类型在 uni-app 中可用
// 如果 @xkit-yx/call-kit 不兼容 uni-app，可能需要调整
type SignalControllerCallType = "1" | "2";

interface ICallTypeItem {
  value: SignalControllerCallType;
  title: string;
  checked?: boolean;
}

// 在 uni-app 中，我们使用 Vue 组件的方式
export default {
  data() {
    return {
      // uni-app 中可能需要通过 uni.getSystemInfoSync() 获取状态栏高度
      headerHeight: 0,
      statusBarHeight: 0,
      callType: "1" as SignalControllerCallType,
      imAccid: "",
      callTypeArr: [
        { value: "1", title: "语音通话" },
        { value: "2", title: "视频通话" },
      ] as ICallTypeItem[],
    };
  },
  
  computed: {
    // 计算标题的 padding-top
    titlePaddingTop(): number {
      // 计算逻辑可能需要根据 uni-app 的实际情况调整
      const totalHeight = this.headerHeight + this.statusBarHeight;
      return (totalHeight / 2) - 12;
    }
  },
  
  onLoad() {
    // uni-app 生命周期函数
    this.getSystemInfo();
  },
  
  methods: {
    // 获取系统信息
    getSystemInfo() {
      // uni-app 获取系统信息的方式
      const systemInfo = uni.getSystemInfoSync();
      // 注意：uni-app 中获取状态栏和导航栏高度的方式可能不同
      // 微信小程序中通常在 app.onLaunch 中获取
      
      // 假设这些值已经存储在全局变量中
      // 实际项目中需要根据 uni-app 的全局变量获取方式调整
      const app = getApp();
      if (app.globalData) {
        this.headerHeight = app.globalData.headerHeight || 44;
        this.statusBarHeight = app.globalData.statusBarHeight || 20;
      }
    },
    
    // 改变呼叫类型
    changeCallType(e: any) {
      // uni-app 中事件对象的 detail 结构与微信小程序相同
      this.callType = e.detail.value as SignalControllerCallType;
    },
    
    // 开始呼叫
    async startCall() {
      if (!this.imAccid.trim()) {
        uni.showToast({
          title: '请输入对方账号',
          icon: 'none'
        });
        return;
      }
      
      try {
        // 获取全局的 neCall 实例
        const app = getApp<{ globalData: { neCall?: any } }>();
        
        if (app.globalData.neCall) {
          await app.globalData.neCall.call({
            callType: this.callType,
            accId: this.imAccid,
          });
          
          // uni-app 中的页面跳转
          uni.navigateTo({
            url: '/pages/call/call'
          });
        } else {
          uni.showToast({
            title: '呼叫功能未初始化',
            icon: 'none'
          });
        }
      } catch (err: any) {
        console.error('呼叫失败:', err);
        uni.showToast({
          title: err.message || '呼叫失败',
          icon: 'none'
        });
      }
    }
  }
};
</script>

<style scoped>
.container-box {
  background-image: url(https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2Fgroupcall%2Fbg.png);
  background-color: #333;
  background-repeat:no-repeat;
  background-size: cover;
  background-color: #1a1a23;
  height: 100vh;
  padding: 0 40rpx;
  box-sizing: border-box;
  color: #fff;
}

.switch-item {
  margin: 10px 0;
}

.title {
  color: #FFFFFF;
  padding-top: 65rpx;
  line-height: 60rpx;
  text-align: center;
}

.user-info {
  display: flex;
  margin-top: 20rpx;
}

.sub-title {
  margin-bottom: 36rpx;
}

.sub-title .radio-group-no-box .radio-item {
  font-size: 32rpx;
  padding: 4px 8px;
}

.input-wrapper {
  border-radius: 8rpx;
  background-color: #292935;
  margin: 40rpx 0;
  padding: 18rpx 16rpx;
  font-size: 32rpx;
}

.radio-group-no-box {
  display: inline-block;
  color: #006eff;
  background-color: #ffffff;
  border: 1px solid #006eff;
  border-radius: 4px;
  /* margin-left: 180rpx; */
}

.radio-group-no-box .radio-item {
  padding: 3px 8px;
  text-align: center;
  border-right: 1px solid #006eff;
  display: inline-block;
}

.radio-group-no-box .radio-item:last-child {
  border-right: none;
}

.radio-group-no-box .radio-item.selected {
  color: #ffffff;
  background-color: #006eff;
}

.radio-group-no-box radio {
  display: none;
}

.bottom-btn {
  position: fixed;
  width: 100vw;
  bottom: 5vh;
}

.bottom-btn .btn {
  width: 90%;
  line-height: 60rpx;
  background-color: #467ff6;
  border-radius: 50px;
  font-size: 32rpx;
  color: #ffffff;
  margin: 0;
}
</style>