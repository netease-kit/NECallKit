// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import static androidx.test.espresso.Espresso.pressBack;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.waitForTime;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkCallerMicroPhoneWhenCallState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkCallerSpeakerWhenCallState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkCallerSwitchTypeWhenCallState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkMicroPhoneState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkMuteVideoState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkSpeakerState;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.checkSwitchType;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCallerMicroPhoneBtnWhenCall;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCallerSpeakerWhenCall;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCallerSwitchTypeBtnWhenCall;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCameraFlip;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickCancelBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickHangupBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickMicroPhoneBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickMuteVideoBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSpeakerBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSwitchTypeBtn;

import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;

public class UITestForCaller extends UITestBaseForCallKit {

  @Test
  public void testSelf() {
    // 登录 case
    enterP2PCall();
    homeToLogin("15098918829", "1112");
    enterP2PCall();
    callerSearchAndCallUsual("15725572857");
    waitForTime(2000);
    pressBack();
    waitForTime(2000);
    homeToLogout();
  }

  /**
   * 主叫搜索目标用户并进行呼叫各种按钮切换测试及检验
   *
   * @param phone 目标用户手机账号
   */
  public static Map<String, String> callerSearchAndCallUsual(String phone) {
    searchByPhone(phone);
    startCallFromSearchResult(phone); // video
    waitForTime(500);
    checkCallerSwitchTypeWhenCallState(ChannelType.VIDEO.getValue());
    //--------- 呼叫页面 --------------
    clickCallerSwitchTypeBtnWhenCall(); // audio
    checkCallerSwitchTypeWhenCallState(ChannelType.AUDIO.getValue());
    checkCallerMicroPhoneWhenCallState(true);
    clickCallerMicroPhoneBtnWhenCall();
    checkCallerMicroPhoneWhenCallState(false);
    clickCallerMicroPhoneBtnWhenCall();
    checkCallerSpeakerWhenCallState(false);
    clickCallerSpeakerWhenCall();
    checkCallerSpeakerWhenCallState(true);
    clickCallerSpeakerWhenCall();

    //--------- 等待对方接听 -----------
    waitForTime(10000);

    checkSwitchType(ChannelType.AUDIO.getValue()); //检查通话类型
    clickMicroPhoneBtn();
    checkMicroPhoneState(false);
    clickSpeakerBtn();
    checkSpeakerState(true);
    clickSwitchTypeBtn(); // video
    checkSwitchType(ChannelType.VIDEO.getValue());
    clickMicroPhoneBtn();
    checkMicroPhoneState(false);
    clickMuteVideoBtn();
    checkMuteVideoState(false);
    clickMuteVideoBtn(); // true
    clickCameraFlip();
    waitForTime(2000);
    clickCameraFlip();

    //--------- 等待被叫检查操作 -----------
    // 挂断
    waitForTime(4000);
    clickHangupBtn();

    // 点击通话记录，被叫拒绝
    startCallFromRecord(0);
    waitForTime(5000);

    // 点击最近搜索，主叫取消
    startCallFromRecent(0);
    clickCancelBtn();

    return new HashMap<>();
  }
}
