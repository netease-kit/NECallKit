import App from './App'
import { createSSRApp } from 'vue';
import * as Pinia from 'pinia';

import { NECallKit } from "@/uni_modules/Netease-Call/callkit/callServices/services/index";
import { NEStore } from "@/uni_modules/Netease-Call/callkit/callServices/NEStore/index";
import { initNIM } from "@/nim";

uni.$NECallKit = NECallKit;
uni.$NEStore = NEStore;

try {
  uni.$UIKitNIM = initNIM();
  
  uni.$NIMPushPlugin = uni.requireNativePlugin("NIMUniPlugin-PluginModule");
  
  uni.$UIKitNIM.V2NIMSettingService.setOfflinePushConfig(uni.$NIMPushPlugin, {
    apns: {
      certificateName: "party_release",
    },
  });
} catch (error) {
  console.error("NIM 初始化失败:", error);
}

export function createApp() {
	const app = createSSRApp(App);
	app.use(Pinia.createPinia());
	return {
		app,
		Pinia, // 此处必须将 Pinia 返回
	};
}
