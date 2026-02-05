<script lang="ts">
	export default {
    globalData: {
      appkey: "", // 请填写应用对应的AppKey，可在云信控制台的“AppKey管理”页面获取
      nim: null,
      neCall: null,
      accountId: '',
      isLoggedIn: false,
    },
		onLaunch: function() {
			console.log('App Launch')

      const userConfig = uni.getStorageSync('userConfig')
      if (userConfig && userConfig.accountId && userConfig.token) {
        setTimeout(() => {
          uni.redirectTo({ url: '/pages/index/index' })
        }, 100)
      } else {
        setTimeout(() => {
          uni.redirectTo({ url: '/pages/login/login' })
        }, 100)
      }
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		}
	}
</script>

<style>
	/*每个页面公共css */
</style>
