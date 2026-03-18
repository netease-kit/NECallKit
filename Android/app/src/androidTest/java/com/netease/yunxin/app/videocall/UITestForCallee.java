// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import static androidx.test.espresso.Espresso.pressBack;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.waitForTime;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkCalleeSwitchTypeWhenCallState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkCallerSwitchTypeWhenCallState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkMicroPhoneState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkMuteVideoState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkSpeakerState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkSwitchType;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickAcceptBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCalleeSwitchTypeBtnWhenCall;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCameraFlip;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickMicroPhoneBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickMuteVideoBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickRejectBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSpeakerBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSwitchTypeBtn;

import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import org.junit.Test;

public class UITestForCallee extends UITestBaseForCallKit {

  @Test
  public void testSelf() {
    enterP2PCall();
    homeToLogin("15725572857", "1111");
    enterP2PCall();
    calleeForAcceptCallUsual();
    waitForTime(2000);
    pressBack();
    waitForTime(2000);
    homeToLogout();
  }

  /** 主叫搜索目标用户并进行呼叫各种按钮切换测试及检验 */
  public static void calleeForAcceptCallUsual() {
    //----------- 等待呼叫 -----------
    waitForTime(5000);
    checkCalleeSwitchTypeWhenCallState(ChannelType.VIDEO.getValue());
    clickCalleeSwitchTypeBtnWhenCall();
    checkCalleeSwitchTypeWhenCallState(ChannelType.AUDIO.getValue());
    clickCalleeSwitchTypeBtnWhenCall();
    clickAcceptBtn();

    checkSwitchType(ChannelType.VIDEO.getValue());
    //----------- 等待主叫操作 ----------
    waitForTime(10000);

    clickCalleeSwitchTypeBtnWhenCall(); // audio
    checkCallerSwitchTypeWhenCallState(ChannelType.AUDIO.getValue());
    waitForTime(1000);
    clickMicroPhoneBtn();
    checkMicroPhoneState(false);
    waitForTime(2000);
    clickSpeakerBtn();
    checkSpeakerState(true);

    waitForTime(1000);
    clickSpeakerBtn();
    checkSpeakerState(false);
    waitForTime(1000);
    clickSwitchTypeBtn();
    checkSwitchType(ChannelType.VIDEO.getValue());
    waitForTime(1000);
    clickMicroPhoneBtn();
    checkMicroPhoneState(false);
    waitForTime(1000);
    clickMuteVideoBtn();
    checkMuteVideoState(true);
    waitForTime(1000);
    clickCameraFlip();
    waitForTime(2000);
    clickCameraFlip();

    // 通话结束
    // 等待再次呼叫并拒绝
    waitForTime(10000);
    clickRejectBtn();
  }
}
