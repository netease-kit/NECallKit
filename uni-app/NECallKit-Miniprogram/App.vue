<script lang="ts">
  import V2NIM from 'nim-web-sdk-ng/dist/v2/NIM_MINIAPP_SDK' // im sdk path
  import { NECall } from '@xkit-yx/call-kit/miniprogram_dist/index'
  
	export default {
		onLaunch: async function() {
			console.log('App Launch')
      
      const appkey = "" // 请填写自己应用的 appkey
      const account = "" // 请填写当前用户的im账号
      const token = "" // 请填写当前用户的im token
      
      // 初始化 V10 sdk
      const nim = V2NIM.getInstance({
        appkey,
        account,
        token,
        apiVersion: 'v2',
        debugLevel: 'debug',
      })
      // 登录 IM
      await nim.V2NIMLoginService.login(account, token)
      getApp().globalData.nim = nim
      
      // 初始化呼叫组件
      const neCall = NECall.getInstance()
      neCall.setup({
        nim, // im 实例用户需要先初始化, 对应到 NIM.getInstance 返回的 nim
        appkey, // 应用的 appKey，RTC 平台的 appKey
      })
      neCall?.on("onReceiveInvited", () => {
        // 接收到邀请后跳转到呼叫页面，路由用户可以自定义，该页面下需要包含 `@xkit-yx/call-kit-wx-ui` 相关的 UI 组件
        uni.navigateTo({
          url: "/pages/call/call",
        })
      })
      getApp().globalData.neCall = neCall
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
