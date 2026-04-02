// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import router from '@ohos.router';
import {
  CallerInfo,
  IncomingCallBannerContent,
  BannerCallbackStore
} from '@yunxin/callkit_ui/src/main/ets/widget/IncomingCallBannerWidget';

@Entry
@Component
struct IncomingCallBannerPage {
  private callerInfo: CallerInfo = BannerCallbackStore.callerInfo;

  build() {
    Column() {
      IncomingCallBannerContent({
        callerInfo: this.callerInfo,
        onAccept: () => {
          BannerCallbackStore.onAccept?.();
        },
        onReject: () => {
          BannerCallbackStore.onReject?.();
        },
        onBodyTap: () => {
          BannerCallbackStore.onBodyTap?.();
        }
      })
        .margin({ top: 8, left: 8, right: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000000')
    .hitTestBehavior(HitTestMode.Transparent)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
