import { BinaryMessenger } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import {
  GroupCallKitApi,
  GroupCallKitEventSink,
  GroupSimpleResponse,
  GroupCallResponse,
  GroupAcceptResponse,
  GroupJoinResponse,
  GroupQueryCallInfoResponse,
  GroupQueryMembersResponse,
  NEGroupConfigParam,
  NEGroupCallParam,
  NEGroupAcceptParam,
  NEGroupHangupParam,
  NEGroupInviteParam,
  NEGroupJoinParam,
  NEGroupViewParam
} from './Pigeon';

const TAG = "GroupCallKitPlatform";

// Result 接口定义
interface Result<T> {
  success(value: T): void;
  error(error: Error): void;
}

// 辅助：构建成功的 GroupSimpleResponse
function okGroupSimple(): GroupSimpleResponse {
  return new GroupSimpleResponse(0, "Success");
}

// 辅助：构建失败的 GroupSimpleResponse
function errGroupSimple(code: number, msg: string): GroupSimpleResponse {
  return new GroupSimpleResponse(code, msg);
}

/**
 * GroupCallKitPlatform —— 群呼引擎平台实现
 * 目前返回 "not supported on ohos" 占位实现
 * 后续可以根据需求接入鸿蒙侧群呼 SDK
 */
export class GroupCallKitPlatform extends GroupCallKitApi {
  private eventSink: GroupCallKitEventSink;
  private context: common.Context;

  constructor(messenger: BinaryMessenger, context: common.Context) {
    super();
    this.context = context;
    this.eventSink = new GroupCallKitEventSink(messenger);
    console.info(`[${TAG}] GroupCallKitPlatform initialized`);
  }

  // ============================================================================
  // 初始化和释放
  // ============================================================================

  init(config: NEGroupConfigParam, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] init called`);
    // TODO: 接入鸿蒙侧群呼 SDK
    result.success(okGroupSimple());
  }

  release(result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] release called`);
    // TODO: 释放鸿蒙侧群呼资源
    result.success(okGroupSimple());
  }

  // ============================================================================
  // 通话控制
  // ============================================================================

  groupCall(param: NEGroupCallParam, result: Result<GroupCallResponse>): void {
    console.info(`[${TAG}] groupCall not supported on ohos`);
    result.error(new Error("not supported on ohos"));
  }

  groupAccept(param: NEGroupAcceptParam, result: Result<GroupAcceptResponse>): void {
    console.info(`[${TAG}] groupAccept not supported on ohos`);
    result.error(new Error("not supported on ohos"));
  }

  groupHangup(param: NEGroupHangupParam, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] groupHangup not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  groupInvite(param: NEGroupInviteParam, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] groupInvite not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  groupJoin(param: NEGroupJoinParam, result: Result<GroupJoinResponse>): void {
    console.info(`[${TAG}] groupJoin not supported on ohos`);
    result.error(new Error("not supported on ohos"));
  }

  // ============================================================================
  // 查询接口
  // ============================================================================

  groupQueryCallInfo(callId: string, result: Result<GroupQueryCallInfoResponse>): void {
    console.info(`[${TAG}] groupQueryCallInfo not supported on ohos`);
    result.error(new Error("not supported on ohos"));
  }

  groupQueryMembers(callId: string, result: Result<GroupQueryMembersResponse>): void {
    console.info(`[${TAG}] groupQueryMembers not supported on ohos`);
    result.error(new Error("not supported on ohos"));
  }

  // ============================================================================
  // 音视频控制
  // ============================================================================

  enableLocalVideo(enable: boolean, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] enableLocalVideo not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  muteLocalVideo(mute: boolean, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] muteLocalVideo not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  enableLocalAudio(enable: boolean, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] enableLocalAudio not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  muteLocalAudio(mute: boolean, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] muteLocalAudio not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  setSpeakerphoneOn(enable: boolean, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] setSpeakerphoneOn not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  isSpeakerphoneOn(result: Result<boolean>): void {
    console.info(`[${TAG}] isSpeakerphoneOn not supported on ohos`);
    result.success(false);
  }

  switchCamera(result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] switchCamera not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  // ============================================================================
  // 视图控制
  // ============================================================================

  setupLocalView(param: NEGroupViewParam, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] setupLocalView not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  setupRemoteView(param: NEGroupViewParam, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] setupRemoteView not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  // ============================================================================
  // 其他接口
  // ============================================================================

  enableAudioVolumeIndication(enable: boolean, interval: number, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] enableAudioVolumeIndication not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }

  setParameters(params: Map<string, Object>, result: Result<GroupSimpleResponse>): void {
    console.info(`[${TAG}] setParameters not supported on ohos`);
    result.success(errGroupSimple(-1, "not supported on ohos"));
  }
}
