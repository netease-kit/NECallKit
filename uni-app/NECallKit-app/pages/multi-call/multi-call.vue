<template>
	<div>
		<div class="call-container">
			<div class="user-info">
				<div style="display:flex; justify-content:space-between; align-items:center;">
					<div class="account">当前账号：{{ userConfig.accountId }}</div>
					<button type="default" @click="goSettings">设置</button>
				</div>
			</div>
			
			<div class="form-section">
				<div class="form-grid">
					<label for="calledAccount">被呼账号：</label>
					<input type="text" id="calledAccount" v-model="calledAccount" class="input-field" placeholder="请输入多个账号，用逗号分隔">
				</div>
				
				<div class="accounts-preview" v-if="accountList.length > 0">
					<div class="preview-title">将呼叫以下账号：</div>
					<div class="account-tags">
						<span class="account-tag" v-for="(account, index) in accountList" :key="index">{{ account }}</span>
					</div>
				</div>
			</div>
			
			<div class="button-container">
				<button type="primary" class="call-btn video" @click="startCall" :disabled="!calledAccount">发起通话</button>
			</div>
		</div>
	</div>
</template>

<style scoped>
.call-container {
    padding: 20px;
    background-color: #f5f5f5;
    min-height: 100vh;
}

.user-info {
    background-color: white;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.account {
    font-size: 16px;
    color: #333;
    font-weight: 500;
}

.form-section {
    background-color: white;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-grid {
    display: grid;
    grid-template-columns: auto 1fr;
    grid-gap: 15px;
    align-items: center;
    margin-bottom: 20px;
}

.form-grid label {
    font-weight: 500;
    color: #333;
    min-width: 10px;
}

.input-field {
    background-color: #f8f8f8;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
}

.input-field:focus {
    border-color: #007AFF;
    outline: none;
}

.accounts-preview {
    border-top: 1px solid #eee;
    padding-top: 15px;
}

.preview-title {
    font-size: 14px;
    color: #666;
    margin-bottom: 10px;
}

.account-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.account-tag {
    background-color: #e3f2fd;
    color: #1976d2;
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    border: 1px solid #bbdefb;
}

.button-container {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin-top: 20px;
}

.call-btn {
    height: 50px;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    color: white;
    font-weight: 500;
}

.call-btn.audio {
    background-color: #28a745;
}

.call-btn.video {
    background-color: #007bff;
}

.call-btn:disabled {
    background-color: #ccc;
    cursor: not-allowed;
}

.settings-btn {
    height: 50px;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    color: white;
    font-weight: 500;
    background-color: #17a2b8;
}
</style>

<script>
	// 首先需要通过 uni.requireNativePlugin("ModuleName") 获取 module
	var NECallKit = uni.requireNativePlugin("netease-CallKit")
	const NECallKitEvent = uni.requireNativePlugin('globalEvent');


	NECallKitEvent.addEventListener('onReceiveInvited', function(e) {
	  console.log('onReceiveInvited' + JSON.stringify(e));
	});
	
	NECallKitEvent.addEventListener('onCallConnected', function(e) {
	  console.log('onCallConnected' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onCallConnected ' + JSON.stringify(e),
	  	icon: "none"
	  });
	  
	  uni.showToast({
	  	title: 'onCallConnected ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});
	
	NECallKitEvent.addEventListener('onCallTypeChange', function(e) {
	  console.log('onCallTypeChange' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onCallTypeChange ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});
	
	NECallKitEvent.addEventListener('onCallEnd', function(e) {
	  console.log('onCallEnd' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onCallEnd ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});
	
	NECallKitEvent.addEventListener('onVideoAvailable', function(e) {
	  console.log('onVideoAvailable' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onVideoAvailable ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});
	
	NECallKitEvent.addEventListener('onVideoMuted', function(e) {
	  console.log('onVideoMuted' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onVideoMuted ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});
	
	NECallKitEvent.addEventListener('onAudioMuted', function(e) {
	  console.log('onAudioMuted' + JSON.stringify(e));
	  uni.showToast({
	  	title: 'onAudioMuted ' + JSON.stringify(e),
	  	icon: "none"
	  });
	});

	export default {
		data() {
			return {
				userConfig: {},
				calledAccount: "",
					ainsMode: 1,
					rtcChannelName: ""
			};
		},

		onLoad() {
			// 获取用户配置
			const config = uni.getStorageSync('userConfig');
			if (!config || !config.accountId) {
				// 未登录，跳转到登录页
				uni.redirectTo({
					url: '/pages/login/login'
				});
				return;
			}
			this.userConfig = config;
			// 读取群呼设置（内存）
			const app = getApp();
			const saved = (app && app.globalData && app.globalData.multiCallSettings) || {};
			this.rtcChannelName = saved.rtcChannelName || "";
			if (typeof saved.ainsMode === 'number') this.ainsMode = saved.ainsMode;
		},
		onShow() {
			// 返回页面时刷新设置（内存）
			const app = getApp();
			const saved = (app && app.globalData && app.globalData.multiCallSettings) || {};
			this.rtcChannelName = saved.rtcChannelName || "";
			if (typeof saved.ainsMode === 'number') this.ainsMode = saved.ainsMode;
		},

		computed: {
			accountList() {
				if (!this.calledAccount) return [];
				// 兼容中文逗号(，)和英文逗号(,)，以及空格
				return this.calledAccount
					.split(/[,，\s]+/)
					.map(acc => acc.trim())
					.filter(acc => acc.length > 0);
			}
		},

			methods: {
				goSettings() {
					uni.navigateTo({ url: '/pages/multi-call/settings' });
				},
				setAINSMode() {
				if (this.ainsMode === -1) {
					return;	
				}
				NECallKit.setAINSMode({
					rtcAINSMode: this.ainsMode
				}, (ret) => {
					if (ret.code != 200) {
						var msg = '设置失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
						uni.showToast({
							title: msg,
							icon: "none"
						})
					} else {
						uni.showToast({
							title: '设置成功',
							icon: "success"
						})
					}
				})
			},

			startCall() {
				if (!this.calledAccount) {
					uni.showToast({
						title: '请输入被呼账号',
						icon: "none"
					});
					return;
				}

				const accounts = this.accountList;
				if (accounts.length === 0) {
					uni.showToast({
						title: '请输入有效的账号',
						icon: "none"
					});
					return;
				}

				// AINS 再次设置 AINS 模式
				this.setAINSMode();

				NECallKit.toCallPage({
					accountList: accounts,
					isGroupCall: true,
					type: 2,
					rtcChannelName: this.rtcChannelName || undefined,
					// push settings (from memory)
					needPush: (getApp().globalData && getApp().globalData.multiCallSettings && typeof getApp().globalData.multiCallSettings.needPush === 'boolean') ? getApp().globalData.multiCallSettings.needPush : false,
					pushContent: (getApp().globalData && getApp().globalData.multiCallSettings && getApp().globalData.multiCallSettings.pushContent) || undefined,
					pushPayload: (getApp().globalData && getApp().globalData.multiCallSettings && getApp().globalData.multiCallSettings.pushPayload) || undefined
				}, (ret) => {
					if (ret.code != 200) {
						var msg = '多人视频呼叫失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
						uni.showToast({
							title: msg,
							icon: "none"
						})
					} else {
						uni.showToast({
							title: '多人视频呼叫成功',
							icon: "success"
						})
					}
				})
			}
		}
	}

</script>
