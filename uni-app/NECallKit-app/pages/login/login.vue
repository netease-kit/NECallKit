<template>
	<div class="login-container">
		<div class="form-section">
			<div class="form-grid">
				<label for="account">账号：</label>
				<input type="text" id="account" v-model="account" class="input-field" placeholder="请输入账号">

				<label for="apnsCername">APNs证书名：</label>
				<input type="text" id="apnsCername" v-model="apnsCername" class="input-field" placeholder="APNs证书名（可选）">

				<label for="pkCername">PK证书名：</label>
				<input type="text" id="pkCername" v-model="pkCername" class="input-field" placeholder="PK证书名（可选）">

				<label for="language">语言：</label>
				<input type="text" id="language" v-model="language" class="input-field" placeholder="语言设置（可选）">

				<label for="rtcUid">自定义 rtcUid：</label>
				<input type="text" id="rtcUid" v-model="rtcUid" class="input-field" placeholder="自定义rtcUid（可选）">
			</div>

			<div class="collapsible-section">
				<div class="section-header" @click="toggleCallConfig">
					<span class="section-title">单人呼叫配置</span>
					<span class="toggle-icon" :class="{ 'expanded': isCallConfigExpanded }">▼</span>
				</div>
				<div class="switch-section" v-show="isCallConfigExpanded">
					<div class="switch-item">
						<label>开启悬浮窗：</label>
						<switch :checked="enableFloatingWindow" @change="enableFloatingWindowRadioChange" />
					</div>

					<div class="switch-item">
						<label>开启自动悬浮窗：</label>
						<switch :checked="enableAutoFloatingWindowWhenHome"
							@change="enableAutoFloatingWindowWhenHomeRadioChange" />
					</div>

					<div class="switch-item">
						<label>开启前台服务：</label>
						<switch :checked="enableForegroundService" @change="enableForegroundServiceRadioChange" />
					</div>

					<div class="switch-item">
						<label>支持音频转视频：</label>
						<switch :checked="enableAudio2Video" @change="enableAudio2VideoChange" />
					</div>

					<div class="switch-item">
						<label>支持视频转音频：</label>
						<switch :checked="enableVideo2Audio" @change="enableVideo2AudioChange" />
					</div>

					<div class="switch-item">
						<label>音频转视频需确认：</label>
						<switch :checked="audio2VideoConfirm" @change="audio2VideoConfirmChange" />
					</div>

					<div class="switch-item">
						<label>视频转音频需确认：</label>
						<switch :checked="video2AudioConfirm" @change="video2AudioConfirmChange" />
					</div>
				</div>
			</div>
		</div>

		<div class="button-container">
			<button type="primary" class="login-button" @click="login" :disabled="!canLogin">登录</button>
		</div>
	</div>
</template>

<style scoped>
	.login-container {
		padding: 20px;
		background-color: #f5f5f5;
		min-height: 100vh;
	}

	.title {
		font-size: 24px;
		font-weight: bold;
		margin-bottom: 30px;
		color: #333;
		text-align: center;
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
		margin-bottom: 20px;
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
		justify-content: center;
		margin-top: 30px;
	}

	.login-button {
		width: 100%;
		max-width: 300px;
		height: 50px;
		font-size: 16px;
		border-radius: 8px;
		background-color: #007AFF;
		color: white;
		border: none;
	}

	.login-button:disabled {
		background-color: #ccc;
		cursor: not-allowed;
	}

	.collapsible-section {
		margin: 20px 0;
	}

	.section-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		cursor: pointer;
		padding: 15px;
		background-color: white;
		border-radius: 8px;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		margin-bottom: 10px;
	}

	.section-header:hover {
		background-color: #f8f9fa;
	}

	.section-title {
		font-size: 16px;
		font-weight: bold;
		color: #333;
	}

	.toggle-icon {
		font-size: 14px;
		color: #666;
		transition: transform 0.3s ease;
	}

	.toggle-icon.expanded {
		transform: rotate(180deg);
	}

	.switch-section {
		background-color: white;
		border-radius: 8px;
		padding: 15px;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		transition: all 0.3s ease;
	}

	.switch-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 0;
		border-bottom: 1px solid #f0f0f0;
	}

	.switch-item:last-child {
		border-bottom: none;
	}

	.switch-item label {
		font-weight: 500;
		color: #333;
	}
