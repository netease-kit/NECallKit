// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.callkit;

import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.checkLocalDrawable;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.clickOnRecyclerItemWithHolder;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.clickOnRecyclerItemWithPosition;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.findViewMatcherInGroup;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.inputText;
import static com.netease.yunxin.app.videocall.base.BaseTestUtils.viewClick;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLEE_SWITCH_CALL_TYPE_AUDIO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLEE_SWITCH_CALL_TYPE_VIDEO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_MICRO_PHONE_DISABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_MICRO_PHONE_ENABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_SPEAKER_SWITCH_DISABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_SPEAKER_SWITCH_ENABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_SWITCH_CALL_TYPE_AUDIO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALLER_SWITCH_CALL_TYPE_VIDEO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_AUDIO_SWITCH_DISABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_AUDIO_SWITCH_ENABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_SPEAKER_SWITCH_DISABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_SPEAKER_SWITCH_ENABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_SWITCH_CALL_TYPE_AUDIO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_SWITCH_CALL_TYPE_VIDEO;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_VIDEO_SWITCH_DISABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.DrawableRes.CALL_VIDEO_SWITCH_ENABLE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALLEE_SWITCH_CALL_TYPE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALLER_AUDIO_SWITCH;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALLER_SPEAKER_SWITCH;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALLER_SWITCH_CALL_TYPE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_ACCEPT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_AUDIO_SWITCH;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_CAMERA_FLIP;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_CANCEL;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_HANGUP;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_REJECT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_SPEAKER_SWITCH;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_SWITCH_CALL_TYPE;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.CALL_VIDEO_SWITCH;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.LOGIN_NEXT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.LOGIN_PHONE_INPUT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.LOGIN_SEND;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.LOGIN_VERIFY_CODE_INPUT_PARENT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.MAIN_P2P_CALL_ENTER;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.MAIN_USER_AVATAR;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.SEARCH_PHONE_INPUT;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.SEARCH_RECENT_GROUP;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.SEARCH_RECORD_GROUP;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.SEARCH_RESULT_GROUP;
import static com.netease.yunxin.app.videocall.callkit.CallKitTestConstants.ViewIds.SEARCH_SEARCH;

import android.text.TextUtils;
import android.widget.EditText;
import androidx.test.espresso.ViewInteraction;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.yunxin.app.videocall.base.ClassRegister;
import com.netease.yunxin.app.videocall.call.adapter.RecentUserAdapter;
import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;

/** 呼叫组件测试工具封装 */
@ClassRegister
public final class CallKitTestUtils {

  //--- main
  public static ViewInteraction clickP2PItem() {
    return viewClick(MAIN_P2P_CALL_ENTER);
  }

  public static ViewInteraction clickUserAvatar() {
    return viewClick(MAIN_USER_AVATAR);
  }

  public static ViewInteraction clickLogoutOption(boolean logout) {
    return viewClick(withText(logout ? "是" : "否"));
  }

  //--- login
  public static ViewInteraction inputLoginPhone(String phoneNum) {
    return inputText(LOGIN_PHONE_INPUT, phoneNum);
  }

  public static ViewInteraction clickSendBtn() {
    return viewClick(LOGIN_SEND);
  }

  public static void inputVerifyCode(String verifyCode) {
    for (int i = 0; i < 4; i++) {
      inputText(
          findViewMatcherInGroup(LOGIN_VERIFY_CODE_INPUT_PARENT, EditText.class.getName(), i),
          String.valueOf(verifyCode.charAt(i)));
    }
  }

  public static ViewInteraction clickNextBtn() {
    return viewClick(LOGIN_NEXT);
  }

  //-------------- search page
  public static ViewInteraction inputSearchPhone(String phoneNum) {
    return inputText(SEARCH_PHONE_INPUT, phoneNum);
  }

  public static ViewInteraction clickSearchBtn() {
    return viewClick(withId(SEARCH_SEARCH));
  }

  public static ViewInteraction clickSearchResult(String verifyPhoneNum) {
    return clickOnRecyclerItemWithHolder(
        SEARCH_RESULT_GROUP, hasTextInHolderWithRecent(verifyPhoneNum));
  }

  public static ViewInteraction clickRecordByIndex(int index) {
    return clickOnRecyclerItemWithPosition(SEARCH_RECORD_GROUP, index);
  }

  public static ViewInteraction clickRecentByIndex(int index) {
    return clickOnRecyclerItemWithPosition(SEARCH_RECENT_GROUP, index);
  }

  //--------------- on the call page
  public static ViewInteraction clickCancelBtn() {
    return viewClick(CALL_CANCEL);
  }

  public static ViewInteraction clickRejectBtn() {
    return viewClick(CALL_REJECT);
  }

