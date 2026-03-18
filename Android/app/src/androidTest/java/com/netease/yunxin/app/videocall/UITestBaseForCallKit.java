// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import static androidx.test.espresso.Espresso.pressBack;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.waitForTime;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickEndCallOption;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickLogoutOption;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickNextBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickP2PItem;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickRecentByIndex;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickRecordByIndex;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSearchBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSearchResult;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickSendBtn;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.clickUserAvatar;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.inputLoginPhone;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.inputSearchPhone;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestUtils.inputVerifyCode;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.LargeTest;
import com.netease.yunxin.app.videocall.base.ClassRegister;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCVideoCall;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
@LargeTest
@ClassRegister
public class UITestBaseForCallKit {

  @Rule
  public ActivityScenarioRule<MainActivity> mainRuler =
      new ActivityScenarioRule<>(MainActivity.class);

  /**
   * 进入登录页面并登录成功
   *
   * @param phoneNum 登录手机号
   * @param verifyCode 验证码
   */
  public static void homeToLogin(String phoneNum, String verifyCode) {
    inputLoginPhone(phoneNum);
    clickSendBtn();
    waitForTime(500);
    inputVerifyCode(verifyCode);
    clickNextBtn();
    waitForTime(500);
    NERTCVideoCall.sharedInstance().enableSwitchCallTypeConfirm(false, false);
  }

  /** 点击首页头像，弹出退出弹窗，退出 */
  public static void homeToLogout() {
    clickUserAvatar();
    clickLogoutOption(true);
    waitForTime(2000);
  }

  /** 强制退出当前通话 */
  public static void forceEndCall() {
    pressBack();
    clickEndCallOption(true);
  }

  /** 进入 1对1 呼叫搜索页面 */
  public static void enterP2PCall() {
    clickP2PItem();
  }

  /**
   * 搜索 手机号码
   *
   * @param phoneNum 手机号
   */
  public static void searchByPhone(String phoneNum) {
    inputSearchPhone(phoneNum);
    clickSearchBtn();
  }

  /**
   * 开始呼叫搜索结果
   *
   * @param phoneNumResult 手机号结果目标
   */
  public static void startCallFromSearchResult(String phoneNumResult) {
    clickSearchResult(phoneNumResult);
  }

  /**
   * 通过 index 指定最近搜索记录发起呼叫
   *
   * @param index 索引 （0-2）
   */
  public static void startCallFromRecent(int index) {
    clickRecentByIndex(index);
  }

  /**
   * 通过 index 指定通话记录发起呼叫
   *
   * @param index 索引（0-2）
   */
  public static void startCallFromRecord(int index) {
    clickRecordByIndex(index);
  }

  /**
   * 配置通话转换确认
   *
   * @param audio2Video true 音频转视频需要确认，false 音频转视频不需要确认；
   * @param video2Audio true 视频转音频需要确认，false 视频转音频不需要确认；
   */
  public static void enableSwitchCallTypeConfirm(boolean audio2Video, boolean video2Audio) {
    NERTCVideoCall.sharedInstance().enableSwitchCallTypeConfirm(audio2Video, video2Audio);
  }
}
