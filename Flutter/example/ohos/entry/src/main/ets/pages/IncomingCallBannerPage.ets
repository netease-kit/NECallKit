import { BannerCallbackStore, IncomingCallBannerContent } from 'netease_callkit_ui';

@Entry
@Component
struct IncomingCallBannerPage {
  build() {
    Stack() {
      // 使用存储在 BannerCallbackStore 中的来电信息和回调
      IncomingCallBannerContent({
        callerInfo: BannerCallbackStore.callerInfo,
        onAccept: () => {
          if (BannerCallbackStore.onAccept) {
            BannerCallbackStore.onAccept();
          }
        },
        onReject: () => {
          if (BannerCallbackStore.onReject) {
            BannerCallbackStore.onReject();
          }
        },
        onBodyTap: () => {
          if (BannerCallbackStore.onBodyTap) {
            BannerCallbackStore.onBodyTap();
          }
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
