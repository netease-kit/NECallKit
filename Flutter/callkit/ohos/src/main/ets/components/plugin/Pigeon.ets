import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import BasicMessageChannel, { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger,TaskQueue } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import { ByteBuffer } from '@ohos/flutter_ohos/src/main/ets/util/ByteBuffer';


/** Error class for passing custom error details to Flutter via a thrown PlatformException. */
export class FlutterError implements Error {

  /** The error code. */
  public code: string;

  /** The error name. */
  public name: string;

  /** The error message. */
  public message: string;
  /** The error stack. */
  public stack?: string;

  constructor(code: string, name: string,  message: string, stack: string) 
  {
    this.code = code;
    this.name = name;
    this.message = message;
    this.stack = stack;
  }
}

function wrapError(error: Error): Array<Object> {
  let errorList: Array<Object> = new Array<Object>(3);
  if (error instanceof FlutterError) {
    let err: FlutterError = error as FlutterError;
    errorList[0] = err.code;
    errorList[1] = err.name;
    errorList[2] = err.message;
  } else {
    errorList[0] = error.toString();
    errorList[1] = error.name;
    errorList[2] = "Cause: " + error.message + ", Stacktrace: " + error.stack;
  }
  return errorList;
}

export enum CallInitRtcMode {
  GLOBAL,
  IN_NEED,
  IN_NEED_DELAY_TO_ACCEPT
}

export enum CallType {
  NONE,
  AUDIO,
  VIDEO
}

export enum CallEngineStatus {
  IDLE,
  CALLING,
  CALLED,
  IN_CALL
}

export enum CallSwitchState {
  INVITE,
  AGREE,
  REJECT
}

export enum CallTerminalCode {
  NORMAL,
  TOKEN_ERROR,
  TIME_OUT,
  BUSY,
  RTC_INIT_ERROR,
  JOIN_RTC_ERROR,
  CANCEL_ERROR_PARAM,
  CALL_FAILED,
  KICKED,
  EMPTY_UID,
  RTC_DISCONNECTED,
  CALLER_CANCEL,
  CALLEE_CANCEL,
  CALLEE_REJECT,
  CALLER_REJECTED,
  HANG_UP,
  BE_HANG_UP,
  OTHER_REJECTED,
  OTHER_ACCEPTED,
  USER_RTC_DISCONNECTED,
  USER_RTC_LEAVE,
  ACCEPT_FAIL
}

export enum NIMRtcCallStatus {
  COMPLETED,
  CANCELLED,
  REJECTED,
  TIMEOUT,
  BUSY
}

export enum RtcVirtualBackgroundSourceStateReason {
  SUCCESS,
  FAILURE,
  NOT_SUPPORTED
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class SimpleResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private data1: number;

  getData1(): number {
    return this.data1;
  }

  private data2: number;

  getData2(): number {
    return this.data2;
  }

  private data3: string;

  getData3(): string {
    return this.data3;
  }

  constructor(code: number, msg: string, data1: number, data2: number, data3: string) {
    this.code = code;
    this.msg = msg;
    this.data1 = data1;
    this.data2 = data2;
    this.data3 = data3;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    arr.push(this.data1);
    arr.push(this.data2);
    arr.push(this.data3);
    return arr;
  }

