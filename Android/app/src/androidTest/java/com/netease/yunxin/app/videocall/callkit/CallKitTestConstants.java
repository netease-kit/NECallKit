// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.callkit;

import com.netease.yunxin.app.videocall.R;

/** 呼叫组件中使用到的 id */
public final class CallKitTestConstants {
  /** view id 列表 */
  public interface ViewIds {
    int MAIN_P2P_CALL_ENTER = R.id.rly_video_call;

    int MAIN_USER_AVATAR = R.id.iv_account;

    int LOGIN_PHONE_INPUT = R.id.edt_account_id;

    /** 登录密码模块有更新，需要重新适配 */
    int LOGIN_SEND = R.id.edt_account_id;

    int LOGIN_VERIFY_CODE_INPUT_PARENT = R.id.vcv_sms;

    int LOGIN_NEXT = R.id.btn_next;

    int SEARCH_PHONE_INPUT = R.id.edt_account_id;

    int SEARCH_SEARCH = R.id.edt_account_id;

    int SEARCH_RESULT_GROUP = R.id.edt_account_id;

    int SEARCH_RECENT_GROUP = R.id.rv_recent_user;

    int SEARCH_RECORD_GROUP = R.id.rv_call_order;

    int CALL_CANCEL = R.id.ivCancel;

    int CALL_ACCEPT = R.id.ivAccept;

    int CALL_REJECT = R.id.ivReject;

    int CALL_HANGUP = R.id.ivHangUp;

    int CALL_AUDIO_SWITCH = R.id.ivMuteAudio;

    int CALL_SPEAKER_SWITCH = R.id.ivMuteSpeaker;

    int CALL_SWITCH_CALL_TYPE = R.id.ivCallChannelTypeChange;

    int CALL_VIDEO_SWITCH = R.id.ivMuteVideo;

    int CALL_CAMERA_FLIP = R.id.ivSwitchCamera;

    int CALLER_SWITCH_CALL_TYPE = R.id.ivCallSwitchType;

    int CALLER_AUDIO_SWITCH = R.id.ivCallMuteAudio;

    int CALLER_SPEAKER_SWITCH = R.id.ivCallSpeaker;

    int CALLEE_SWITCH_CALL_TYPE = R.id.ivSwitchType;
  }

  /** 文本内容 */
  public interface TextContent {}

  //--------------------- text ----------------------

  /** 图片资源 id 列表 */
  public interface DrawableRes {

    int CALLER_SWITCH_CALL_TYPE_VIDEO = R.drawable.icon_call_tip_video_to_audio;

    int CALLER_SWITCH_CALL_TYPE_AUDIO = R.drawable.icon_call_tip_audio_to_video;

    int CALLER_MICRO_PHONE_ENABLE = R.drawable.icon_call_audio_on;

    int CALLER_MICRO_PHONE_DISABLE = R.drawable.icon_call_audio_off;

    int CALLER_SPEAKER_SWITCH_ENABLE = R.drawable.icon_call_audio_speaker_on;

    int CALLER_SPEAKER_SWITCH_DISABLE = R.drawable.icon_call_audio_speaker_off;

    int CALL_SWITCH_CALL_TYPE_VIDEO = R.drawable.video_to_audio;

    int CALL_SWITCH_CALL_TYPE_AUDIO = R.drawable.audio_to_video;

    int CALL_AUDIO_SWITCH_ENABLE = R.drawable.voice_on;

    int CALL_AUDIO_SWITCH_DISABLE = R.drawable.voice_off;

    int CALL_SPEAKER_SWITCH_ENABLE = R.drawable.speaker_on;

    int CALL_SPEAKER_SWITCH_DISABLE = R.drawable.speaker_off;

    int CALL_VIDEO_SWITCH_ENABLE = R.drawable.cam_on;

    int CALL_VIDEO_SWITCH_DISABLE = R.drawable.cam_off;

    int CALLEE_SWITCH_CALL_TYPE_VIDEO = R.drawable.icon_call_tip_video_to_audio;

    int CALLEE_SWITCH_CALL_TYPE_AUDIO = R.drawable.icon_call_tip_audio_to_video;
  }
}