  public static ViewInteraction clickAcceptBtn() {
    return viewClick(CALL_ACCEPT);
  }

  public static ViewInteraction clickHangupBtn() {
    return viewClick(CALL_HANGUP);
  }

  public static ViewInteraction clickMicroPhoneBtn() {
    return viewClick(CALL_AUDIO_SWITCH);
  }

  public static ViewInteraction checkMicroPhoneState(boolean enable) {
    return checkLocalDrawable(
        CALL_AUDIO_SWITCH, enable ? CALL_AUDIO_SWITCH_ENABLE : CALL_AUDIO_SWITCH_DISABLE);
  }

  public static ViewInteraction clickSpeakerBtn() {
    return viewClick(CALL_SPEAKER_SWITCH);
  }

  public static ViewInteraction checkSpeakerState(boolean enable) {
    return checkLocalDrawable(
        CALL_SPEAKER_SWITCH, enable ? CALL_SPEAKER_SWITCH_ENABLE : CALL_SPEAKER_SWITCH_DISABLE);
  }

  public static ViewInteraction clickSwitchTypeBtn() {
    return viewClick(CALL_SWITCH_CALL_TYPE);
  }

  public static ViewInteraction checkSwitchType(int callType) {
    return checkLocalDrawable(
        CALL_SWITCH_CALL_TYPE,
        callType == ChannelType.AUDIO.getValue()
            ? CALL_SWITCH_CALL_TYPE_AUDIO
            : CALL_SWITCH_CALL_TYPE_VIDEO);
  }

  public static ViewInteraction clickMuteVideoBtn() {
    return viewClick(CALL_VIDEO_SWITCH);
  }

  public static ViewInteraction checkMuteVideoState(boolean enable) {
    return checkLocalDrawable(
        CALL_VIDEO_SWITCH, enable ? CALL_VIDEO_SWITCH_ENABLE : CALL_VIDEO_SWITCH_DISABLE);
  }

  public static ViewInteraction clickCallerSwitchTypeBtnWhenCall() {
    return viewClick(CALLER_SWITCH_CALL_TYPE);
  }

  public static ViewInteraction checkCallerSwitchTypeWhenCallState(int callType) {
    return checkLocalDrawable(
        CALLER_SWITCH_CALL_TYPE,
        callType == ChannelType.AUDIO.getValue()
            ? CALLER_SWITCH_CALL_TYPE_AUDIO
            : CALLER_SWITCH_CALL_TYPE_VIDEO);
  }

  public static ViewInteraction clickCallerMicroPhoneBtnWhenCall() {
    return viewClick(CALLER_AUDIO_SWITCH);
  }

  public static ViewInteraction checkCallerMicroPhoneWhenCallState(boolean enable) {
    return checkLocalDrawable(
        CALLER_AUDIO_SWITCH, enable ? CALLER_MICRO_PHONE_ENABLE : CALLER_MICRO_PHONE_DISABLE);
  }

  public static ViewInteraction clickCallerSpeakerWhenCall() {
    return viewClick(CALLER_SPEAKER_SWITCH);
  }

  public static ViewInteraction checkCallerSpeakerWhenCallState(boolean enable) {
    return checkLocalDrawable(
        CALLER_SPEAKER_SWITCH,
        enable ? CALLER_SPEAKER_SWITCH_ENABLE : CALLER_SPEAKER_SWITCH_DISABLE);
  }

  public static ViewInteraction clickCalleeSwitchTypeBtnWhenCall() {
    return viewClick(CALLEE_SWITCH_CALL_TYPE);
  }

  public static ViewInteraction checkCalleeSwitchTypeWhenCallState(int callType) {
    return checkLocalDrawable(
        CALLEE_SWITCH_CALL_TYPE,
        callType == ChannelType.AUDIO.getValue()
            ? CALLEE_SWITCH_CALL_TYPE_AUDIO
            : CALLEE_SWITCH_CALL_TYPE_VIDEO);
  }

  public static ViewInteraction clickCameraFlip() {
    return viewClick(CALL_CAMERA_FLIP);
  }

  public static ViewInteraction clickEndCallOption(boolean end) {
    return viewClick(withText(end ? "是" : "否"));
  }

  //------------------ self matcher method
  public static Matcher<RecentUserAdapter.ViewHolder> hasTextInHolderWithRecent(String text) {
    return new TypeSafeMatcher<RecentUserAdapter.ViewHolder>() {
      @Override
      protected boolean matchesSafely(RecentUserAdapter.ViewHolder customHolder) {
        return TextUtils.equals(customHolder.tvNickname.getText(), text);
      }

      @Override
      public void describeTo(Description description) {
        description.appendText("equals with text");
      }
    };
  }
}
