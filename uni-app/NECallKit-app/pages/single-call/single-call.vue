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
					<input type="text" id="calledAccount" v-model="calledAccount" class="input-field"
						placeholder="请输入被呼账号">
				</div>

			</div>

			<div class="button-container">
				<button type="primary" class="call-btn audio" @click="callAudio"
					:disabled="!calledAccount">音频通话</button>
				<button type="primary" class="call-btn video" @click="callVideo"
					:disabled="!calledAccount">视频通话</button>
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
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	.form-grid {
		display: grid;
		grid-template-columns: auto 1fr;
		grid-gap: 15px;
		align-items: center;
	}

	.form-grid label {
		font-weight: 500;
		color: #333;
		min-width: 120px;
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


	export default {
		data() {
			return {
				userConfig: {},
				calledAccount: "",
                rtcChannelName: "",
                ainsMode: -1
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
			// 读取单呼设置（内存）
			const app = getApp();
			const saved = (app && app.globalData && app.globalData.singleCallSettings) || {};
			this.rtcChannelName = saved.rtcChannelName || "";
                  if (saved.ainsMode !== undefined) this.ainsMode = Number(saved.ainsMode);

			// 注册原生事件监听
			this.onReceiveInvited = (e) => {
				console.log('onReceiveInvited', JSON.stringify(e));
			};
			NECallKitEvent.addEventListener('onReceiveInvited', this.onReceiveInvited);

			this.onCallConnected = (e) => {
				console.log('onCallConnected' + JSON.stringify(e));
			};
			NECallKitEvent.addEventListener('onCallConnected', this.onCallConnected);

			this.onCallTypeChange = (e) => {
				console.log('onCallTypeChange' + JSON.stringify(e));
				NECallKitEvent.removeEventListener('onReceiveInvited', this.onReceiveInvited);
				uni.showToast({
					title: 'onCallTypeChange ' + JSON.stringify(e),
					icon: "none"
				});
			};
			NECallKitEvent.addEventListener('onCallTypeChange', this.onCallTypeChange);

			this.onCallEnd = (e) => {
				console.log('onCallEnd' + JSON.stringify(e));
				uni.showToast({
					title: 'onCallEnd ' + JSON.stringify(e),
					icon: "none"
				});
			};
			NECallKitEvent.addEventListener('onCallEnd', this.onCallEnd);

			this.onVideoAvailable = (e) => {
				console.log('onVideoAvailable' + JSON.stringify(e));
				uni.showToast({
					title: 'onVideoAvailable ' + JSON.stringify(e),
					icon: "none"
				});
			};
			NECallKitEvent.addEventListener('onVideoAvailable', this.onVideoAvailable);

			this.onVideoMuted = (e) => {
				console.log('onVideoMuted' + JSON.stringify(e));
				uni.showToast({
					title: 'onVideoMuted ' + JSON.stringify(e),
					icon: "none"
				});
			};
			NECallKitEvent.addEventListener('onVideoMuted', this.onVideoMuted);

			this.onAudioMuted = (e) => {
				console.log('onAudioMuted' + JSON.stringify(e));
				uni.showToast({
					title: 'onAudioMuted ' + JSON.stringify(e),
					icon: "none"
				});
			};
			NECallKitEvent.addEventListener('onAudioMuted', this.onAudioMuted);
		},

		onUnload() {
			// 组件卸载时移除监听，避免泄露
			if (this.onReceiveInvited) NECallKitEvent.removeEventListener('onReceiveInvited', this.onReceiveInvited);
			if (this.onCallConnected) NECallKitEvent.removeEventListener('onCallConnected', this.onCallConnected);
			if (this.onCallTypeChange) NECallKitEvent.removeEventListener('onCallTypeChange', this.onCallTypeChange);
			if (this.onCallEnd) NECallKitEvent.removeEventListener('onCallEnd', this.onCallEnd);
			if (this.onVideoAvailable) NECallKitEvent.removeEventListener('onVideoAvailable', this.onVideoAvailable);
			if (this.onVideoMuted) NECallKitEvent.removeEventListener('onVideoMuted', this.onVideoMuted);
			if (this.onAudioMuted) NECallKitEvent.removeEventListener('onAudioMuted', this.onAudioMuted);
		},
		onShow() {
			// 返回页面时刷新设置（内存）
			const app = getApp();
			const saved = (app && app.globalData && app.globalData.singleCallSettings) || {};
            this.rtcChannelName = saved.rtcChannelName || "";
            if (saved.ainsMode !== undefined) this.ainsMode = Number(saved.ainsMode);
		},

		methods: {
			goSettings() {
				uni.navigateTo({
					url: '/pages/single-call/settings'
				});
			},
            setAINSMode() {
                if (this.ainsMode === -1) {
                    return;
                }
                NECallKit.setAINSMode({ rtcAINSMode: this.ainsMode }, (ret) => {
                    if (ret.code != 200) {
                        var msg = '设置失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
                        uni.showToast({ title: msg, icon: 'none' });
                    }
                });
            },

			async callAudio() {
				if (!this.calledAccount) {
					uni.showToast({
						title: '请输入被呼账号',
						icon: "none"
					});
					return;
				}

                // 再次设置 AINS 模式（若选择为 -1 则跳过）
                this.setAINSMode();

				// 读取推送设置（内存）并发起通话
				const app = getApp();
				const saved = (app && app.globalData && app.globalData.singleCallSettings) || {};
				const options = {
					accountList: [this.calledAccount],
					rtcChannelName: this.rtcChannelName || undefined,
					type: 1,
					needPush: typeof saved.needPush === 'boolean' ? saved.needPush : false,
					pushTitle: saved.pushTitle || undefined,
					pushContent: saved.pushContent || undefined,
					pushPayload: saved.pushPayload || undefined,
					needBadge: typeof saved.needBadge === 'boolean' ? saved.needBadge : false
				};
				NECallKit.toCallPage(options, (ret) => {
					if (ret.code != 200) {
						var msg = '音频呼叫失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
						uni.showToast({
							title: msg,
							icon: "none"
						})
					} else {
						uni.showToast({
							title: '音频呼叫成功',
							icon: "success"
						})
					}
				})
			},

			async callVideo() {
				if (!this.calledAccount) {
					uni.showToast({
						title: '请输入被呼账号',
						icon: "none"
					});
					return;
				}

                // 再次设置 AINS 模式（若选择为 -1 则跳过）
                this.setAINSMode();

				// 读取推送设置（内存）并发起通话
				const app = getApp();
				const saved = (app && app.globalData && app.globalData.singleCallSettings) || {};
				const options = {
					accountList: [this.calledAccount],
					rtcChannelName: this.rtcChannelName || undefined,
					type: 2,
					needPush: typeof saved.needPush === 'boolean' ? saved.needPush : false,
					pushTitle: saved.pushTitle || undefined,
					pushContent: saved.pushContent || undefined,
					pushPayload: saved.pushPayload || undefined,
					needBadge: typeof saved.needBadge === 'boolean' ? saved.needBadge : false
				};
				NECallKit.toCallPage(options, (ret) => {
					if (ret.code != 200) {
						var msg = '视频呼叫失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
						uni.showToast({
							title: msg,
							icon: "none"
						})
					} else {
						uni.showToast({
							title: '视频呼叫成功',
							icon: "success"
						})
					}
				})
			}
		}
	}
</script>
