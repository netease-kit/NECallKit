import NIM from "nim-web-sdk-ng/dist/v2/NIM_UNIAPP_SDK";
import { APP_CONFIG } from "@/config";

export function initNIM() {
  return NIM.getInstance(
    {
      appkey: APP_CONFIG.appKey,
      needReconnect: true,
      debugLevel: "off",
      apiVersion: "v2",
      enableV2CloudConversation: true,
    },
    {
      V2NIMLoginServiceConfig: {
        lbsUrls: ["https://lbs.netease.im/lbs/webconf.jsp"],
        linkUrl: "weblink.netease.im",
        isFixedDeviceId: true,
      },
    }
  );
}