</style>

<script>
	// 首先需要通过 uni.requireNativePlugin("ModuleName") 获取 module
	var callKit = uni.requireNativePlugin("netease-CallKit")
	const callKitEvent = uni.requireNativePlugin('globalEvent');
	// 导入配置文件
	import AppConfig from '../../debug/AppConfig.js';

	callKitEvent.addEventListener('onReceiveInvited', function(e) {
		console.log('onReceiveInvited' + JSON.stringify(e));
	});

	callKitEvent.addEventListener('onCallConnected', function(e) {
		console.log('onCallConnected' + JSON.stringify(e));
		uni.showToast({
			title: 'onCallConnected ' + JSON.stringify(e),
			icon: "none"
		});
	});

	callKitEvent.addEventListener('onCallTypeChange', function(e) {
		console.log('onCallTypeChange' + JSON.stringify(e));
		uni.showToast({
			title: 'onCallTypeChange ' + JSON.stringify(e),
			icon: "none"
		});
	});

	callKitEvent.addEventListener('onCallEnd', function(e) {
		console.log('onCallEnd' + JSON.stringify(e));
		uni.showToast({
			title: 'onCallEnd ' + JSON.stringify(e),
			icon: "none"
		});
	});

	callKitEvent.addEventListener('onVideoAvailable', function(e) {
		console.log('onVideoAvailable' + JSON.stringify(e));
		uni.showToast({
			title: 'onVideoAvailable ' + JSON.stringify(e),
			icon: "none"
		});
	});

	callKitEvent.addEventListener('onVideoMuted', function(e) {
		console.log('onVideoMuted' + JSON.stringify(e));
		uni.showToast({
			title: 'onVideoMuted ' + JSON.stringify(e),
			icon: "none"
		});
	});

	callKitEvent.addEventListener('onAudioMuted', function(e) {
		console.log('onAudioMuted' + JSON.stringify(e));
		uni.showToast({
			title: 'onAudioMuted ' + JSON.stringify(e),
			icon: "none"
		});
	});

	export default {
		data() {
			return {
				account: "",
				currentToken: "", // 将自动获取
				apnsCername: "",
				pkCername: "",
				language: "",
				rtcUid: "",
				enableFloatingWindow: false,
				enableAutoFloatingWindowWhenHome: false,
				enableForegroundService: false,
				enableAudio2Video: true,
				enableVideo2Audio: true,
				audio2VideoConfirm: false,
				video2AudioConfirm: false,
				isCallConfigExpanded: false // 单人呼叫配置折叠状态，默认折叠
			};
		},


		computed: {
			canLogin() {
				return this.account; // 只需要account即可
			}
		},

		methods: {
			enableFloatingWindowRadioChange: function(evt) {
				this.enableFloatingWindow = evt.detail.value
				console.log('enableFloatingWindow value change，value', evt.detail.value)
			},

			enableAutoFloatingWindowWhenHomeRadioChange: function(evt) {
				this.enableAutoFloatingWindowWhenHome = evt.detail.value
				console.log('enableAutoFloatingWindowWhenHome value change，value', evt.detail.value)
			},

			enableForegroundServiceRadioChange: function(evt) {
				this.enableForegroundService = evt.detail.value
				console.log('enableForegroundService value change，value', evt.detail.value)
			},

			enableAudio2VideoChange: function(evt) {
				this.enableAudio2Video = evt.detail.value
				console.log('enableAudio2VideoChange value change，value', evt.detail.value)
			},

			enableVideo2AudioChange: function(evt) {
				this.enableVideo2Audio = evt.detail.value
				console.log('enableVideo2AudioChange value change，value', evt.detail.value)
			},

			audio2VideoConfirmChange: function(evt) {
				this.audio2VideoConfirm = evt.detail.value
				console.log('audio2VideoConfirm value change，value', evt.detail.value)
			},

			video2AudioConfirmChange: function(evt) {
				this.video2AudioConfirm = evt.detail.value
				console.log('video2AudioConfirm value change，value', evt.detail.value)
			},

			toggleCallConfig() {
				this.isCallConfigExpanded = !this.isCallConfigExpanded;
			},

			// 获取Nemo账号信息
			async getNemoAccount(accountId) {
				return new Promise((resolve) => {
					uni.request({
						url: AppConfig.nemoServerUrl,
						method: 'POST',
						header: {
							'Content-Type': 'application/json',
							'deviceId': AppConfig.deviceInfo.deviceId,
							'clientType': AppConfig.deviceInfo.clientType,
							'appkey': AppConfig.appKey,
							'AppSecret': AppConfig.appSecret
						},
						data: {
							sceneType: 2,
							userUuid: accountId
						},
						success: (res) => {
							console.log("result: ", res.data);
							resolve({
								success: res.statusCode === 200 && res.data && res.data.code === 200,
								data: res.data && res.data.code === 200 ? {
									userUuid: res.data.data.userUuid || '',
									userName: res.data.data.userName || '',
									userToken: res.data.data.userToken || '',
									icon: res.data.data.icon || null
								} : null,
								message: res.data && res.data.code !== 200 ? res.data.msg || '账号创建失败' : null
							});
						},
						fail: (error) => {
							resolve({
								success: false,
								data: null,
								message: '网络请求失败：' + (error.errMsg || '未知错误')
							});
						}
					});
				});
			},

			async loginAPI() {
				return new Promise((resolve) => {
					console.log("loginAPI: ", this.account, this.currentToken);
					callKit.login({
						appKey: AppConfig.appKey,
						account: this.account,
						token: this.currentToken,
						rtcUid: this.rtcUid ? Number(this.rtcUid) : undefined,
						apnsCername: this.apnsCername,
						pkCername: this.pkCername,
						language: this.language,
						enableFloatingWindow: this.enableFloatingWindow,
						enableAutoFloatingWindowWhenHome: this.enableAutoFloatingWindowWhenHome,
						enableForegroundService: this.enableForegroundService,
						enableAudio2Video: this.enableAudio2Video,
						enableVideo2Audio: this.enableVideo2Audio,
						enableAudio2VideoConfirm: this.audio2VideoConfirm,
						enableVideo2AudioConfirm: this.video2AudioConfirm
					}, (ret) => {
						resolve(ret);
					});
				});
			},

			async login() {
				if (!this.canLogin) {
					uni.showToast({
						title: '请填写账号',
						icon: "none"
					});
					return;
				}

				uni.showLoading({
					title: '获取账号信息中...'
				});

				// 先获取Nemo账号信息
				const nemoResult = await this.getNemoAccount(this.account);
				console.log("nemoResult: ", nemoResult);
				
				if (!nemoResult.success) {
					uni.hideLoading();
					uni.showToast({
						title: '账号创建失败(请更换账号后重试)\n错误信息：' + nemoResult.message,
						icon: "none"
					});
					return;
				}

				const nemoAccount = nemoResult.data;
				this.currentToken = nemoAccount.userToken;
				console.log("currentToken: ", this.currentToken);
				
				uni.showLoading({
					title: '登录中...'
				});

				// 再登录
				const loginResult = await this.loginAPI();
				uni.hideLoading();

				if (loginResult.code !== 200) {
					uni.showToast({
						title: '账号登录失败(请更换账号后重试)\n错误信息：' + loginResult.message,
						icon: "none"
					});
					return;
				}

				// 保存用户配置到本地存储（包含获取到的Token）
				uni.setStorageSync('userConfig', {
					appkey: AppConfig.appKey,
					account: this.account,
					currentToken: this.currentToken,
					rtcUid: this.rtcUid,
					apnsCername: this.apnsCername,
					pkCername: this.pkCername,
					language: this.language,
					enableFloatingWindow: this.enableFloatingWindow,
					enableAutoFloatingWindowWhenHome: this.enableAutoFloatingWindowWhenHome,
					enableForegroundService: this.enableForegroundService,
					enableAudio2Video: this.enableAudio2Video,
					enableVideo2Audio: this.enableVideo2Audio,
					audio2VideoConfirm: this.audio2VideoConfirm,
					video2AudioConfirm: this.video2AudioConfirm,
					// 保存Nemo账号信息
					nemoAccount: nemoAccount
				});

				uni.showToast({
					title: '登录成功',
					icon: "success"
				});

				// 跳转到首页
				setTimeout(() => {
					uni.redirectTo({
						url: '/pages/index/index'
					});
				}, 1500);
			}
		}
	}
</script>