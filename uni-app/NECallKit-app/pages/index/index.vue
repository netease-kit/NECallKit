<template>
	<div class="home-container">
		<div class="user-info">
			<div class="welcome">欢迎，{{ userConfig.account }}</div>
			<button class="logout-button" @click="logout">退出登录</button>
		</div>
		<div class="title">选择通话类型</div>
		<div class="button-container">
			<button type="primary" class="call-button" @click="goToSingleCall">单人通话</button>
			<button type="primary" class="call-button" @click="goToMultiCall">多人通话</button>
		</div>
	</div>
</template>

<style scoped>
.home-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    padding: 20px;
    position: relative;
}

.user-info {
    position: absolute;
    top: 20px;
    right: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.welcome {
    font-size: 14px;
    color: #666;
}

.logout-button {
    background-color: #ff4757;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    font-size: 12px;
    cursor: pointer;
}

.title {
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 40px;
    color: #333;
}

.button-container {
    display: flex;
    flex-direction: column;
    gap: 20px;
    width: 100%;
    max-width: 300px;
}

.call-button {
    height: 50px;
    font-size: 16px;
    border-radius: 8px;
}
</style>

<script>
	var testModule = uni.requireNativePlugin("netease-CallKit")

	export default {
		data() {
			return {
				userConfig: {}
			};
		},

		onLoad() {
			// 检查是否已登录
			const config = uni.getStorageSync('userConfig');
			if (!config || !config.account) {
				// 未登录，跳转到登录页
				uni.redirectTo({
					url: '/pages/login/login'
				});
				return;
			}
			this.userConfig = config;
		},

		methods: {
			goToSingleCall() {
				uni.navigateTo({
					url: '/pages/single-call/single-call'
				});
			},
			
			goToMultiCall() {
				uni.navigateTo({
					url: '/pages/multi-call/multi-call'
				});
			},

			logout() {
				uni.showModal({
					title: '确认退出',
					content: '确定要退出登录吗？',
					success: (res) => {
						if (res.confirm) {
							// 调用登出API
							testModule.logout({}, (ret) => {
								// 清除本地存储
								uni.removeStorageSync('userConfig');
								// 跳转到登录页
								uni.redirectTo({
									url: '/pages/login/login'
								});
							});
						}
					}
				});
			}
		}
	}
</script>