  static fromList(arr: Object[]): SimpleResponse {
    let instance: SimpleResponse = new SimpleResponse(arr[0] as number, arr[1] as string, arr[2] as number, arr[3] as number, arr[4] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private callInfo: CallInfo | null;

  getCallInfo(): CallInfo | null {
    return this.callInfo;
  }

  constructor(code: number, msg: string, callInfo: CallInfo | null) {
    this.code = code;
    this.msg = msg;
    this.callInfo = callInfo;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    if (this.callInfo == null) {
      arr.push(null);
    } else if (this.callInfo instanceof Array) {
      arr.push(this.callInfo);
    } else {
      arr.push(this.callInfo.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): CallResponse {
    let instance: CallResponse = new CallResponse(arr[0] as number, arr[1] as string, arr[2] instanceof Array ? CallInfo.fromList(arr[2] as Object[]) : null);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class LCKConfig {
  private enableLiveCommunicationKit: boolean;

  getEnableLiveCommunicationKit(): boolean {
    return this.enableLiveCommunicationKit;
  }

  private ringtoneName: string;

  getRingtoneName(): string {
    return this.ringtoneName;
  }

  constructor(enableLiveCommunicationKit: boolean, ringtoneName: string) {
    this.enableLiveCommunicationKit = enableLiveCommunicationKit;
    this.ringtoneName = ringtoneName;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.enableLiveCommunicationKit);
    arr.push(this.ringtoneName);
    return arr;
  }

  static fromList(arr: Object[]): LCKConfig {
    let instance: LCKConfig = new LCKConfig(arr[0] as boolean, arr[1] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class SetupConfig {
  private appKey: string;

  getAppKey(): string {
    return this.appKey;
  }

  private currentUserRtcUid: number;

  getCurrentUserRtcUid(): number {
    return this.currentUserRtcUid;
  }

  private enableJoinRtcWhenCall: boolean;

  getEnableJoinRtcWhenCall(): boolean {
    return this.enableJoinRtcWhenCall;
  }

  private initRtcMode: CallInitRtcMode;

  getInitRtcMode(): CallInitRtcMode {
    return this.initRtcMode;
  }

  private lckConfig: LCKConfig | null;

  getLckConfig(): LCKConfig | null {
    return this.lckConfig;
  }

  constructor(appKey: string, currentUserRtcUid: number, enableJoinRtcWhenCall: boolean, initRtcMode: CallInitRtcMode, lckConfig: LCKConfig | null) {
    this.appKey = appKey;
    this.currentUserRtcUid = currentUserRtcUid;
    this.enableJoinRtcWhenCall = enableJoinRtcWhenCall;
    this.initRtcMode = initRtcMode;
    this.lckConfig = lckConfig;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.appKey);
    arr.push(this.currentUserRtcUid);
    arr.push(this.enableJoinRtcWhenCall);
    arr.push(this.initRtcMode);
    if (this.lckConfig == null) {
      arr.push(null);
    } else if (this.lckConfig instanceof Array) {
      arr.push(this.lckConfig);
    } else {
      arr.push(this.lckConfig.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): SetupConfig {
    let instance: SetupConfig = new SetupConfig(arr[0] as string, arr[1] as number, arr[2] as boolean, CallInitRtcMode[CallInitRtcMode[arr[3] as number]], arr[4] instanceof Array ? LCKConfig.fromList(arr[4] as Object[]) : null);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallParam {
  private accId: string;

  getAccId(): string {
    return this.accId;
  }

  private extraInfo: string;

  getExtraInfo(): string {
    return this.extraInfo;
  }

  private rtcChannelName: string;

  getRtcChannelName(): string {
    return this.rtcChannelName;
  }

  private globalExtraCopy: string;

  getGlobalExtraCopy(): string {
    return this.globalExtraCopy;
  }

  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private pushConfig: CallPushConfig | null;

  getPushConfig(): CallPushConfig | null {
    return this.pushConfig;
  }

  constructor(accId: string, extraInfo: string, rtcChannelName: string, globalExtraCopy: string, callType: CallType, pushConfig: CallPushConfig | null) {
    this.accId = accId;
    this.extraInfo = extraInfo;
    this.rtcChannelName = rtcChannelName;
    this.globalExtraCopy = globalExtraCopy;
    this.callType = callType;
    this.pushConfig = pushConfig;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.accId);
    arr.push(this.extraInfo);
    arr.push(this.rtcChannelName);
    arr.push(this.globalExtraCopy);
    arr.push(this.callType);
    if (this.pushConfig == null) {
      arr.push(null);
    } else if (this.pushConfig instanceof Array) {
      arr.push(this.pushConfig);
    } else {
      arr.push(this.pushConfig.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): CallParam {
    let instance: CallParam = new CallParam(arr[0] as string, arr[1] as string, arr[2] as string, arr[3] as string, CallType[CallType[arr[4] as number]], arr[5] instanceof Array ? CallPushConfig.fromList(arr[5] as Object[]) : null);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallPushConfig {
  private pushTitle: string;

  getPushTitle(): string {
    return this.pushTitle;
  }

  private pushContent: string;

  getPushContent(): string {
    return this.pushContent;
  }

  private pushPayload: string;

  getPushPayload(): string {
    return this.pushPayload;
  }

  private needBadge: boolean;

  getNeedBadge(): boolean {
    return this.needBadge;
  }

  private needPush: boolean;

  getNeedPush(): boolean {
    return this.needPush;
  }

  constructor(pushTitle: string, pushContent: string, pushPayload: string, needBadge: boolean, needPush: boolean) {
    this.pushTitle = pushTitle;
    this.pushContent = pushContent;
    this.pushPayload = pushPayload;
    this.needBadge = needBadge;
    this.needPush = needPush;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.pushTitle);
    arr.push(this.pushContent);
    arr.push(this.pushPayload);
    arr.push(this.needBadge);
    arr.push(this.needPush);
    return arr;
  }

  static fromList(arr: Object[]): CallPushConfig {
    let instance: CallPushConfig = new CallPushConfig(arr[0] as string, arr[1] as string, arr[2] as string, arr[3] as boolean, arr[4] as boolean);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class UserInfo {
  private accId: string;

  getAccId(): string {
    return this.accId;
  }

  private uid: number;

  getUid(): number {
    return this.uid;
  }

  constructor(accId: string, uid: number) {
    this.accId = accId;
    this.uid = uid;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.accId);
    arr.push(this.uid);
    return arr;
  }

  static fromList(arr: Object[]): UserInfo {
    let instance: UserInfo = new UserInfo(arr[0] as string, arr[1] as number);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class SignalInfo {
  private channelId: string;

  getChannelId(): string {
    return this.channelId;
  }

  private requestId: string;

  getRequestId(): string {
    return this.requestId;
  }

  private channelName: string;

  getChannelName(): string {
    return this.channelName;
  }

  private extraInfo: string;

  getExtraInfo(): string {
    return this.extraInfo;
  }

  private globalExtraCopy: string;

  getGlobalExtraCopy(): string {
    return this.globalExtraCopy;
  }

  constructor(channelId: string, requestId: string, channelName: string, extraInfo: string, globalExtraCopy: string) {
    this.channelId = channelId;
    this.requestId = requestId;
    this.channelName = channelName;
    this.extraInfo = extraInfo;
    this.globalExtraCopy = globalExtraCopy;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.channelId);
    arr.push(this.requestId);
    arr.push(this.channelName);
    arr.push(this.extraInfo);
    arr.push(this.globalExtraCopy);
    return arr;
  }

  static fromList(arr: Object[]): SignalInfo {
    let instance: SignalInfo = new SignalInfo(arr[0] as string, arr[1] as string, arr[2] as string, arr[3] as string, arr[4] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class RtcInfo {
  private channelName: string;

  getChannelName(): string {
    return this.channelName;
  }

  private token: string;

  getToken(): string {
    return this.token;
  }

  private uid: number;

  getUid(): number {
    return this.uid;
  }

  private cid: number;

  getCid(): number {
    return this.cid;
  }

  constructor(channelName: string, token: string, uid: number, cid: number) {
    this.channelName = channelName;
    this.token = token;
    this.uid = uid;
    this.cid = cid;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.channelName);
    arr.push(this.token);
    arr.push(this.uid);
    arr.push(this.cid);
    return arr;
  }

  static fromList(arr: Object[]): RtcInfo {
    let instance: RtcInfo = new RtcInfo(arr[0] as string, arr[1] as string, arr[2] as number, arr[3] as number);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallInfo {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private currentAccId: string;

  getCurrentAccId(): string {
    return this.currentAccId;
  }

  private callerInfo: UserInfo | null;

  getCallerInfo(): UserInfo | null {
    return this.callerInfo;
  }

  private calleeInfo: UserInfo | null;

  getCalleeInfo(): UserInfo | null {
    return this.calleeInfo;
  }

  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private signalInfo: SignalInfo | null;

  getSignalInfo(): SignalInfo | null {
    return this.signalInfo;
  }

  private rtcInfo: RtcInfo | null;

  getRtcInfo(): RtcInfo | null {
    return this.rtcInfo;
  }

  private callStatus: CallEngineStatus | null;

  getCallStatus(): CallEngineStatus | null {
    return this.callStatus;
  }

  constructor(callId: string, currentAccId: string, callerInfo: UserInfo | null, calleeInfo: UserInfo | null, callType: CallType, signalInfo: SignalInfo | null, rtcInfo: RtcInfo | null, callStatus: CallEngineStatus | null) {
    this.callId = callId;
    this.currentAccId = currentAccId;
    this.callerInfo = callerInfo;
    this.calleeInfo = calleeInfo;
    this.callType = callType;
    this.signalInfo = signalInfo;
    this.rtcInfo = rtcInfo;
    this.callStatus = callStatus;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.callId);
    arr.push(this.currentAccId);
    if (this.callerInfo == null) {
      arr.push(null);
    } else if (this.callerInfo instanceof Array) {
      arr.push(this.callerInfo);
    } else {
      arr.push(this.callerInfo.toList());
    }
    if (this.calleeInfo == null) {
      arr.push(null);
    } else if (this.calleeInfo instanceof Array) {
      arr.push(this.calleeInfo);
    } else {
      arr.push(this.calleeInfo.toList());
    }
    arr.push(this.callType);
    if (this.signalInfo == null) {
      arr.push(null);
    } else if (this.signalInfo instanceof Array) {
      arr.push(this.signalInfo);
    } else {
      arr.push(this.signalInfo.toList());
    }
    if (this.rtcInfo == null) {
      arr.push(null);
    } else if (this.rtcInfo instanceof Array) {
      arr.push(this.rtcInfo);
    } else {
      arr.push(this.rtcInfo.toList());
    }
    arr.push(this.callStatus);
    return arr;
  }

  static fromList(arr: Object[]): CallInfo {
    let instance: CallInfo = new CallInfo(arr[0] as string, arr[1] as string, arr[2] instanceof Array ? UserInfo.fromList(arr[2] as Object[]) : null, arr[3] instanceof Array ? UserInfo.fromList(arr[3] as Object[]) : null, CallType[CallType[arr[4] as number]], arr[5] instanceof Array ? SignalInfo.fromList(arr[5] as Object[]) : null, arr[6] instanceof Array ? RtcInfo.fromList(arr[6] as Object[]) : null, arr[7] != null ? CallEngineStatus[CallEngineStatus[arr[7] as number]] : null);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class HangupParam {
  private channelId: string;

  getChannelId(): string {
    return this.channelId;
  }

  private extraString: string;

  getExtraString(): string {
    return this.extraString;
  }

  constructor(channelId: string, extraString: string) {
    this.channelId = channelId;
    this.extraString = extraString;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.channelId);
    arr.push(this.extraString);
    return arr;
  }

  static fromList(arr: Object[]): HangupParam {
    let instance: HangupParam = new HangupParam(arr[0] as string, arr[1] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class SwitchParam {
  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private state: CallSwitchState;

  getState(): CallSwitchState {
    return this.state;
  }

  constructor(callType: CallType, state: CallSwitchState) {
    this.callType = callType;
    this.state = state;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callType);
    arr.push(this.state);
    return arr;
  }

  static fromList(arr: Object[]): SwitchParam {
    let instance: SwitchParam = new SwitchParam(CallType[CallType[arr[0] as number]], CallSwitchState[CallSwitchState[arr[1] as number]]);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallConfig {
  private enableOffline: boolean;

  getEnableOffline(): boolean {
    return this.enableOffline;
  }

  private enableSwitchVideoConfirm: boolean;

  getEnableSwitchVideoConfirm(): boolean {
    return this.enableSwitchVideoConfirm;
  }

  private enableSwitchAudioConfirm: boolean;

  getEnableSwitchAudioConfirm(): boolean {
    return this.enableSwitchAudioConfirm;
  }

  constructor(enableOffline: boolean, enableSwitchVideoConfirm: boolean, enableSwitchAudioConfirm: boolean) {
    this.enableOffline = enableOffline;
    this.enableSwitchVideoConfirm = enableSwitchVideoConfirm;
    this.enableSwitchAudioConfirm = enableSwitchAudioConfirm;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.enableOffline);
    arr.push(this.enableSwitchVideoConfirm);
    arr.push(this.enableSwitchAudioConfirm);
    return arr;
  }

  static fromList(arr: Object[]): CallConfig {
    let instance: CallConfig = new CallConfig(arr[0] as boolean, arr[1] as boolean, arr[2] as boolean);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class ViewParam {
  private viewId: number;

  getViewId(): number {
    return this.viewId;
  }

  constructor(viewId: number) {
    this.viewId = viewId;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.viewId);
    return arr;
  }

  static fromList(arr: Object[]): ViewParam {
    let instance: ViewParam = new ViewParam(arr[0] as number);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class InviteInfo {
  private callerAccId: string;

  getCallerAccId(): string {
    return this.callerAccId;
  }

  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private extraInfo: string;

  getExtraInfo(): string {
    return this.extraInfo;
  }

  private channelId: string;

  getChannelId(): string {
    return this.channelId;
  }

  constructor(callerAccId: string, callType: CallType, extraInfo: string, channelId: string) {
    this.callerAccId = callerAccId;
    this.callType = callType;
    this.extraInfo = extraInfo;
    this.channelId = channelId;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callerAccId);
    arr.push(this.callType);
    arr.push(this.extraInfo);
    arr.push(this.channelId);
    return arr;
  }

  static fromList(arr: Object[]): InviteInfo {
    let instance: InviteInfo = new InviteInfo(arr[0] as string, CallType[CallType[arr[1] as number]], arr[2] as string, arr[3] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallEndInfo {
  private reasonCode: CallTerminalCode;

  getReasonCode(): CallTerminalCode {
    return this.reasonCode;
  }

  private extraString: string;

  getExtraString(): string {
    return this.extraString;
  }

  private message: string;

  getMessage(): string {
    return this.message;
  }

  constructor(reasonCode: CallTerminalCode, extraString: string, message: string) {
    this.reasonCode = reasonCode;
    this.extraString = extraString;
    this.message = message;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.reasonCode);
    arr.push(this.extraString);
    arr.push(this.message);
    return arr;
  }

  static fromList(arr: Object[]): CallEndInfo {
    let instance: CallEndInfo = new CallEndInfo(CallTerminalCode[CallTerminalCode[arr[0] as number]], arr[1] as string, arr[2] as string);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class CallTypeChangeInfo {
  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private state: CallSwitchState;

  getState(): CallSwitchState {
    return this.state;
  }

  constructor(callType: CallType, state: CallSwitchState) {
    this.callType = callType;
    this.state = state;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callType);
    arr.push(this.state);
    return arr;
  }

  static fromList(arr: Object[]): CallTypeChangeInfo {
    let instance: CallTypeChangeInfo = new CallTypeChangeInfo(CallType[CallType[arr[0] as number]], CallSwitchState[CallSwitchState[arr[1] as number]]);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class RecordConfig {
  private accId: string;

  getAccId(): string {
    return this.accId;
  }

  private callType: CallType;

  getCallType(): CallType {
    return this.callType;
  }

  private callState: NIMRtcCallStatus;

  getCallState(): NIMRtcCallStatus {
    return this.callState;
  }

  constructor(accId: string, callType: CallType, callState: NIMRtcCallStatus) {
    this.accId = accId;
    this.callType = callType;
    this.callState = callState;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.accId);
    arr.push(this.callType);
    arr.push(this.callState);
    return arr;
  }

  static fromList(arr: Object[]): RecordConfig {
    let instance: RecordConfig = new RecordConfig(arr[0] as string, CallType[CallType[arr[1] as number]], NIMRtcCallStatus[NIMRtcCallStatus[arr[2] as number]]);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class NERtcASRCaptionConfig {
  private srcLanguage: string;

  getSrcLanguage(): string {
    return this.srcLanguage;
  }

  private srcLanguages: Array<string>;

  getSrcLanguages(): Array<string> {
    return this.srcLanguages;
  }

  private dstLanguage: string;

  getDstLanguage(): string {
    return this.dstLanguage;
  }

  private dstLanguages: Array<string>;

  getDstLanguages(): Array<string> {
    return this.dstLanguages;
  }

  private needTranslateSameLanguage: boolean;

  getNeedTranslateSameLanguage(): boolean {
    return this.needTranslateSameLanguage;
  }

  constructor(srcLanguage: string, srcLanguages: Array<string>, dstLanguage: string, dstLanguages: Array<string>, needTranslateSameLanguage: boolean) {
    this.srcLanguage = srcLanguage;
    this.srcLanguages = srcLanguages;
    this.dstLanguage = dstLanguage;
    this.dstLanguages = dstLanguages;
    this.needTranslateSameLanguage = needTranslateSameLanguage;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.srcLanguage);
    arr.push(this.srcLanguages);
    arr.push(this.dstLanguage);
    arr.push(this.dstLanguages);
    arr.push(this.needTranslateSameLanguage);
    return arr;
  }

  static fromList(arr: Object[]): NERtcASRCaptionConfig {
    let instance: NERtcASRCaptionConfig = new NERtcASRCaptionConfig(arr[0] as string, arr[1] as Array<string>, arr[2] as string, arr[3] as Array<string>, arr[4] as boolean);
    return instance;
  }
}

/* Generated class from Pigeon that represents data sent in messages.*/
export class NERtcAsrCaptionResult {
  private uid: number;

  getUid(): number {
    return this.uid;
  }

  private isLocalUser: boolean;

  getIsLocalUser(): boolean {
    return this.isLocalUser;
  }

  private timestamp: number;

  getTimestamp(): number {
    return this.timestamp;
  }

  private content: string;

  getContent(): string {
    return this.content;
  }

  private language: string;

  getLanguage(): string {
    return this.language;
  }

  private haveTranslation: boolean;

  getHaveTranslation(): boolean {
    return this.haveTranslation;
  }

  private translatedText: string;

  getTranslatedText(): string {
    return this.translatedText;
  }

  private translationLanguage: string;

  getTranslationLanguage(): string {
    return this.translationLanguage;
  }

  private isFinal: boolean;

  getIsFinal(): boolean {
    return this.isFinal;
  }

  constructor(uid: number, isLocalUser: boolean, timestamp: number, content: string, language: string, haveTranslation: boolean, translatedText: string, translationLanguage: string, isFinal: boolean) {
    this.uid = uid;
    this.isLocalUser = isLocalUser;
    this.timestamp = timestamp;
    this.content = content;
    this.language = language;
    this.haveTranslation = haveTranslation;
    this.translatedText = translatedText;
    this.translationLanguage = translationLanguage;
    this.isFinal = isFinal;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.uid);
    arr.push(this.isLocalUser);
    arr.push(this.timestamp);
    arr.push(this.content);
    arr.push(this.language);
    arr.push(this.haveTranslation);
    arr.push(this.translatedText);
    arr.push(this.translationLanguage);
    arr.push(this.isFinal);
    return arr;
  }

  static fromList(arr: Object[]): NERtcAsrCaptionResult {
    let instance: NERtcAsrCaptionResult = new NERtcAsrCaptionResult(arr[0] as number, arr[1] as boolean, arr[2] as number, arr[3] as string, arr[4] as string, arr[5] as boolean, arr[6] as string, arr[7] as string, arr[8] as boolean);
    return instance;
  }
}

/*
*  群呼引擎配置参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupConfigParam {
  private appKey: string;

  getAppKey(): string {
    return this.appKey;
  }

  private rtcSafeMode: number;

  getRtcSafeMode(): number {
    return this.rtcSafeMode;
  }

  private timeout: number;

  getTimeout(): number {
    return this.timeout;
  }

  private currentUserRtcUid: number;

  getCurrentUserRtcUid(): number {
    return this.currentUserRtcUid;
  }

  constructor(appKey: string, rtcSafeMode: number, timeout: number, currentUserRtcUid: number) {
    this.appKey = appKey;
    this.rtcSafeMode = rtcSafeMode;
    this.timeout = timeout;
    this.currentUserRtcUid = currentUserRtcUid;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.appKey);
    arr.push(this.rtcSafeMode);
    arr.push(this.timeout);
    arr.push(this.currentUserRtcUid);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupConfigParam {
    let instance: NEGroupConfigParam = new NEGroupConfigParam(arr[0] as string, arr[1] as number, arr[2] as number, arr[3] as number);
    return instance;
  }
}

/*
*  推送配置参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupPushParam {
  private pushContent: string;

  getPushContent(): string {
    return this.pushContent;
  }

  private pushPayload: string;

  getPushPayload(): string {
    return this.pushPayload;
  }

  private pushMode: number;

  getPushMode(): number {
    return this.pushMode;
  }

  private sound: string;

  getSound(): string {
    return this.sound;
  }

  constructor(pushContent: string, pushPayload: string, pushMode: number, sound: string) {
    this.pushContent = pushContent;
    this.pushPayload = pushPayload;
    this.pushMode = pushMode;
    this.sound = sound;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.pushContent);
    arr.push(this.pushPayload);
    arr.push(this.pushMode);
    arr.push(this.sound);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupPushParam {
    let instance: NEGroupPushParam = new NEGroupPushParam(arr[0] as string, arr[1] as string, arr[2] as number, arr[3] as string);
    return instance;
  }
}

/*
*  发起群呼参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupCallParam {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private calleeList: Array<string>;

  getCalleeList(): Array<string> {
    return this.calleeList;
  }

  private groupId: string;

  getGroupId(): string {
    return this.groupId;
  }

  private groupType: number;

  getGroupType(): number {
    return this.groupType;
  }

  private inviteMode: number;

  getInviteMode(): number {
    return this.inviteMode;
  }

  private joinMode: number;

  getJoinMode(): number {
    return this.joinMode;
  }

  private extraInfo: string;

  getExtraInfo(): string {
    return this.extraInfo;
  }

  private pushParam: NEGroupPushParam | null;

  getPushParam(): NEGroupPushParam | null {
    return this.pushParam;
  }

  constructor(callId: string, calleeList: Array<string>, groupId: string, groupType: number, inviteMode: number, joinMode: number, extraInfo: string, pushParam: NEGroupPushParam | null) {
    this.callId = callId;
    this.calleeList = calleeList;
    this.groupId = groupId;
    this.groupType = groupType;
    this.inviteMode = inviteMode;
    this.joinMode = joinMode;
    this.extraInfo = extraInfo;
    this.pushParam = pushParam;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.callId);
    arr.push(this.calleeList);
    arr.push(this.groupId);
    arr.push(this.groupType);
    arr.push(this.inviteMode);
    arr.push(this.joinMode);
    arr.push(this.extraInfo);
    if (this.pushParam == null) {
      arr.push(null);
    } else if (this.pushParam instanceof Array) {
      arr.push(this.pushParam);
    } else {
      arr.push(this.pushParam.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): NEGroupCallParam {
    let instance: NEGroupCallParam = new NEGroupCallParam(arr[0] as string, arr[1] as Array<string>, arr[2] as string, arr[3] as number, arr[4] as number, arr[5] as number, arr[6] as string, arr[7] instanceof Array ? NEGroupPushParam.fromList(arr[7] as Object[]) : null);
    return instance;
  }
}

/*
*  接听群呼参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupAcceptParam {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  constructor(callId: string) {
    this.callId = callId;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupAcceptParam {
    let instance: NEGroupAcceptParam = new NEGroupAcceptParam(arr[0] as string);
    return instance;
  }
}

/*
*  挂断群呼参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupHangupParam {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private reason: string;

  getReason(): string {
    return this.reason;
  }

  constructor(callId: string, reason: string) {
    this.callId = callId;
    this.reason = reason;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    arr.push(this.reason);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupHangupParam {
    let instance: NEGroupHangupParam = new NEGroupHangupParam(arr[0] as string, arr[1] as string);
    return instance;
  }
}

/*
*  邀请成员参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupInviteParam {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private calleeList: Array<string>;

  getCalleeList(): Array<string> {
    return this.calleeList;
  }

  constructor(callId: string, calleeList: Array<string>) {
    this.callId = callId;
    this.calleeList = calleeList;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    arr.push(this.calleeList);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupInviteParam {
    let instance: NEGroupInviteParam = new NEGroupInviteParam(arr[0] as string, arr[1] as Array<string>);
    return instance;
  }
}

/*
*  主动加入参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupJoinParam {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  constructor(callId: string) {
    this.callId = callId;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupJoinParam {
    let instance: NEGroupJoinParam = new NEGroupJoinParam(arr[0] as string);
    return instance;
  }
}

/*
*  群呼成员信息
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupCallMember {
  private accId: string;

  getAccId(): string {
    return this.accId;
  }

  private rtcUid: number;

  getRtcUid(): number {
    return this.rtcUid;
  }

  private state: number;

  getState(): number {
    return this.state;
  }

  private action: string;

  getAction(): string {
    return this.action;
  }

  private reason: string;

  getReason(): string {
    return this.reason;
  }

  constructor(accId: string, rtcUid: number, state: number, action: string, reason: string) {
    this.accId = accId;
    this.rtcUid = rtcUid;
    this.state = state;
    this.action = action;
    this.reason = reason;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.accId);
    arr.push(this.rtcUid);
    arr.push(this.state);
    arr.push(this.action);
    arr.push(this.reason);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupCallMember {
    let instance: NEGroupCallMember = new NEGroupCallMember(arr[0] as string, arr[1] as number, arr[2] as number, arr[3] as string, arr[4] as string);
    return instance;
  }
}

/*
*  群呼信息
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupCallInfo {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private groupId: string;

  getGroupId(): string {
    return this.groupId;
  }

  private groupType: number;

  getGroupType(): number {
    return this.groupType;
  }

  private callerAccId: string;

  getCallerAccId(): string {
    return this.callerAccId;
  }

  private callerRtcUid: number;

  getCallerRtcUid(): number {
    return this.callerRtcUid;
  }

  private memberList: Array<NEGroupCallMember>;

  getMemberList(): Array<NEGroupCallMember> {
    return this.memberList;
  }

  private inviteMode: number;

  getInviteMode(): number {
    return this.inviteMode;
  }

  private joinMode: number;

  getJoinMode(): number {
    return this.joinMode;
  }

  private extraInfo: string;

  getExtraInfo(): string {
    return this.extraInfo;
  }

  private startTimestamp: number;

  getStartTimestamp(): number {
    return this.startTimestamp;
  }

  constructor(callId: string, groupId: string, groupType: number, callerAccId: string, callerRtcUid: number, memberList: Array<NEGroupCallMember>, inviteMode: number, joinMode: number, extraInfo: string, startTimestamp: number) {
    this.callId = callId;
    this.groupId = groupId;
    this.groupType = groupType;
    this.callerAccId = callerAccId;
    this.callerRtcUid = callerRtcUid;
    this.memberList = memberList;
    this.inviteMode = inviteMode;
    this.joinMode = joinMode;
    this.extraInfo = extraInfo;
    this.startTimestamp = startTimestamp;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    arr.push(this.groupId);
    arr.push(this.groupType);
    arr.push(this.callerAccId);
    arr.push(this.callerRtcUid);
    arr.push(this.memberList);
    arr.push(this.inviteMode);
    arr.push(this.joinMode);
    arr.push(this.extraInfo);
    arr.push(this.startTimestamp);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupCallInfo {
    let instance: NEGroupCallInfo = new NEGroupCallInfo(arr[0] as string, arr[1] as string, arr[2] as number, arr[3] as string, arr[4] as number, arr[5] as Array<NEGroupCallMember>, arr[6] as number, arr[7] as number, arr[8] as string, arr[9] as number);
    return instance;
  }
}

/*
*  群呼结束事件
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupCallEndEvent {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private reason: number;

  getReason(): number {
    return this.reason;
  }

  private message: string;

  getMessage(): string {
    return this.message;
  }

  constructor(callId: string, reason: number, message: string) {
    this.callId = callId;
    this.reason = reason;
    this.message = message;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    arr.push(this.reason);
    arr.push(this.message);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupCallEndEvent {
    let instance: NEGroupCallEndEvent = new NEGroupCallEndEvent(arr[0] as string, arr[1] as number, arr[2] as string);
    return instance;
  }
}

/*
*  成员挂断事件
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupCallHangupEvent {
  private callId: string;

  getCallId(): string {
    return this.callId;
  }

  private reason: number;

  getReason(): number {
    return this.reason;
  }

  private message: string;

  getMessage(): string {
    return this.message;
  }

  constructor(callId: string, reason: number, message: string) {
    this.callId = callId;
    this.reason = reason;
    this.message = message;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.callId);
    arr.push(this.reason);
    arr.push(this.message);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupCallHangupEvent {
    let instance: NEGroupCallHangupEvent = new NEGroupCallHangupEvent(arr[0] as string, arr[1] as number, arr[2] as string);
    return instance;
  }
}

/*
*  音量信息
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEAudioVolumeInfo {
  private uid: number;

  getUid(): number {
    return this.uid;
  }

  private volume: number;

  getVolume(): number {
    return this.volume;
  }

  constructor(uid: number, volume: number) {
    this.uid = uid;
    this.volume = volume;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.uid);
    arr.push(this.volume);
    return arr;
  }

  static fromList(arr: Object[]): NEAudioVolumeInfo {
    let instance: NEAudioVolumeInfo = new NEAudioVolumeInfo(arr[0] as number, arr[1] as number);
    return instance;
  }
}

/*
*  群呼视图设置参数
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class NEGroupViewParam {
  private viewId: number;

  getViewId(): number {
    return this.viewId;
  }

  private uid: number;

  getUid(): number {
    return this.uid;
  }

  constructor(viewId: number, uid: number) {
    this.viewId = viewId;
    this.uid = uid;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.viewId);
    arr.push(this.uid);
    return arr;
  }

  static fromList(arr: Object[]): NEGroupViewParam {
    let instance: NEGroupViewParam = new NEGroupViewParam(arr[0] as number, arr[1] as number);
    return instance;
  }
}

/*
*  群呼简单响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupSimpleResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  constructor(code: number, msg: string) {
    this.code = code;
    this.msg = msg;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    return arr;
  }

  static fromList(arr: Object[]): GroupSimpleResponse {
    let instance: GroupSimpleResponse = new GroupSimpleResponse(arr[0] as number, arr[1] as string);
    return instance;
  }
}

/*
*  发起群呼响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupCallResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private callInfo: NEGroupCallInfo | null;

  getCallInfo(): NEGroupCallInfo | null {
    return this.callInfo;
  }

  constructor(code: number, msg: string, callInfo: NEGroupCallInfo | null) {
    this.code = code;
    this.msg = msg;
    this.callInfo = callInfo;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    if (this.callInfo == null) {
      arr.push(null);
    } else if (this.callInfo instanceof Array) {
      arr.push(this.callInfo);
    } else {
      arr.push(this.callInfo.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): GroupCallResponse {
    let instance: GroupCallResponse = new GroupCallResponse(arr[0] as number, arr[1] as string, arr[2] instanceof Array ? NEGroupCallInfo.fromList(arr[2] as Object[]) : null);
    return instance;
  }
}

/*
*  接听群呼响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupAcceptResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private callInfo: NEGroupCallInfo | null;

  getCallInfo(): NEGroupCallInfo | null {
    return this.callInfo;
  }

  constructor(code: number, msg: string, callInfo: NEGroupCallInfo | null) {
    this.code = code;
    this.msg = msg;
    this.callInfo = callInfo;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    if (this.callInfo == null) {
      arr.push(null);
    } else if (this.callInfo instanceof Array) {
      arr.push(this.callInfo);
    } else {
      arr.push(this.callInfo.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): GroupAcceptResponse {
    let instance: GroupAcceptResponse = new GroupAcceptResponse(arr[0] as number, arr[1] as string, arr[2] instanceof Array ? NEGroupCallInfo.fromList(arr[2] as Object[]) : null);
    return instance;
  }
}

/*
*  加入群呼响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupJoinResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private callInfo: NEGroupCallInfo | null;

  getCallInfo(): NEGroupCallInfo | null {
    return this.callInfo;
  }

  constructor(code: number, msg: string, callInfo: NEGroupCallInfo | null) {
    this.code = code;
    this.msg = msg;
    this.callInfo = callInfo;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    if (this.callInfo == null) {
      arr.push(null);
    } else if (this.callInfo instanceof Array) {
      arr.push(this.callInfo);
    } else {
      arr.push(this.callInfo.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): GroupJoinResponse {
    let instance: GroupJoinResponse = new GroupJoinResponse(arr[0] as number, arr[1] as string, arr[2] instanceof Array ? NEGroupCallInfo.fromList(arr[2] as Object[]) : null);
    return instance;
  }
}

/*
*  查询群呼信息响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupQueryCallInfoResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private callInfo: NEGroupCallInfo | null;

  getCallInfo(): NEGroupCallInfo | null {
    return this.callInfo;
  }

  constructor(code: number, msg: string, callInfo: NEGroupCallInfo | null) {
    this.code = code;
    this.msg = msg;
    this.callInfo = callInfo;
  }

  toList(): (Object | null)[] {
    let arr: (Object | null)[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    if (this.callInfo == null) {
      arr.push(null);
    } else if (this.callInfo instanceof Array) {
      arr.push(this.callInfo);
    } else {
      arr.push(this.callInfo.toList());
    }
    return arr;
  }

  static fromList(arr: Object[]): GroupQueryCallInfoResponse {
    let instance: GroupQueryCallInfoResponse = new GroupQueryCallInfoResponse(arr[0] as number, arr[1] as string, arr[2] instanceof Array ? NEGroupCallInfo.fromList(arr[2] as Object[]) : null);
    return instance;
  }
}

/*
*  查询成员列表响应
* 
*  Generated class from Pigeon that represents data sent in messages.
*/
export class GroupQueryMembersResponse {
  private code: number;

  getCode(): number {
    return this.code;
  }

  private msg: string;

  getMsg(): string {
    return this.msg;
  }

  private members: Array<NEGroupCallMember>;

  getMembers(): Array<NEGroupCallMember> {
    return this.members;
  }

  constructor(code: number, msg: string, members: Array<NEGroupCallMember>) {
    this.code = code;
    this.msg = msg;
    this.members = members;
  }

  toList(): Object[] {
    let arr: Object[] = new Array();
    arr.push(this.code);
    arr.push(this.msg);
    arr.push(this.members);
    return arr;
  }

  static fromList(arr: Object[]): GroupQueryMembersResponse {
    let instance: GroupQueryMembersResponse = new GroupQueryMembersResponse(arr[0] as number, arr[1] as string, arr[2] as Array<NEGroupCallMember>);
    return instance;
  }
}

export interface Result<T> {
  success( result: T ): void;

  error( error: Error): void;
}

class CallKitApiCodec extends StandardMessageCodec {
  static INSTANCE: CallKitApiCodec = new CallKitApiCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(128):
        return CallConfig.fromList(super.readValue(buffer));
      case this.getByte(129):
        return CallConfig.fromList(super.readValue(buffer));
      case this.getByte(130):
        return CallInfo.fromList(super.readValue(buffer));
      case this.getByte(131):
        return CallParam.fromList(super.readValue(buffer));
      case this.getByte(132):
        return CallPushConfig.fromList(super.readValue(buffer));
      case this.getByte(133):
        return CallResponse.fromList(super.readValue(buffer));
      case this.getByte(134):
        return HangupParam.fromList(super.readValue(buffer));
      case this.getByte(135):
        return LCKConfig.fromList(super.readValue(buffer));
      case this.getByte(136):
        return NERtcASRCaptionConfig.fromList(super.readValue(buffer));
      case this.getByte(137):
        return RtcInfo.fromList(super.readValue(buffer));
      case this.getByte(138):
        return SetupConfig.fromList(super.readValue(buffer));
      case this.getByte(139):
        return SignalInfo.fromList(super.readValue(buffer));
      case this.getByte(140):
        return SimpleResponse.fromList(super.readValue(buffer));
      case this.getByte(141):
        return SwitchParam.fromList(super.readValue(buffer));
      case this.getByte(142):
        return UserInfo.fromList(super.readValue(buffer));
      case this.getByte(143):
        return ViewParam.fromList(super.readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof CallConfig) {
      stream.writeUint8(this.getByte(128));
      this.writeValue(stream, (value as CallConfig).toList());
    } else if (value instanceof CallConfig) {
      stream.writeUint8(this.getByte(129));
      this.writeValue(stream, (value as CallConfig).toList());
    } else if (value instanceof CallInfo) {
      stream.writeUint8(this.getByte(130));
      this.writeValue(stream, (value as CallInfo).toList());
    } else if (value instanceof CallParam) {
      stream.writeUint8(this.getByte(131));
      this.writeValue(stream, (value as CallParam).toList());
    } else if (value instanceof CallPushConfig) {
      stream.writeUint8(this.getByte(132));
      this.writeValue(stream, (value as CallPushConfig).toList());
    } else if (value instanceof CallResponse) {
      stream.writeUint8(this.getByte(133));
      this.writeValue(stream, (value as CallResponse).toList());
    } else if (value instanceof HangupParam) {
      stream.writeUint8(this.getByte(134));
      this.writeValue(stream, (value as HangupParam).toList());
    } else if (value instanceof LCKConfig) {
      stream.writeUint8(this.getByte(135));
      this.writeValue(stream, (value as LCKConfig).toList());
    } else if (value instanceof NERtcASRCaptionConfig) {
      stream.writeUint8(this.getByte(136));
      this.writeValue(stream, (value as NERtcASRCaptionConfig).toList());
    } else if (value instanceof RtcInfo) {
      stream.writeUint8(this.getByte(137));
      this.writeValue(stream, (value as RtcInfo).toList());
    } else if (value instanceof SetupConfig) {
      stream.writeUint8(this.getByte(138));
      this.writeValue(stream, (value as SetupConfig).toList());
    } else if (value instanceof SignalInfo) {
      stream.writeUint8(this.getByte(139));
      this.writeValue(stream, (value as SignalInfo).toList());
    } else if (value instanceof SimpleResponse) {
      stream.writeUint8(this.getByte(140));
      this.writeValue(stream, (value as SimpleResponse).toList());
    } else if (value instanceof SwitchParam) {
      stream.writeUint8(this.getByte(141));
      this.writeValue(stream, (value as SwitchParam).toList());
    } else if (value instanceof UserInfo) {
      stream.writeUint8(this.getByte(142));
      this.writeValue(stream, (value as UserInfo).toList());
    } else if (value instanceof ViewParam) {
      stream.writeUint8(this.getByte(143));
      this.writeValue(stream, (value as ViewParam).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

/* Generated abstract class from Pigeon that represents a handler of messages from Flutter.*/
export abstract class CallKitApi {

  abstract setup(config: SetupConfig , result: Result<SimpleResponse>): void;

  abstract getVersion(): string;

  abstract call(param: CallParam , result: Result<CallResponse>): void;

  abstract accept(result: Result<CallResponse>): void;

  abstract hangup(param: HangupParam , result: Result<SimpleResponse>): void;

  abstract switchCallType(param: SwitchParam , result: Result<SimpleResponse>): void;

  abstract setTimeout(time: number , result: Result<SimpleResponse>): void;

  abstract setupLocalView(param: ViewParam , result: Result<SimpleResponse>): void;

  abstract setupRemoteView(param: ViewParam , result: Result<SimpleResponse>): void;

  abstract enableLocalVideo(enable: boolean , result: Result<SimpleResponse>): void;

  abstract muteLocalVideo(muted: boolean , result: Result<SimpleResponse>): void;

  abstract muteLocalAudio(muted: boolean , result: Result<SimpleResponse>): void;

  abstract switchCamera(result: Result<SimpleResponse>): void;

  abstract isSpeakerphoneOn(result: Result<boolean>): void;

  abstract setSpeakerphoneOn(enable: boolean , result: Result<SimpleResponse>): void;

  abstract setCallConfig(config: CallConfig , result: Result<SimpleResponse>): void;

  abstract getCallInfo(result: Result<CallInfo>): void;

  abstract getCallConfig(result: Result<CallConfig>): void;

  abstract destroy(result: Result<SimpleResponse>): void;

  abstract startASRCaption(config: NERtcASRCaptionConfig , result: Result<SimpleResponse>): void;

  abstract stopASRCaption(result: Result<SimpleResponse>): void;

  abstract getUserWithRtcUid(uid: number , result: Result<UserInfo>): void;

  abstract setCallRecordProvider(enable: boolean , result: Result<SimpleResponse>): void;
  /** The codec used by CallKitApi. */
  static getCodec(): MessageCodec<Object>{
    return CallKitApiCodec.INSTANCE;
  }
  /*Sets up an instance of `CallKitApi` to handle messages through the `binaryMessenger`.*/
  static setup(binaryMessenger: BinaryMessenger, api: CallKitApi | null): void {
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setup", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setup(args[0] as SetupConfig, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.getVersion", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let res: Array<Object> = [];
              try {
                let output: string = api!.getVersion();
                res.push(output);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.call", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<CallResponse>{
                    success(result: CallResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<CallResponse> = new ResultImp();

              api!.call(args[0] as CallParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.accept", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<CallResponse>{
                    success(result: CallResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<CallResponse> = new ResultImp();

              api!.accept(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.hangup", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.hangup(args[0] as HangupParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.switchCallType", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.switchCallType(args[0] as SwitchParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setTimeout", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setTimeout(args[0] as number, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setupLocalView", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setupLocalView(args[0] as ViewParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setupRemoteView", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setupRemoteView(args[0] as ViewParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.enableLocalVideo", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.enableLocalVideo(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.muteLocalVideo", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.muteLocalVideo(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.muteLocalAudio", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.muteLocalAudio(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.switchCamera", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.switchCamera(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.isSpeakerphoneOn", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<boolean>{
                    success(result: boolean): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<boolean> = new ResultImp();

              api!.isSpeakerphoneOn(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setSpeakerphoneOn", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setSpeakerphoneOn(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setCallConfig", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setCallConfig(args[0] as CallConfig, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.getCallInfo", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<CallInfo>{
                    success(result: CallInfo): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<CallInfo> = new ResultImp();

              api!.getCallInfo(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.getCallConfig", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<CallConfig>{
                    success(result: CallConfig): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<CallConfig> = new ResultImp();

              api!.getCallConfig(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.destroy", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.destroy(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.startASRCaption", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.startASRCaption(args[0] as NERtcASRCaptionConfig, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.stopASRCaption", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.stopASRCaption(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.getUserWithRtcUid", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<UserInfo>{
                    success(result: UserInfo): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<UserInfo> = new ResultImp();

              api!.getUserWithRtcUid(args[0] as number, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallKitApi.setCallRecordProvider", CallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<SimpleResponse>{
                    success(result: SimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<SimpleResponse> = new ResultImp();

              api!.setCallRecordProvider(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
  }
}

class CallKitEventSinkCodec extends StandardMessageCodec {
  static INSTANCE: CallKitEventSinkCodec = new CallKitEventSinkCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(128):
        return CallEndInfo.fromList(super.readValue(buffer));
      case this.getByte(129):
        return CallInfo.fromList(super.readValue(buffer));
      case this.getByte(130):
        return CallResponse.fromList(super.readValue(buffer));
      case this.getByte(131):
        return CallTypeChangeInfo.fromList(super.readValue(buffer));
      case this.getByte(132):
        return InviteInfo.fromList(super.readValue(buffer));
      case this.getByte(133):
        return NERtcAsrCaptionResult.fromList(super.readValue(buffer));
      case this.getByte(134):
        return RecordConfig.fromList(super.readValue(buffer));
      case this.getByte(135):
        return RtcInfo.fromList(super.readValue(buffer));
      case this.getByte(136):
        return SignalInfo.fromList(super.readValue(buffer));
      case this.getByte(137):
        return SimpleResponse.fromList(super.readValue(buffer));
      case this.getByte(138):
        return UserInfo.fromList(super.readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof CallEndInfo) {
      stream.writeUint8(this.getByte(128));
      this.writeValue(stream, (value as CallEndInfo).toList());
    } else if (value instanceof CallInfo) {
      stream.writeUint8(this.getByte(129));
      this.writeValue(stream, (value as CallInfo).toList());
    } else if (value instanceof CallResponse) {
      stream.writeUint8(this.getByte(130));
      this.writeValue(stream, (value as CallResponse).toList());
    } else if (value instanceof CallTypeChangeInfo) {
      stream.writeUint8(this.getByte(131));
      this.writeValue(stream, (value as CallTypeChangeInfo).toList());
    } else if (value instanceof InviteInfo) {
      stream.writeUint8(this.getByte(132));
      this.writeValue(stream, (value as InviteInfo).toList());
    } else if (value instanceof NERtcAsrCaptionResult) {
      stream.writeUint8(this.getByte(133));
      this.writeValue(stream, (value as NERtcAsrCaptionResult).toList());
    } else if (value instanceof RecordConfig) {
      stream.writeUint8(this.getByte(134));
      this.writeValue(stream, (value as RecordConfig).toList());
    } else if (value instanceof RtcInfo) {
      stream.writeUint8(this.getByte(135));
      this.writeValue(stream, (value as RtcInfo).toList());
    } else if (value instanceof SignalInfo) {
      stream.writeUint8(this.getByte(136));
      this.writeValue(stream, (value as SignalInfo).toList());
    } else if (value instanceof SimpleResponse) {
      stream.writeUint8(this.getByte(137));
      this.writeValue(stream, (value as SimpleResponse).toList());
    } else if (value instanceof UserInfo) {
      stream.writeUint8(this.getByte(138));
      this.writeValue(stream, (value as UserInfo).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

/* Generated class from Pigeon that represents Flutter messages that can be called from ArkTS.*/
export class CallKitEventSink {
  binaryMessenger: BinaryMessenger;

  constructor(binaryMessenger: BinaryMessenger) {
    this.binaryMessenger = binaryMessenger;
  }

  /** The codec used by CallKitEventSink. */
  static getCodec(): MessageCodec<Object> {
    return CallKitEventSinkCodec.INSTANCE;
  }

  onReceiveInvited(infoArg: InviteInfo, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onReceiveInvited", CallKitEventSink.getCodec());
    channel.send(
        [infoArg],
        channelReply => callback.reply(null));
  }
  onCallEnd(infoArg: CallEndInfo, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onCallEnd", CallKitEventSink.getCodec());
    channel.send(
        [infoArg],
        channelReply => callback.reply(null));
  }
  onCallConnected(infoArg: CallInfo, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onCallConnected", CallKitEventSink.getCodec());
    channel.send(
        [infoArg],
        channelReply => callback.reply(null));
  }
  onLCKAccept(responseArg: CallResponse, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> =
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onLCKAccept", CallKitEventSink.getCodec());
    channel.send(
        [responseArg],
        channelReply => callback.reply(null));
  }
  onLCKHangup(responseArg: SimpleResponse, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> =
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onLCKHangup", CallKitEventSink.getCodec());
    channel.send(
        [responseArg],
        channelReply => callback.reply(null));
  }
  onCallTypeChange(infoArg: CallTypeChangeInfo, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onCallTypeChange", CallKitEventSink.getCodec());
    channel.send(
        [infoArg],
        channelReply => callback.reply(null));
  }
  onVideoAvailable(availableArg: boolean,userIDArg: string, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onVideoAvailable", CallKitEventSink.getCodec());
    channel.send(
        [availableArg, userIDArg],
        channelReply => callback.reply(null));
  }
  onVideoMuted(mutedArg: boolean,userIDArg: string, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onVideoMuted", CallKitEventSink.getCodec());
    channel.send(
        [mutedArg, userIDArg],
        channelReply => callback.reply(null));
  }
  onAudioMuted(mutedArg: boolean,userIDArg: string, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onAudioMuted", CallKitEventSink.getCodec());
    channel.send(
        [mutedArg, userIDArg],
        channelReply => callback.reply(null));
  }
  onLocalAudioMuted(mutedArg: boolean, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onLocalAudioMuted", CallKitEventSink.getCodec());
    channel.send(
        [mutedArg],
        channelReply => callback.reply(null));
  }
  onRtcInitEnd(callback: Reply<void>):void {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onRtcInitEnd", CallKitEventSink.getCodec());
    channel.send(
        null,
        channelReply => callback.reply(null));
  }
  onRecordSend(configArg: RecordConfig, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onRecordSend", CallKitEventSink.getCodec());
    channel.send(
        [configArg],
        channelReply => callback.reply(null));
  }
  onNERtcEngineVirtualBackgroundSourceEnabled(enabledArg: boolean,reasonArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onNERtcEngineVirtualBackgroundSourceEnabled", CallKitEventSink.getCodec());
    channel.send(
        [enabledArg, reasonArg],
        channelReply => callback.reply(null));
  }
  onAsrCaptionStateChanged(asrStateArg: number,codeArg: number,messageArg: string, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onAsrCaptionStateChanged", CallKitEventSink.getCodec());
    channel.send(
        [asrStateArg, codeArg, messageArg],
        channelReply => callback.reply(null));
  }
  onAsrCaptionResult(resultArg: Array<NERtcAsrCaptionResult>, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.CallKitEventSink.onAsrCaptionResult", CallKitEventSink.getCodec());
    channel.send(
        [resultArg],
        channelReply => callback.reply(null));
  }
}

class GroupCallKitApiCodec extends StandardMessageCodec {
  static INSTANCE: GroupCallKitApiCodec = new GroupCallKitApiCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(128):
        return CallConfig.fromList(super.readValue(buffer));
      case this.getByte(129):
        return CallEndInfo.fromList(super.readValue(buffer));
      case this.getByte(130):
        return CallInfo.fromList(super.readValue(buffer));
      case this.getByte(131):
        return CallParam.fromList(super.readValue(buffer));
      case this.getByte(132):
        return CallPushConfig.fromList(super.readValue(buffer));
      case this.getByte(133):
        return CallResponse.fromList(super.readValue(buffer));
      case this.getByte(134):
        return CallTypeChangeInfo.fromList(super.readValue(buffer));
      case this.getByte(135):
        return GroupAcceptResponse.fromList(super.readValue(buffer));
      case this.getByte(136):
        return GroupCallResponse.fromList(super.readValue(buffer));
      case this.getByte(137):
        return GroupJoinResponse.fromList(super.readValue(buffer));
      case this.getByte(138):
        return GroupQueryCallInfoResponse.fromList(super.readValue(buffer));
      case this.getByte(139):
        return GroupQueryMembersResponse.fromList(super.readValue(buffer));
      case this.getByte(140):
        return GroupSimpleResponse.fromList(super.readValue(buffer));
      case this.getByte(141):
        return HangupParam.fromList(super.readValue(buffer));
      case this.getByte(142):
        return InviteInfo.fromList(super.readValue(buffer));
      case this.getByte(143):
        return LCKConfig.fromList(super.readValue(buffer));
      case this.getByte(144):
        return NEAudioVolumeInfo.fromList(super.readValue(buffer));
      case this.getByte(145):
        return NEGroupAcceptParam.fromList(super.readValue(buffer));
      case this.getByte(146):
        return NEGroupCallEndEvent.fromList(super.readValue(buffer));
      case this.getByte(147):
        return NEGroupCallHangupEvent.fromList(super.readValue(buffer));
      case this.getByte(148):
        return NEGroupCallInfo.fromList(super.readValue(buffer));
      case this.getByte(149):
        return NEGroupCallMember.fromList(super.readValue(buffer));
      case this.getByte(150):
        return NEGroupCallParam.fromList(super.readValue(buffer));
      case this.getByte(151):
        return NEGroupConfigParam.fromList(super.readValue(buffer));
      case this.getByte(152):
        return NEGroupHangupParam.fromList(super.readValue(buffer));
      case this.getByte(153):
        return NEGroupInviteParam.fromList(super.readValue(buffer));
      case this.getByte(154):
        return NEGroupJoinParam.fromList(super.readValue(buffer));
      case this.getByte(155):
        return NEGroupPushParam.fromList(super.readValue(buffer));
      case this.getByte(156):
        return NEGroupViewParam.fromList(super.readValue(buffer));
      case this.getByte(157):
        return NERtcASRCaptionConfig.fromList(super.readValue(buffer));
      case this.getByte(158):
        return NERtcAsrCaptionResult.fromList(super.readValue(buffer));
      case this.getByte(159):
        return RecordConfig.fromList(super.readValue(buffer));
      case this.getByte(160):
        return RtcInfo.fromList(super.readValue(buffer));
      case this.getByte(161):
        return SetupConfig.fromList(super.readValue(buffer));
      case this.getByte(162):
        return SignalInfo.fromList(super.readValue(buffer));
      case this.getByte(163):
        return SimpleResponse.fromList(super.readValue(buffer));
      case this.getByte(164):
        return SwitchParam.fromList(super.readValue(buffer));
      case this.getByte(165):
        return UserInfo.fromList(super.readValue(buffer));
      case this.getByte(166):
        return ViewParam.fromList(super.readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof CallConfig) {
      stream.writeUint8(this.getByte(128));
      this.writeValue(stream, (value as CallConfig).toList());
    } else if (value instanceof CallEndInfo) {
      stream.writeUint8(this.getByte(129));
      this.writeValue(stream, (value as CallEndInfo).toList());
    } else if (value instanceof CallInfo) {
      stream.writeUint8(this.getByte(130));
      this.writeValue(stream, (value as CallInfo).toList());
    } else if (value instanceof CallParam) {
      stream.writeUint8(this.getByte(131));
      this.writeValue(stream, (value as CallParam).toList());
    } else if (value instanceof CallPushConfig) {
      stream.writeUint8(this.getByte(132));
      this.writeValue(stream, (value as CallPushConfig).toList());
    } else if (value instanceof CallResponse) {
      stream.writeUint8(this.getByte(133));
      this.writeValue(stream, (value as CallResponse).toList());
    } else if (value instanceof CallTypeChangeInfo) {
      stream.writeUint8(this.getByte(134));
      this.writeValue(stream, (value as CallTypeChangeInfo).toList());
    } else if (value instanceof GroupAcceptResponse) {
      stream.writeUint8(this.getByte(135));
      this.writeValue(stream, (value as GroupAcceptResponse).toList());
    } else if (value instanceof GroupCallResponse) {
      stream.writeUint8(this.getByte(136));
      this.writeValue(stream, (value as GroupCallResponse).toList());
    } else if (value instanceof GroupJoinResponse) {
      stream.writeUint8(this.getByte(137));
      this.writeValue(stream, (value as GroupJoinResponse).toList());
    } else if (value instanceof GroupQueryCallInfoResponse) {
      stream.writeUint8(this.getByte(138));
      this.writeValue(stream, (value as GroupQueryCallInfoResponse).toList());
    } else if (value instanceof GroupQueryMembersResponse) {
      stream.writeUint8(this.getByte(139));
      this.writeValue(stream, (value as GroupQueryMembersResponse).toList());
    } else if (value instanceof GroupSimpleResponse) {
      stream.writeUint8(this.getByte(140));
      this.writeValue(stream, (value as GroupSimpleResponse).toList());
    } else if (value instanceof HangupParam) {
      stream.writeUint8(this.getByte(141));
      this.writeValue(stream, (value as HangupParam).toList());
    } else if (value instanceof InviteInfo) {
      stream.writeUint8(this.getByte(142));
      this.writeValue(stream, (value as InviteInfo).toList());
    } else if (value instanceof LCKConfig) {
      stream.writeUint8(this.getByte(143));
      this.writeValue(stream, (value as LCKConfig).toList());
    } else if (value instanceof NEAudioVolumeInfo) {
      stream.writeUint8(this.getByte(144));
      this.writeValue(stream, (value as NEAudioVolumeInfo).toList());
    } else if (value instanceof NEGroupAcceptParam) {
      stream.writeUint8(this.getByte(145));
      this.writeValue(stream, (value as NEGroupAcceptParam).toList());
    } else if (value instanceof NEGroupCallEndEvent) {
      stream.writeUint8(this.getByte(146));
      this.writeValue(stream, (value as NEGroupCallEndEvent).toList());
    } else if (value instanceof NEGroupCallHangupEvent) {
      stream.writeUint8(this.getByte(147));
      this.writeValue(stream, (value as NEGroupCallHangupEvent).toList());
    } else if (value instanceof NEGroupCallInfo) {
      stream.writeUint8(this.getByte(148));
      this.writeValue(stream, (value as NEGroupCallInfo).toList());
    } else if (value instanceof NEGroupCallMember) {
      stream.writeUint8(this.getByte(149));
      this.writeValue(stream, (value as NEGroupCallMember).toList());
    } else if (value instanceof NEGroupCallParam) {
      stream.writeUint8(this.getByte(150));
      this.writeValue(stream, (value as NEGroupCallParam).toList());
    } else if (value instanceof NEGroupConfigParam) {
      stream.writeUint8(this.getByte(151));
      this.writeValue(stream, (value as NEGroupConfigParam).toList());
    } else if (value instanceof NEGroupHangupParam) {
      stream.writeUint8(this.getByte(152));
      this.writeValue(stream, (value as NEGroupHangupParam).toList());
    } else if (value instanceof NEGroupInviteParam) {
      stream.writeUint8(this.getByte(153));
      this.writeValue(stream, (value as NEGroupInviteParam).toList());
    } else if (value instanceof NEGroupJoinParam) {
      stream.writeUint8(this.getByte(154));
      this.writeValue(stream, (value as NEGroupJoinParam).toList());
    } else if (value instanceof NEGroupPushParam) {
      stream.writeUint8(this.getByte(155));
      this.writeValue(stream, (value as NEGroupPushParam).toList());
    } else if (value instanceof NEGroupViewParam) {
      stream.writeUint8(this.getByte(156));
      this.writeValue(stream, (value as NEGroupViewParam).toList());
    } else if (value instanceof NERtcASRCaptionConfig) {
      stream.writeUint8(this.getByte(157));
      this.writeValue(stream, (value as NERtcASRCaptionConfig).toList());
    } else if (value instanceof NERtcAsrCaptionResult) {
      stream.writeUint8(this.getByte(158));
      this.writeValue(stream, (value as NERtcAsrCaptionResult).toList());
    } else if (value instanceof RecordConfig) {
      stream.writeUint8(this.getByte(159));
      this.writeValue(stream, (value as RecordConfig).toList());
    } else if (value instanceof RtcInfo) {
      stream.writeUint8(this.getByte(160));
      this.writeValue(stream, (value as RtcInfo).toList());
    } else if (value instanceof SetupConfig) {
      stream.writeUint8(this.getByte(161));
      this.writeValue(stream, (value as SetupConfig).toList());
    } else if (value instanceof SignalInfo) {
      stream.writeUint8(this.getByte(162));
      this.writeValue(stream, (value as SignalInfo).toList());
    } else if (value instanceof SimpleResponse) {
      stream.writeUint8(this.getByte(163));
      this.writeValue(stream, (value as SimpleResponse).toList());
    } else if (value instanceof SwitchParam) {
      stream.writeUint8(this.getByte(164));
      this.writeValue(stream, (value as SwitchParam).toList());
    } else if (value instanceof UserInfo) {
      stream.writeUint8(this.getByte(165));
      this.writeValue(stream, (value as UserInfo).toList());
    } else if (value instanceof ViewParam) {
      stream.writeUint8(this.getByte(166));
      this.writeValue(stream, (value as ViewParam).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

/* Generated abstract class from Pigeon that represents a handler of messages from Flutter.*/
export abstract class GroupCallKitApi {
  /* 初始化群呼引擎*/
  abstract init(config: NEGroupConfigParam , result: Result<GroupSimpleResponse>): void;
  /* 释放群呼引擎*/
  abstract release(result: Result<GroupSimpleResponse>): void;
  /* 发起群呼*/
  abstract groupCall(param: NEGroupCallParam , result: Result<GroupCallResponse>): void;
  /* 接听群呼*/
  abstract groupAccept(param: NEGroupAcceptParam , result: Result<GroupAcceptResponse>): void;
  /* 挂断/拒绝群呼*/
  abstract groupHangup(param: NEGroupHangupParam , result: Result<GroupSimpleResponse>): void;
  /* 邀请新成员*/
  abstract groupInvite(param: NEGroupInviteParam , result: Result<GroupSimpleResponse>): void;
  /* 主动加入群呼*/
  abstract groupJoin(param: NEGroupJoinParam , result: Result<GroupJoinResponse>): void;
  /* 查询群呼信息*/
  abstract groupQueryCallInfo(callId: string , result: Result<GroupQueryCallInfoResponse>): void;
  /* 查询成员列表*/
  abstract groupQueryMembers(callId: string , result: Result<GroupQueryMembersResponse>): void;
  /* 开关本端视频采集*/
  abstract enableLocalVideo(enable: boolean , result: Result<GroupSimpleResponse>): void;
  /* 静音本端视频发送*/
  abstract muteLocalVideo(mute: boolean , result: Result<GroupSimpleResponse>): void;
  /* 开关本端音频采集和发送*/
  abstract enableLocalAudio(enable: boolean , result: Result<GroupSimpleResponse>): void;
  /* 静音本端音频发送*/
  abstract muteLocalAudio(mute: boolean , result: Result<GroupSimpleResponse>): void;
  /* 设置扬声器开关*/
  abstract setSpeakerphoneOn(enable: boolean , result: Result<GroupSimpleResponse>): void;
  /* 获取扬声器状态*/
  abstract isSpeakerphoneOn(result: Result<boolean>): void;
  /* 切换前后摄像头*/
  abstract switchCamera(result: Result<GroupSimpleResponse>): void;
  /* 设置本端视频画布*/
  abstract setupLocalView(param: NEGroupViewParam , result: Result<GroupSimpleResponse>): void;
  /* 设置远端成员视频画布*/
  abstract setupRemoteView(param: NEGroupViewParam , result: Result<GroupSimpleResponse>): void;
  /* 开启/关闭音量回调*/
  abstract enableAudioVolumeIndication(enable: boolean , interval: number , result: Result<GroupSimpleResponse>): void;
  /* 设置音视频通话参数*/
  abstract setParameters(params: Map<string, Object> , result: Result<GroupSimpleResponse>): void;
  /** The codec used by GroupCallKitApi. */
  static getCodec(): MessageCodec<Object>{
    return GroupCallKitApiCodec.INSTANCE;
  }
  /*Sets up an instance of `GroupCallKitApi` to handle messages through the `binaryMessenger`.*/
  static setup(binaryMessenger: BinaryMessenger, api: GroupCallKitApi | null): void {
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.init", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.init(args[0] as NEGroupConfigParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.release", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.release(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupCall", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupCallResponse>{
                    success(result: GroupCallResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupCallResponse> = new ResultImp();

              api!.groupCall(args[0] as NEGroupCallParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupAccept", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupAcceptResponse>{
                    success(result: GroupAcceptResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupAcceptResponse> = new ResultImp();

              api!.groupAccept(args[0] as NEGroupAcceptParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupHangup", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.groupHangup(args[0] as NEGroupHangupParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupInvite", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.groupInvite(args[0] as NEGroupInviteParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupJoin", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupJoinResponse>{
                    success(result: GroupJoinResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupJoinResponse> = new ResultImp();

              api!.groupJoin(args[0] as NEGroupJoinParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupQueryCallInfo", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupQueryCallInfoResponse>{
                    success(result: GroupQueryCallInfoResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupQueryCallInfoResponse> = new ResultImp();

              api!.groupQueryCallInfo(args[0] as string, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.groupQueryMembers", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupQueryMembersResponse>{
                    success(result: GroupQueryMembersResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupQueryMembersResponse> = new ResultImp();

              api!.groupQueryMembers(args[0] as string, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.enableLocalVideo", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.enableLocalVideo(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.muteLocalVideo", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.muteLocalVideo(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.enableLocalAudio", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.enableLocalAudio(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.muteLocalAudio", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.muteLocalAudio(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.setSpeakerphoneOn", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.setSpeakerphoneOn(args[0] as boolean, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.isSpeakerphoneOn", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<boolean>{
                    success(result: boolean): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<boolean> = new ResultImp();

              api!.isSpeakerphoneOn(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.switchCamera", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.switchCamera(resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.setupLocalView", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.setupLocalView(args[0] as NEGroupViewParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.setupRemoteView", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.setupRemoteView(args[0] as NEGroupViewParam, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.enableAudioVolumeIndication", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.enableAudioVolumeIndication(args[0] as boolean, args[1] as number, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.GroupCallKitApi.setParameters", GroupCallKitApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              class ResultImp implements Result<GroupSimpleResponse>{
                    success(result: GroupSimpleResponse): void {
                      let res: Array<Object> = [];
                      res.push(result);
                      reply.reply(res);
                    }

                    error(error: Error): void {
                      let wrappedError: Array<Object> = wrapError(error);
                      reply.reply(wrappedError);
                    }
              }
              let resultCallback: Result<GroupSimpleResponse> = new ResultImp();

              api!.setParameters(args[0] as Map<string, Object>, resultCallback);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
  }
}

class GroupCallKitEventSinkCodec extends StandardMessageCodec {
  static INSTANCE: GroupCallKitEventSinkCodec = new GroupCallKitEventSinkCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(128):
        return NEGroupCallEndEvent.fromList(super.readValue(buffer));
      case this.getByte(129):
        return NEGroupCallHangupEvent.fromList(super.readValue(buffer));
      case this.getByte(130):
        return NEGroupCallInfo.fromList(super.readValue(buffer));
      case this.getByte(131):
        return NEGroupCallMember.fromList(super.readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof NEGroupCallEndEvent) {
      stream.writeUint8(this.getByte(128));
      this.writeValue(stream, (value as NEGroupCallEndEvent).toList());
    } else if (value instanceof NEGroupCallHangupEvent) {
      stream.writeUint8(this.getByte(129));
      this.writeValue(stream, (value as NEGroupCallHangupEvent).toList());
    } else if (value instanceof NEGroupCallInfo) {
      stream.writeUint8(this.getByte(130));
      this.writeValue(stream, (value as NEGroupCallInfo).toList());
    } else if (value instanceof NEGroupCallMember) {
      stream.writeUint8(this.getByte(131));
      this.writeValue(stream, (value as NEGroupCallMember).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

/*
*  群呼业务回调
* 
*  Generated class from Pigeon that represents Flutter messages that can be called from ArkTS.
*/
export class GroupCallKitEventSink {
  binaryMessenger: BinaryMessenger;

  constructor(binaryMessenger: BinaryMessenger) {
    this.binaryMessenger = binaryMessenger;
  }

  /** The codec used by GroupCallKitEventSink. */
  static getCodec(): MessageCodec<Object> {
    return GroupCallKitEventSinkCodec.INSTANCE;
  }

  /* 收到群呼邀请*/
  onReceiveGroupInvitation(infoArg: NEGroupCallInfo, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupCallKitEventSink.onReceiveGroupInvitation", GroupCallKitEventSink.getCodec());
    channel.send(
        [infoArg],
        channelReply => callback.reply(null));
  }
  /* 成员列表变更*/
  onGroupMemberListChanged(callIdArg: string,membersArg: Array<NEGroupCallMember>, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupCallKitEventSink.onGroupMemberListChanged", GroupCallKitEventSink.getCodec());
    channel.send(
        [callIdArg, membersArg],
        channelReply => callback.reply(null));
  }
  /* 成员挂断回调*/
  onGroupCallHangup(eventArg: NEGroupCallHangupEvent, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupCallKitEventSink.onGroupCallHangup", GroupCallKitEventSink.getCodec());
    channel.send(
        [eventArg],
        channelReply => callback.reply(null));
  }
  /* 群呼结束回调*/
  onGroupCallEnd(eventArg: NEGroupCallEndEvent, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupCallKitEventSink.onGroupCallEnd", GroupCallKitEventSink.getCodec());
    channel.send(
        [eventArg],
        channelReply => callback.reply(null));
  }
}

class GroupMediaEventSinkCodec extends StandardMessageCodec {
  static INSTANCE: GroupMediaEventSinkCodec = new GroupMediaEventSinkCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(128):
        return NEAudioVolumeInfo.fromList(super.readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof NEAudioVolumeInfo) {
      stream.writeUint8(this.getByte(128));
      this.writeValue(stream, (value as NEAudioVolumeInfo).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

/*
*  媒体事件回调
* 
*  Generated class from Pigeon that represents Flutter messages that can be called from ArkTS.
*/
export class GroupMediaEventSink {
  binaryMessenger: BinaryMessenger;

  constructor(binaryMessenger: BinaryMessenger) {
    this.binaryMessenger = binaryMessenger;
  }

  /** The codec used by GroupMediaEventSink. */
  static getCodec(): MessageCodec<Object> {
    return GroupMediaEventSinkCodec.INSTANCE;
  }

  /* 远端用户开启音频*/
  onUserAudioStart(uidArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserAudioStart", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户关闭音频*/
  onUserAudioStop(uidArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserAudioStop", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户音频静音状态变更*/
  onUserAudioMute(uidArg: number,mutedArg: boolean, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserAudioMute", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg, mutedArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户开启视频*/
  onUserVideoStart(uidArg: number,maxProfileArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserVideoStart", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg, maxProfileArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户关闭视频*/
  onUserVideoStop(uidArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserVideoStop", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户视频静音状态变更*/
  onUserVideoMute(uidArg: number,mutedArg: boolean, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onUserVideoMute", GroupMediaEventSink.getCodec());
    channel.send(
        [uidArg, mutedArg],
        channelReply => callback.reply(null));
  }
  /* 远端用户音量回调*/
  onRemoteAudioVolumeIndication(volumesArg: Array<NEAudioVolumeInfo>,totalVolumeArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onRemoteAudioVolumeIndication", GroupMediaEventSink.getCodec());
    channel.send(
        [volumesArg, totalVolumeArg],
        channelReply => callback.reply(null));
  }
  /* 与服务器连接中断*/
  onDisconnect(reasonArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onDisconnect", GroupMediaEventSink.getCodec());
    channel.send(
        [reasonArg],
        channelReply => callback.reply(null));
  }
  /* 音视频组件运行时错误*/
  onError(codeArg: number, callback: Reply<void>) {
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, "dev.flutter.pigeon.GroupMediaEventSink.onError", GroupMediaEventSink.getCodec());
    channel.send(
        [codeArg],
        channelReply => callback.reply(null));
  }
}
/* Generated abstract class from Pigeon that represents a handler of messages from Flutter.*/
export abstract class CallkitVideoRendererApi {
  /* 创建视频渲染器，返回 textureId*/
  abstract createVideoRenderer(): number;
  /* 设置镜像*/
  abstract setMirror(textureId: number , mirror: boolean ): number;
  /* 绑定为本地视频画布*/
  abstract setupLocalVideoRenderer(textureId: number ): number;
  /* 绑定为远端视频画布*/
  abstract setupRemoteVideoRenderer(uid: number , textureId: number ): number;
  /* 释放视频渲染器*/
  abstract disposeVideoRenderer(textureId: number ): void;
  /** The codec used by CallkitVideoRendererApi. */
  static getCodec(): MessageCodec<Object>{
    return new StandardMessageCodec();
  }
  /*Sets up an instance of `CallkitVideoRendererApi` to handle messages through the `binaryMessenger`.*/
  static setup(binaryMessenger: BinaryMessenger, api: CallkitVideoRendererApi | null): void {
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallkitVideoRendererApi.createVideoRenderer", CallkitVideoRendererApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let res: Array<Object> = [];
              try {
                let output: number = api!.createVideoRenderer();
                res.push(output);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallkitVideoRendererApi.setMirror", CallkitVideoRendererApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              let res: Array<Object> = [];
              try {
                let output: number = api!.setMirror(args[0] as number, args[1] as boolean);
                res.push(output);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallkitVideoRendererApi.setupLocalVideoRenderer", CallkitVideoRendererApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              let res: Array<Object> = [];
              try {
                let output: number = api!.setupLocalVideoRenderer(args[0] as number);
                res.push(output);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallkitVideoRendererApi.setupRemoteVideoRenderer", CallkitVideoRendererApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              let res: Array<Object> = [];
              try {
                let output: number = api!.setupRemoteVideoRenderer(args[0] as number, args[1] as number);
                res.push(output);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, "dev.flutter.pigeon.CallkitVideoRendererApi.disposeVideoRenderer", CallkitVideoRendererApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object ,reply: Reply<Object> ) {
              let args: Array<Object> = message as Array<Object>;
              let res: Array<Object> = [];
              try {
                api!.disposeVideoRenderer(args[0] as number);
                res.push(null);
              }
 catch (error) {
                let wrappedError: Array<Object> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
  }
}
