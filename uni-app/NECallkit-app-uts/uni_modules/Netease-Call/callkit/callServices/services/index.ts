import {
  CallEngine,
  CallbackParams,
  InitParams,
  LoginParams,
  CallParams,
  AcceptParams,
  HangupParams,
  InviteUserOptions,
  JoinOptions,
  Camera,
  CallbackOptions,
  SelfInfoOptions,
  NECallEvent,
} from "@/uni_modules/Netease-Call";
import {
  MediaType,
  CallRole,
  CallStatus,
  NAME,
  StoreName,
  CALL_DATA_KEY,
  CALL_PAGE_PATH,
} from "../const/index";
import {
  formatTime,
  performanceNow,
  Timer,
  paramValidate,
  VALIDATE_PARAMS,
  toast,
} from "../utils/index";
import { t, CallTips } from "../locales/index";
import { CallRingController } from "./callRingController";

const SWITCH_CALL_STATE_INVITE = 1;
const SWITCH_CALL_STATE_ACCEPT = 2;
const SWITCH_CALL_STATE_REJECT = 3;
const AUDIO_PLAYBACK_DEVICE_SPEAKERPHONE = 0;
const AUDIO_PLAYBACK_DEVICE_EARPIECE = 1;
const SWITCH_CALL_TYPE_INVITE_TIMEOUT = 5000;

class CallService {
  static instance = null;
  public callEngine: any;
  private _timerId: number = -1;
  private _startTimeStamp: number = performanceNow();
  private _isInForeground: boolean = false;
  private _incomingBannerEnabled: boolean = false;
  private _ringController: CallRingController = new CallRingController();
  private _pendingSwitchCallType: MediaType | null = null;
  private _switchCallTypeInviteRevision: number = 0;
  private _pendingSwitchCallTypeInviteAt: number = 0;
  private _switchCallTypeInviteTimeoutTimerId: number = -1;
  private _switchCallTypeConfirmModalType: MediaType | null = null;
  private _switchCallTypeConfirmModalRevision: number = 0;
  private _autoFloatingWindowWhenHomeEnabled: boolean = false;
  private _incomingCallPermissionRevision: number = 0;
  private _iosLiveCommunicationKitIncoming: boolean = false;

  constructor() {
    console.log(`${NAME.PREFIX} constructor`);
    this.callEngine = new CallEngine();
    this._addListener();

    uni.onAppHide(() => {
      this._isInForeground = false;
      // #ifndef APP-IOS
      this._startFloatWindowWhenHome();
      // #endif
    });
    uni.onAppShow(() => {
      this._isInForeground = true;
      if (this._isIOSPlatform()) {
        this.recoverConnectedCallPageFromNative("appShow");
      }
    });
  }

  static getInstance() {
    if (!CallService.instance) {
      CallService.instance = new CallService();
    }
    return CallService.instance;
  }

  private _addListener(): void {
    console.log(`${NAME.PREFIX} _addListener`);

    this.callEngine.on("onError", (res) => {
      console.error(`${NAME.PREFIX} onError, data: ${JSON.stringify(res)}`);
    });
    this.callEngine.on("onLiveCommunicationKitIncomingStateChanged", (res) => {
      console.log(
        `${NAME.PREFIX} onLiveCommunicationKitIncomingStateChanged, data: ${JSON.stringify(res)}`
      );
      this._iosLiveCommunicationKitIncoming = res?.isIncoming === true;
      if (this._iosLiveCommunicationKitIncoming) {
        this._ringController.stopLoopRing();
      }
    });
    this.callEngine.on("onCallReceived", (res) => {
      console.log(
        `${NAME.PREFIX} onCallReceived, data: ${JSON.stringify(res)}`
      );
      const incomingPermissionRevision = ++this._incomingCallPermissionRevision;
      const remotePushPayload = res?.info?.extraInfo;
      console.log(
        `${NAME.PREFIX} onReceiveInvited(callerAccId:${res?.info?.callerAccId}, callType:${res?.info?.callType}, channelId:${res?.info?.channelId}, extraInfo:${res?.info?.extraInfo}, remotePushPayload:${remotePushPayload})`
      );
      if (remotePushPayload) {
        try {
          const remoteExtraInfo = JSON.parse(remotePushPayload);
          console.log(
            `${NAME.PREFIX} onReceiveInvited remotePushParams: ${JSON.stringify(remoteExtraInfo?.pushConfig ?? remoteExtraInfo)}`
          );
        } catch (error) {
          console.log(
            `${NAME.PREFIX} onReceiveInvited remotePushParams: ${remotePushPayload}`
          );
        }
      }
      this._hasPermission(
        res?.info?.callType,
        () => {
          if (incomingPermissionRevision !== this._incomingCallPermissionRevision) {
            console.log(
              `${NAME.PREFIX} onCallReceived permission success ignored, revision: ${incomingPermissionRevision}, current: ${this._incomingCallPermissionRevision}`
            );
            return;
          }
          const callTipsKey =
            res?.info?.callType == MediaType.AUDIO
              ? CallTips.CALLEE_CALLING_AUDIO_MSG
              : CallTips.CALLEE_CALLING_VIDEO_MSG;
          uni.$NEStore.update(
            StoreName.CALL,
            NAME.IS_GROUP_CALL,
            res.info?.calleeIDList?.length > 1
          );
          let updateStoreParams = {
            [NAME.CALL_ROLE]: CallRole.CALLEE,
            [NAME.CALL_STATUS]: CallStatus.CALLING,
            [NAME.MEDIA_TYPE]: res?.info?.callType,
            [NAME.CALL_TIPS]: t(callTipsKey),
            [NAME.CALLER_USER_INFO]: res?.info?.callerAccId,
            [NAME.CALL_EXTRA_INFO]: res?.info?.extraInfo,
            [NAME.CHAT_GROUP_ID]: res?.info?.chatGroupId,
          };
          uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);
          if (this._incomingBannerEnabled) {
            this._startIncomingRingIfNeeded();
            this.showIncomingBanner();
            return;
          }
          this._startIncomingRingIfNeeded();
          getApp().globalData.timeout > 0 && this._navigateToCallPage();
        },
        () => {
          this._hangupPermissionDeniedCall();
        }
      );
    });

    this.callEngine.on("onCallConnected", (res) => {
      console.log(`${NAME.PREFIX} onCallConnected, data: ${JSON.stringify(res)}`);
      this._clearIOSLiveCommunicationKitIncoming();
      this._ringController.stopLoopRing();
      
      const connectedCallInfo = res?.info;
      if (
        this._isIOSPlatform() &&
        Number(connectedCallInfo?.callStatus ?? 0) === 3 &&
        !this._isCallPageVisible() &&
        this.recoverConnectedCallPageFromNative("onCallConnected", connectedCallInfo)
      ) {
        return;
      }

      const callType = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.MEDIA_TYPE
      ) || connectedCallInfo?.callType;
      this.startService(callType);
      
      const callStatus = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.CALL_STATUS
      );
      if (callStatus === CallStatus.CALLING) {
        if (
          this._isIOSPlatform() &&
          this._incomingBannerEnabled &&
          !this._isCallPageVisible() &&
          this.recoverConnectedCallPageFromNative("onCallConnected", connectedCallInfo)
        ) {
          return;
        }
        uni.$NEStore.update(
          StoreName.CALL,
          NAME.CALL_STATUS,
          CallStatus.CONNECTED
        );
        uni.$NEStore.update(StoreName.CALL, NAME.CALL_TIPS, "");
        this._startTimer();
        return;
      }
      if (this._isIOSPlatform() && callStatus !== CallStatus.CONNECTED) {
        console.log(
          `${NAME.PREFIX} onCallConnected recover call page from native info, callStatus: ${callStatus}`
        );
        this.recoverConnectedCallPageFromNative("onCallConnected", connectedCallInfo);
      }
    });

    this.callEngine.on("onCallTypeChange", (res) => {
      console.log(
        `${NAME.PREFIX} onCallTypeChange, data: ${JSON.stringify(res)}, ` +
          `pending: ${this._pendingSwitchCallType}, revision: ${this._switchCallTypeInviteRevision}, ` +
          `currentMediaType: ${uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE)}`
      );
      const callType = res?.info?.callType;
      const state = res?.info?.state;
      if (state === SWITCH_CALL_STATE_INVITE) {
        this._handleSwitchCallTypeInvite(callType);
        return;
      }

      if (state === SWITCH_CALL_STATE_ACCEPT) {
        if (
          this._pendingSwitchCallType !== null &&
          this._pendingSwitchCallType !== callType
        ) {
          console.log(
            `${NAME.PREFIX} onCallTypeChange accept skipped, pending: ${this._pendingSwitchCallType}, callType: ${callType}`
          );
          return;
        }
        if (this._pendingSwitchCallType === null) {
          console.log(
            `${NAME.PREFIX} onCallTypeChange passive accept, check permission before apply, callType: ${callType}`
          );
          this._restoreSwitchCallTypeConfirmConfig();
          this._applySwitchCallTypeAfterPermission(callType);
          return;
        }
        this._restoreSwitchCallTypeConfirmConfig();
        this._clearPendingSwitchCallType(callType);
        this._applySwitchCallType(callType);
        return;
      }

      if (state === SWITCH_CALL_STATE_REJECT) {
        this._restoreSwitchCallTypeConfirmConfig();
        this._handleSwitchCallTypeRejected(callType);
      }
    });

    this.callEngine.on("onCallEnd", (res) => {
      console.log(`${NAME.PREFIX} onCallEnd, data: ${JSON.stringify(res)}`);
      this._clearIOSLiveCommunicationKitIncoming();
      this._incomingCallPermissionRevision++;
      this._ringController.stopLoopRing();
      
      const callType = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.MEDIA_TYPE
      );
      this.stopService(callType);
      
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this.cancelIncomingBanner();
      this._resetCallStore();
      
      //呼叫超时
      if (res?.info?.reasonCode == 2) {
        const toastInfo = {
          key: CallTips.CALL_TIMEOUT,
        };
        toast.show(t(toastInfo));
      }
      
      //对方已拒绝
      if (res?.info?.reasonCode == 14) {
        const toastInfo = {
          key: CallTips.OTHER_SIDE_REJECT_CALL,
        };
        toast.show(t(toastInfo));
        this._ringController.playPeerRejectRing();
      }
      
      //对方忙线
      if (res?.info?.reasonCode == 3) {
        const toastInfo = {
          key: CallTips.OTHER_SIDE_LINE_BUSY,
        };
        toast.show(t(toastInfo));
        this._ringController.playPeerBusyRing();
      }
      
      //对方已挂断
      if (res?.info?.reasonCode == 16) {
        const toastInfo = {
          key: CallTips.END_CALL,
          options: {
            userList: '对方',
          },
        };
        toast.show(t(toastInfo));
      }
      
      //其他端已拒绝
      if (res?.info?.reasonCode == 17) {
        const toastInfo = {
          key: CallTips.OTHER_REJECTED,
        };
        toast.show(t(toastInfo));
      }
      
      //其他端已接听
      if (res?.info?.reasonCode == 18) {
        const toastInfo = {
          key: CallTips.OTHER_ACCEPTED,
        };
        toast.show(t(toastInfo));
      }
    });

    this.callEngine.on("onCallNotConnected", (res) => {
      console.log(
        `${NAME.PREFIX} onCallNotConnected, data: ${JSON.stringify(res)}`
      );
      this._clearIOSLiveCommunicationKitIncoming();
      this._ringController.stopLoopRing();
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this.cancelIncomingBanner();
      this._resetCallStore();
    });

    this.callEngine.on("onFloatWindowClick", (res) => {
      console.log(
        `${NAME.PREFIX} onFloatWindowClick, data: ${JSON.stringify(res)}`
      );
      this.bringAppToForeground();
      setTimeout(() => {
        this.stopFloatWindow();
        this._navigateToCallPage();
      }, 300);
    });

    this.callEngine.on("onIncomingBannerClick", (res) => {
      console.log(
        `${NAME.PREFIX} onIncomingBannerClick, data: ${JSON.stringify(res)}`
      );
      if (res?.action === "accept") {
        this._handleIncomingBannerAccept();
        return;
      }
      this.cancelIncomingBanner();
      this._navigateToCallPage();
    });
  }

  private _removeListenr(): void {
    this.callEngine.off("onError");
    this.callEngine.off("onLiveCommunicationKitIncomingStateChanged");
    this.callEngine.off("onCallReceived");
    this.callEngine.off("onCallBegin");
    this.callEngine.off("onCallTypeChange");
    this.callEngine.off("onCallEnd");
    this.callEngine.off("onCallNotConnected");
    this.callEngine.off("onFloatWindowClick");
    this.callEngine.off("onIncomingBannerClick");
  }
  
  public init(options: InitParams): void {
    console.log(`${NAME.PREFIX} init setup, data: ${JSON.stringify(options)}`);
    this.enableIncomingBanner(options.enableIncomingBanner ?? false);
    this.callEngine.setup(options)
    this.setAutoFloatingWindowWhenHomeEnabled(options.enableAutoFloatingWindowWhenHome ?? false);
    console.log(`${NAME.PREFIX} init setup done, data: ${JSON.stringify(options)}`);
  }
  
  public setTimeout(millisecond: number): void {
    this.callEngine.setTimeout(millisecond);
  }

  public login(options: LoginParams): void {
    console.log(`${NAME.PREFIX} login, data: ${JSON.stringify(options)}`);
    const params = {
      accountId: options.accountId,
      token: options.token,
      success: () => {
        options?.success?.();
        uni.$NEStore.update(
          StoreName.CALL,
          NAME.LOCAL_USER_INFO,
          options.accountId
        );
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.login(params);
  }

  public logout(options: CallbackParams): void {
    const params = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.logout(params);
    this._resetCallStore();
  }

  public call(options: CallParams): void {
    console.log(`${NAME.PREFIX} calls, data: ${JSON.stringify(options)}`);
    const isAndroid = uni.getSystemInfoSync().platform === "android";
    const startCall = () => {
      const params: CallParams = {
        accountId: options.accountId,
        callType: options.callType,
        params: options.params,
        success: () => {
          if (!isAndroid) {
            this._hasPermission(options.callType);
          }
          let callTips = CallTips.CALLER_CALLING_MSG;
          let updateStoreParams = {
            [NAME.CALL_ROLE]: CallRole.CALLER,
            [NAME.CALL_STATUS]: CallStatus.CALLING,
            [NAME.MEDIA_TYPE]: options?.callType,
            [NAME.CALL_TIPS]: t(callTips),
            [NAME.CHAT_GROUP_ID]: options?.info?.chatGroupID,
          };
          uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);
          this._ringController.startOutgoingRing();
          this._navigateToCallPage();
          options?.success?.();
        },
        fail: (errCode: number, errMsg: string) => {
          options?.fail?.(errCode, errMsg);
          uni.showToast({
            title: errMsg,
            position: "bottom",
          });
          this.handleExceptionExit();
        },
      };

      this.callEngine.call(params);
    };

    if (isAndroid) {
      this._hasPermission(options.callType, startCall);
      return;
    }
    startCall();
  }

  public accept(options?: AcceptParams): void {
    console.log(`${NAME.PREFIX} accept`);
    this._clearIOSLiveCommunicationKitIncoming();
    this._ringController.stopLoopRing();
    this.cancelIncomingBanner();
    const params: AcceptParams = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.accept(params);
  }
  
  public hangup(options?: HangupParams): void {
    console.log(`${NAME.PREFIX} hangup`);
    this._clearIOSLiveCommunicationKitIncoming();
    this._ringController.stopLoopRing();
    this.cancelIncomingBanner();
    const params: HangupParams = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        options?.fail?.(errCode, errMsg);
      },
    };
    this.callEngine.hangup(params);
    this._navigateBackCallPage();
  }

  public reject(options?: CallbackOptions): void {
    console.log(`${NAME.PREFIX} reject`);
    const params: CallbackOptions = {
      success: () => {
        options?.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        uni.showToast({
          title: errMsg,
          position: "bottom",
        });
        options?.fail?.(errCode, errMsg);
      },
    };
    // this.callEngine.reject(params);
  }

  public openCamera(): void {
    console.log(`${NAME.PREFIX} openCamera`);
    // const params: CallbackOptions = {
    //   success: () => {
    //     options?.success?.();
    //   },
    //   fail: (errCode: number, errMsg: string) => {
    //     options?.fail?.(errCode, errMsg);
    //   },
    // };
    this.callEngine.muteLocalVideo(false);
  }

  public closeCamera(): void {
    console.log(`${NAME.PREFIX} closeCamera`);
    this.callEngine.muteLocalVideo(true);
  }

  public switchCamera(camera: Camera): void {
    console.log(`${NAME.PREFIX} switchCamera`);
    this.callEngine.switchCamera(camera);
  }

  public switchVideoToAudio(): void {
    console.log(`${NAME.PREFIX} switchVideoToAudio`);
    const callStatus = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    const mediaType = uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);
    if (callStatus !== CallStatus.CONNECTED || mediaType !== MediaType.VIDEO) {
      console.log(`${NAME.PREFIX} switchVideoToAudio skipped, invalid state`);
      return;
    }
    if (this._pendingSwitchCallType !== null) {
      console.log(`${NAME.PREFIX} switchVideoToAudio skipped, pending: ${this._pendingSwitchCallType}`);
      uni.showToast({
        title: "正在切换，请勿重复操作",
        position: "bottom",
      });
      return;
    }
    this._sendSwitchCallTypeInviteAfterPermission(MediaType.AUDIO);
  }

  public switchAudioToVideo(): void {
    console.log(`${NAME.PREFIX} switchAudioToVideo`);
    const callStatus = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    const mediaType = uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);
    if (callStatus !== CallStatus.CONNECTED || mediaType !== MediaType.AUDIO) {
      console.log(`${NAME.PREFIX} switchAudioToVideo skipped, invalid state`);
      return;
    }
    if (this._pendingSwitchCallType !== null) {
      console.log(`${NAME.PREFIX} switchAudioToVideo skipped, pending: ${this._pendingSwitchCallType}`);
      uni.showToast({
        title: "正在切换，请勿重复操作",
        position: "bottom",
      });
      return;
    }
    this._sendSwitchCallTypeInviteAfterPermission(MediaType.VIDEO);
  }

  public setSwitchCallTypeConfirm(audioToVideoConfirm: boolean, videoToAudioConfirm: boolean): void {
    console.log(
      `${NAME.PREFIX} setSwitchCallTypeConfirm, audioToVideoConfirm: ${audioToVideoConfirm}, videoToAudioConfirm: ${videoToAudioConfirm}`
    );
    this.callEngine.setSwitchCallTypeConfirm(
      audioToVideoConfirm,
      videoToAudioConfirm
    );
  }

  public setAutoFloatingWindowWhenHomeEnabled(enable: boolean): void {
    const floatingWindowEnabled = getApp().globalData?.enableFloatingWindow !== false;
    const effectiveEnable = enable === true && floatingWindowEnabled;
    console.log(
      `${NAME.PREFIX} setAutoFloatingWindowWhenHomeEnabled, enable: ${enable}, ` +
        `floatingWindowEnabled: ${floatingWindowEnabled}, effectiveEnable: ${effectiveEnable}`
    );
    this._autoFloatingWindowWhenHomeEnabled = effectiveEnable;
    this.callEngine.setAutoFloatingWindowWhenHomeEnabled?.(effectiveEnable);
  }

  private _startFloatWindowWhenHome(): void {
    if (!this._autoFloatingWindowWhenHomeEnabled) {
      return;
    }
    if (getApp().globalData?.enableFloatingWindow === false) {
      console.log(`${NAME.PREFIX} _startFloatWindowWhenHome skipped, floating window disabled`);
      return;
    }
    const callStatus = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    if (callStatus !== CallStatus.CONNECTED) {
      console.log(`${NAME.PREFIX} _startFloatWindowWhenHome skipped, callStatus: ${callStatus}`);
      return;
    }
    const enableFloatWindow = uni.$NEStore.getData(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW);
    if (enableFloatWindow) {
      console.log(`${NAME.PREFIX} _startFloatWindowWhenHome skipped, already enabled`);
      return;
    }
    console.log(`${NAME.PREFIX} _startFloatWindowWhenHome start`);
    this.startFloatWindow();
  }

  private _applyPendingInviteSwitchCallTypeConfirmConfig(): void {
    console.log(`${NAME.PREFIX} _applyPendingInviteSwitchCallTypeConfirmConfig`);
    this.callEngine.setSwitchCallTypeConfirm(true, true);
  }

  private _restoreSwitchCallTypeConfirmConfig(): void {
    const app = getApp();
    const audioToVideoConfirm = app.globalData?.audioToVideoConfirm === true;
    const videoToAudioConfirm = app.globalData?.videoToAudioConfirm === true;
    console.log(
      `${NAME.PREFIX} _restoreSwitchCallTypeConfirmConfig, ` +
        `audioToVideoConfirm: ${audioToVideoConfirm}, ` +
        `videoToAudioConfirm: ${videoToAudioConfirm}`
    );
    this.callEngine.setSwitchCallTypeConfirm(audioToVideoConfirm, videoToAudioConfirm);
  }

  private _sendSwitchCallTypeInviteAfterPermission(callType: MediaType): void {
    console.log(
      `${NAME.PREFIX} _sendSwitchCallTypeInviteAfterPermission, callType: ${callType}`
    );
    const switchName =
      callType === MediaType.VIDEO ? "switchAudioToVideo" : "switchVideoToAudio";
    this._hasPermission(
      callType,
      async () => {
        if (await this._isNetworkUnavailable()) {
          console.error(`${NAME.PREFIX} ${switchName} fail, network unavailable`);
          uni.showToast({
            title: "网络异常",
            position: "bottom",
          });
          return;
        }
        this._setPendingSwitchCallType(callType);
        this._sendSwitchCallTypeInvite({
          callType,
          success: () => {
            console.log(`${NAME.PREFIX} ${switchName} success`);
          },
          fail: (errCode: number, errMsg: string) => {
            this._clearPendingSwitchCallType(callType);
            console.error(
              `${NAME.PREFIX} ${switchName} fail, code: ${errCode}, msg: ${errMsg}`
            );
            uni.showToast({
              title: errMsg || "切换失败",
              position: "bottom",
            });
          },
        });
      }
    );
  }

  private _isNetworkUnavailable(): Promise<boolean> {
    return new Promise((resolve) => {
      uni.getNetworkType({
        success: (res) => {
          const networkType = String(res?.networkType ?? "").toLowerCase();
          console.log(`${NAME.PREFIX} _isNetworkUnavailable, networkType: ${networkType}`);
          resolve(networkType === "none");
        },
        fail: (err) => {
          console.error(
            `${NAME.PREFIX} _isNetworkUnavailable fail, error: ${JSON.stringify(err)}`
          );
          resolve(false);
        },
      });
    });
  }

  private _sendSwitchCallTypeInvite(options: {
    callType: MediaType;
    success?: () => void;
    fail?: (errCode: number, errMsg: string) => void;
  }): void {
    console.log(
      `${NAME.PREFIX} _sendSwitchCallTypeInvite prepare, callType: ${options.callType}, ` +
        `pending: ${this._pendingSwitchCallType}`
    );
    this._applyPendingInviteSwitchCallTypeConfirmConfig();
    if (options.callType === MediaType.VIDEO) {
      this.callEngine.muteLocalVideo(false);
    }
    this.callEngine.switchCallType({
      callType: options.callType,
      state: SWITCH_CALL_STATE_INVITE,
      success: () => {
        console.log(
          `${NAME.PREFIX} _sendSwitchCallTypeInvite success, callType: ${options.callType}`
        );
        options.success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        this._restoreSwitchCallTypeConfirmConfig();
        console.error(
          `${NAME.PREFIX} _sendSwitchCallTypeInvite fail, callType: ${options.callType}, ` +
            `code: ${errCode}, msg: ${errMsg}`
        );
        options.fail?.(errCode, errMsg);
      },
    });
  }

  public openMicrophone(): void {
    console.log(`${NAME.PREFIX} openMicrophone`);
    this.callEngine.muteLocalAudio(false);
  }

  public closeMicrophone(): void {
    this.callEngine.muteLocalAudio(true);
  }

  public selectAudioPlaybackDevice(enable: boolean): void {
    this.callEngine.setSpeakerphoneOn(enable);
  }

  public setSelfInfo(options: SelfInfoOptions): void {
    // this.callEngine.setSelfInfo(options);
  }

  public enableVirtualBackground(enable: boolean): void {
    // this.callEngine.enableVirtualBackground(enable);
  }

  public setBlurBackground(level: number): void {
    // this.callEngine.setBlurBackground(level);
  }

  public startFloatWindow(): void {
    if (getApp().globalData?.enableFloatingWindow === false) {
      console.log(`${NAME.PREFIX} startFloatWindow skipped, disabled`);
      return;
    }
    this.callEngine.startFloatWindow({
      success: () => {
        uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, true);
        this._navigateBackCallPage();
      },
    });
  }


  public stopFloatWindow(): void {
    this.callEngine.stopFloatWindow();
    uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, false);
  }

  public enableIncomingBanner(enable: boolean): void {
    console.log(`${NAME.PREFIX} enableIncomingBanner, enable: ${enable}`);
    const enabled = this.callEngine.setIncomingBannerEnabled(enable);
    if (enable && enabled === false) {
      console.log(`${NAME.PREFIX} enableIncomingBanner fail, disable incoming banner`);
      getApp().globalData.enableIncomingBanner = false;
      this._incomingBannerEnabled = false;
      uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_INCOMING_BANNER, false);
      return;
    }
    this._incomingBannerEnabled = enable;
    uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_INCOMING_BANNER, enable);
    if (!enable) {
      this.cancelIncomingBanner();
    }
  }

  public showIncomingBanner(): void {
    if (!this._incomingBannerEnabled) {
      console.log(`${NAME.PREFIX} showIncomingBanner skipped, disabled`);
      return;
    }
    const callRole = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_ROLE);
    const callStatus = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    if (callRole !== CallRole.CALLEE || callStatus !== CallStatus.CALLING) {
      console.log(`${NAME.PREFIX} showIncomingBanner skipped, invalid state`);
      return;
    }
    const caller = uni.$NEStore.getData(StoreName.CALL, NAME.CALLER_USER_INFO);
    const mediaType = uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);
    uni.$NEStore.update(StoreName.CALL, NAME.IS_IN_INCOMING_BANNER, true);
    this.callEngine.showIncomingBanner(caller, mediaType);
  }

  public cancelIncomingBanner(): void {
    console.log(`${NAME.PREFIX} cancelIncomingBanner`);
    this.callEngine.cancelIncomingBanner();
    uni.$NEStore.update(StoreName.CALL, NAME.IS_IN_INCOMING_BANNER, false);
  }
  
  public startService(callType: number): void {
    console.log(`${NAME.PREFIX} startService`);
    this.callEngine.startService(callType);
  }
  
  public stopService(callType: number): void {
  	console.log(`${NAME.PREFIX} stopService`);
  	this.callEngine.stopService(callType);
  }

  public bringAppToForeground(): void {
    this.callEngine.bringAppToForeground();
  }
  
  public getVersion(): string {
    return CallEngine.getVersion();
  }

  public handleExceptionExit() {
    console.log(`${NAME.PREFIX} handleExceptionExit`);
    try {
      const callStatus = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.CALL_STATUS
      );
      const callRole = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_ROLE);
      if (callStatus === CallStatus.IDLE) return;
      this._navigateBackCallPage();
      if (callRole === CallRole.CALLER || callStatus === CallStatus.CONNECTED) {
        this.hangup();
      } else if (callRole === CallRole.CALLEE) {
        this.hangup();
      }
      this._resetCallStore();
    } catch (error) {
      console.error(
        `${NAME.PREFIX} handleExceptionExit failed, error: ${error}.`
      );
    }
  }

  public getNECallEngineInstance() {
    return this.callEngine;
  }

  public getCallInfo(): any {
    return this.callEngine.getCallInfo?.();
  }

  public recoverConnectedCallPageFromNative(source: string, callInfo?: any): boolean {
    if (!this._isIOSPlatform()) {
      return false;
    }
    let nativeCallInfo = callInfo;
    if (!nativeCallInfo) {
      try {
        nativeCallInfo = this.getCallInfo();
      } catch (error) {
        console.log(`${NAME.PREFIX} recoverConnectedCallPageFromNative getCallInfo failed, ${error}`);
        return false;
      }
    }
    if (Number(nativeCallInfo?.callStatus ?? 0) !== 3) {
      return false;
    }
    const floatWindowActive = this._isFloatWindowActive();
    console.log(
      `${NAME.PREFIX} recoverConnectedCallPageFromNative, source: ${source}, ` +
        `floatWindowActive: ${floatWindowActive}`
    );
    this._syncConnectedCallStoreFromNativeInfo(nativeCallInfo);
    this.startService(nativeCallInfo?.callType);
    if (!floatWindowActive) {
      this._navigateToCallPage();
    }
    this._startTimer();
    return true;
  }

  private _isFloatWindowActive(): boolean {
    const storeFloatWindowActive =
      uni.$NEStore.getData(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW) === true;
    const nativeFloatWindowVisible = this.callEngine.isFloatWindowVisible?.();
    if (typeof nativeFloatWindowVisible === "boolean") {
      return nativeFloatWindowVisible || storeFloatWindowActive;
    }
    return storeFloatWindowActive;
  }

  private _syncConnectedCallStoreFromNativeInfo(callInfo: any): void {
    if (!callInfo) return;
    const currentAccId = callInfo?.currentAccId;
    const callerAccId = callInfo?.callerInfo?.accId;
    const calleeAccId = callInfo?.calleeInfo?.accId;
    const isCaller = currentAccId && callerAccId && currentAccId === callerAccId;
    const remoteAccId = isCaller ? calleeAccId : callerAccId;
    uni.$NEStore.updateStore(
      {
        [NAME.CALL_ROLE]: isCaller ? CallRole.CALLER : CallRole.CALLEE,
        [NAME.CALL_STATUS]: CallStatus.CONNECTED,
        [NAME.MEDIA_TYPE]: callInfo?.callType,
        [NAME.CALL_TIPS]: "",
        [NAME.CALLER_USER_INFO]: remoteAccId,
        [NAME.CALL_EXTRA_INFO]:
          callInfo?.signalInfo?.extraInfo ?? callInfo?.signalInfo?.globalExtraCopy,
      },
      StoreName.CALL
    );
  }

  private _isIOSPlatform(): boolean {
    return uni.getSystemInfoSync().platform === "ios";
  }

  private _isCallPageVisible(): boolean {
    const pagesList = getCurrentPages();
    const currentPage = pagesList[pagesList.length - 1]?.route || "";
    return currentPage.indexOf("callkit/callPage") !== -1;
  }

  private _navigateToCallPage() {
    const pagesList = getCurrentPages();
    const currentPage = pagesList[pagesList.length - 1].route;
    console.log(
      `${
        NAME.PREFIX
      } _navigateToCallPage, currentPage = ${currentPage}, ${currentPage.indexOf(
        "callkit/callPage"
      )}`
    );
    if (currentPage.indexOf("callkit/callPage") === -1) {
      uni.navigateTo({
        url: CALL_PAGE_PATH,
        animationType: "slide-in-top",
        success: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage success, ${JSON.stringify(
              result
            )}`
          );
        },
        fail: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage fail, ${JSON.stringify(result)}`
          );
        },
        complete: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateToCallPage complete, ${JSON.stringify(
              result
            )}`
          );
        },
      });
    }
  }

  private _navigateBackCallPage(): void {
    const pagesList = getCurrentPages();
    const currentPage = pagesList[pagesList.length - 1].route;
    console.log(
      `${NAME.PREFIX} _navigateBackCallPage, currentPage = ${currentPage}`
    );
    if (currentPage.indexOf("callkit/callPage") > 0) {
      uni.navigateBack({
        success: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage success, ${JSON.stringify(
              result
            )}`
          );
        },
        fail: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage fail, ${JSON.stringify(
              result
            )}`
          );
        },
        complete: (result) => {
          console.log(
            `${NAME.PREFIX} _navigateBackCallPage complete, ${JSON.stringify(
              result
            )}`
          );
        },
      });
    }
  }

  private _handleIncomingBannerAccept(): void {
    console.log(`${NAME.PREFIX} _handleIncomingBannerAccept`);
    this.accept({
      success: () => {
        const callType = uni.$NEStore.getData(StoreName.CALL, NAME.MEDIA_TYPE);
        this.startService(callType);
        uni.$NEStore.update(StoreName.CALL, NAME.CALL_STATUS, CallStatus.CONNECTED);
        uni.$NEStore.update(StoreName.CALL, NAME.CALL_TIPS, "");
        this._startTimer();
        this._navigateToCallPage();
      },
      fail: (errCode: number, errMsg: string) => {
        console.error(
          `${NAME.PREFIX} _handleIncomingBannerAccept fail, errCode=${errCode}, errMsg=${errMsg}`
        );
        toast.show(errMsg || "接听失败");
        this._resetCallStore();
      },
    });
  }

  private _handleSwitchCallTypeInvite(callType: MediaType): void {
    console.log(`${NAME.PREFIX} _handleSwitchCallTypeInvite, callType: ${callType}`);
    if (callType !== MediaType.AUDIO && callType !== MediaType.VIDEO) {
      console.log(`${NAME.PREFIX} _handleSwitchCallTypeInvite skipped, invalid callType`);
      return;
    }

    if (this._pendingSwitchCallType === callType) {
      console.log(`${NAME.PREFIX} _handleSwitchCallTypeInvite skipped, local pending invite`);
      return;
    }

    const app = getApp();
    const needConfirm =
      callType === MediaType.VIDEO
        ? app.globalData.audioToVideoConfirm
        : app.globalData.videoToAudioConfirm;

    if (!needConfirm) {
      this._respondSwitchCallTypeAfterPermission(callType);
      return;
    }

    const enableFloatWindow = uni.$NEStore.getData(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW) === true;
    const nativeFloatWindowVisible = this.callEngine.isFloatWindowVisible?.() === true;
    console.log(
      `${NAME.PREFIX} _handleSwitchCallTypeInvite floatWindow state, ` +
        `store: ${enableFloatWindow}, native: ${nativeFloatWindowVisible}`
    );

    if (this._switchCallTypeConfirmModalType !== null) {
      console.log(
        `${NAME.PREFIX} _handleSwitchCallTypeInvite skipped, modal showing, ` +
          `callType: ${callType}, modalType: ${this._switchCallTypeConfirmModalType}, ` +
          `revision: ${this._switchCallTypeConfirmModalRevision}`
      );
      return;
    }
    const revision = this._nextSwitchCallTypeInviteRevision();
    this._switchCallTypeConfirmModalType = callType;
    this._switchCallTypeConfirmModalRevision = revision;
    uni.showModal({
      title: "切换通话类型",
      content:
        callType === MediaType.VIDEO
          ? "对方邀请你切换为视频通话，是否同意？"
          : "对方邀请你切换为语音通话，是否同意？",
      confirmText: "同意",
      cancelText: "拒绝",
      success: (result) => {
        if (!this._isCurrentSwitchCallTypeInvite(revision)) {
          console.log(`${NAME.PREFIX} _handleSwitchCallTypeInvite skipped, expired revision: ${revision}`);
          this._clearSwitchCallTypeConfirmModal(revision);
          return;
        }
        this._clearSwitchCallTypeConfirmModal(revision);
        const state = result.confirm
          ? SWITCH_CALL_STATE_ACCEPT
          : SWITCH_CALL_STATE_REJECT;
        if (state === SWITCH_CALL_STATE_ACCEPT) {
          this._respondSwitchCallTypeAfterPermission(callType, true);
          return;
        }
        this._respondSwitchCallType(callType, state);
      },
      fail: () => {
        if (!this._isCurrentSwitchCallTypeInvite(revision)) {
          console.log(`${NAME.PREFIX} _handleSwitchCallTypeInvite fail skipped, expired revision: ${revision}`);
          this._clearSwitchCallTypeConfirmModal(revision);
          return;
        }
        this._clearSwitchCallTypeConfirmModal(revision);
        this._respondSwitchCallType(callType, SWITCH_CALL_STATE_REJECT);
      },
    });
  }

  private _respondSwitchCallTypeAfterPermission(
    callType: MediaType,
    applyAsync: boolean = false
  ): void {
    this._hasPermission(
      callType,
      () => {
        this._respondSwitchCallType(callType, SWITCH_CALL_STATE_ACCEPT, () => {
          const applySwitchCallType = () => {
            this._applySwitchCallType(callType);
          };
          if (applyAsync) {
            setTimeout(applySwitchCallType, 0);
            return;
          }
          applySwitchCallType();
        });
      },
      () => {
        this._respondSwitchCallType(callType, SWITCH_CALL_STATE_REJECT);
      }
    );
  }

  private _applySwitchCallTypeAfterPermission(callType: MediaType): void {
    this._hasPermission(
      callType,
      () => {
        this._applySwitchCallType(callType);
      },
      () => {
        this._respondSwitchCallType(callType, SWITCH_CALL_STATE_REJECT);
        this._hangupPermissionDeniedCall();
      },
      true
    );
  }

  private _setPendingSwitchCallType(callType: MediaType): void {
    this._pendingSwitchCallType = callType;
    this._switchCallTypeInviteRevision++;
    this._pendingSwitchCallTypeInviteAt = performanceNow();
    console.log(
      `${NAME.PREFIX} _setPendingSwitchCallType, callType: ${callType}, ` +
        `inviteAt: ${this._pendingSwitchCallTypeInviteAt}`
    );
    this._startSwitchCallTypeInviteTimeout(callType, this._switchCallTypeInviteRevision);
  }

  private _clearPendingSwitchCallType(callType?: MediaType): void {
    if (callType == null || this._pendingSwitchCallType === callType) {
      console.log(`${NAME.PREFIX} _clearPendingSwitchCallType, callType: ${callType}`);
      this._pendingSwitchCallType = null;
      this._pendingSwitchCallTypeInviteAt = 0;
      this._clearSwitchCallTypeInviteTimeout();
      this._switchCallTypeInviteRevision++;
    }
  }

  private _startSwitchCallTypeInviteTimeout(
    callType: MediaType,
    revision: number
  ): void {
    this._clearSwitchCallTypeInviteTimeout();
    console.log(
      `${NAME.PREFIX} _startSwitchCallTypeInviteTimeout, callType: ${callType}, ` +
        `revision: ${revision}, timeout: ${SWITCH_CALL_TYPE_INVITE_TIMEOUT}`
    );
    this._switchCallTypeInviteTimeoutTimerId = Timer.run(
      NAME.TIMEOUT,
      () => {
        if (
          this._pendingSwitchCallType !== callType ||
          this._switchCallTypeInviteRevision !== revision
        ) {
          console.log(
            `${NAME.PREFIX} _startSwitchCallTypeInviteTimeout skipped, ` +
              `pending: ${this._pendingSwitchCallType}, callType: ${callType}, ` +
              `revision: ${revision}, currentRevision: ${this._switchCallTypeInviteRevision}`
          );
          return;
        }
        console.log(
          `${NAME.PREFIX} _startSwitchCallTypeInviteTimeout expired, callType: ${callType}`
        );
        this._restoreSwitchCallTypeConfirmConfig();
        this._clearPendingSwitchCallType(callType);
        uni.showToast({
          title: "切换超时",
          position: "bottom",
        });
      },
      {
        delay: SWITCH_CALL_TYPE_INVITE_TIMEOUT,
        count: 1,
      }
    );
  }

  private _clearSwitchCallTypeInviteTimeout(): void {
    if (this._switchCallTypeInviteTimeoutTimerId === -1) {
      return;
    }
    Timer.clearTask(this._switchCallTypeInviteTimeoutTimerId);
    this._switchCallTypeInviteTimeoutTimerId = -1;
  }

  private _nextSwitchCallTypeInviteRevision(): number {
    this._switchCallTypeInviteRevision++;
    return this._switchCallTypeInviteRevision;
  }

  private _isCurrentSwitchCallTypeInvite(revision: number): boolean {
    return revision === this._switchCallTypeInviteRevision;
  }

  private _clearSwitchCallTypeConfirmModal(revision?: number): void {
    if (
      revision != null &&
      this._switchCallTypeConfirmModalRevision !== revision
    ) {
      return;
    }
    console.log(
      `${NAME.PREFIX} _clearSwitchCallTypeConfirmModal, revision: ${revision}, ` +
        `modalType: ${this._switchCallTypeConfirmModalType}`
    );
    this._switchCallTypeConfirmModalType = null;
    this._switchCallTypeConfirmModalRevision = 0;
  }

  private _handleSwitchCallTypeRejected(callType: MediaType): void {
    console.log(`${NAME.PREFIX} _handleSwitchCallTypeRejected, callType: ${callType}`);
    if (this._pendingSwitchCallType === callType) {
      this._clearPendingSwitchCallType(callType);
      uni.showToast({
        title: "对方拒绝了您的请求",
        position: "bottom",
      });
    }
  }

  private _respondSwitchCallType(
    callType: MediaType,
    state: number,
    success?: () => void
  ): void {
    console.log(
      `${NAME.PREFIX} _respondSwitchCallType, callType: ${callType}, state: ${state}`
    );
    if (callType === MediaType.VIDEO && state === SWITCH_CALL_STATE_ACCEPT) {
      this.callEngine.muteLocalVideo(false);
    }
    this.callEngine.switchCallType({
      callType,
      state,
      success: () => {
        console.log(`${NAME.PREFIX} _respondSwitchCallType success`);
        success?.();
      },
      fail: (errCode: number, errMsg: string) => {
        console.error(
          `${NAME.PREFIX} _respondSwitchCallType fail, code: ${errCode}, msg: ${errMsg}`
        );
        uni.showToast({
          title: errMsg || "切换失败",
          position: "bottom",
        });
      },
    });
  }

  private _applySwitchCallType(callType: MediaType): void {
    console.log(`${NAME.PREFIX} _applySwitchCallType, callType: ${callType}`);
    if (callType === MediaType.AUDIO) {
      this._resetDeviceStateAfterSwitchCallType(callType);
      uni.$NEStore.update(StoreName.CALL, NAME.MEDIA_TYPE, MediaType.AUDIO);
      return;
    }

    if (callType === MediaType.VIDEO) {
      this._resetDeviceStateAfterSwitchCallType(callType);
      uni.$NEStore.update(StoreName.CALL, NAME.MEDIA_TYPE, MediaType.VIDEO);
    }
  }

  private _resetDeviceStateAfterSwitchCallType(callType: MediaType): void {
    const isVideo = callType === MediaType.VIDEO;
    const speakerStatus = isVideo
      ? AUDIO_PLAYBACK_DEVICE_SPEAKERPHONE
      : AUDIO_PLAYBACK_DEVICE_EARPIECE;
    console.log(
      `${NAME.PREFIX} _resetDeviceStateAfterSwitchCallType, callType: ${callType}, ` +
        `micOpen: true, speakerStatus: ${speakerStatus}, cameraOpen: ${isVideo}`
    );

    this.openMicrophone();
    this.selectAudioPlaybackDevice(isVideo);
    if (isVideo) {
      this.openCamera();
    } else {
      this.closeCamera();
    }

    uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_MIC_OPEN, true);
    uni.$NEStore.update(StoreName.CALL, NAME.CURRENT_SPEAKER_STATUS, speakerStatus);
    uni.$NEStore.update(StoreName.CALL, NAME.IS_LOCAL_CAMERA_OPEN, isVideo);
    uni.$NEStore.update(StoreName.CALL, NAME.CURRENT_CAMERA_IS_OPEN, isVideo);
  }

  private _updateCallDuration(): void {
    const callDurationNum = Math.round(
      (performanceNow() - this._startTimeStamp) / 1000
    );
    const callDurationStr = formatTime(callDurationNum);
    uni.$NEStore.update(StoreName.CALL, NAME.CALL_DURATION, callDurationStr);
  }

  private _startTimer(): void {
    if (this._timerId === -1) {
      this._startTimeStamp = performanceNow();
      this._timerId = Timer.run(
        NAME.TIMEOUT,
        this._updateCallDuration.bind(this),
        { delay: 1000 }
      );
    }
  }

  private _stopTimer(): void {
    if (this._timerId !== -1) {
      Timer.clearTask(this._timerId);
      this._timerId = -1;
    }
  }

  private _startIncomingRingIfNeeded(): void {
    if (this._iosLiveCommunicationKitIncoming) {
      console.log(`${NAME.PREFIX} skip incoming ring because iOS LiveCommunicationKit is incoming`);
      return;
    }
    this._ringController.startIncomingRing();
  }

  private _clearIOSLiveCommunicationKitIncoming(): void {
    this._iosLiveCommunicationKitIncoming = false;
  }

  private _hasPermission(
    type: number,
    success?: () => void,
    fail?: () => void,
    showFailToastAfterCallback: boolean = false
  ) {
    console.log(`${NAME.PREFIX} _hasPermission, data: ${type}`);
    this.callEngine.hasPermission({
      type,
      success: () => {
        console.log(`${NAME.PREFIX} _hasPermission success`);
        success?.();
      },
      fail: (errCode, errMsg) => {
        console.log(
          `${NAME.PREFIX} _hasPermission fail, errCode=${errCode}, errMsg=${errMsg}`
        );
        const permissionTip =
          errCode === 21001 && errMsg ? errMsg : '未授权摄像头/麦克风权限！';
        const showPermissionTip = () => {
          uni.showToast({
            title: permissionTip,
            icon: "none",
            position: "center",
          });
        };
        if (fail) {
          if (showFailToastAfterCallback) {
            fail();
            setTimeout(() => {
              showPermissionTip();
            }, 500);
            return;
          }
          showPermissionTip();
          fail();
        } else {
          this.handleExceptionExit();
          setTimeout(() => {
            showPermissionTip();
          }, 500);
        }
      },
    });
  }

  private _hangupPermissionDeniedCall(): void {
    console.log(`${NAME.PREFIX} _hangupPermissionDeniedCall`);
    this._clearIOSLiveCommunicationKitIncoming();
    this._ringController.stopLoopRing();
    this.cancelIncomingBanner();
    this.callEngine.hangup({
      success: () => {
        console.log(`${NAME.PREFIX} _hangupPermissionDeniedCall success`);
      },
      fail: (errCode: number, errMsg: string) => {
        console.error(
          `${NAME.PREFIX} _hangupPermissionDeniedCall fail, errCode=${errCode}, errMsg=${errMsg}`
        );
      },
    });
    this._navigateBackCallPage();
    this._resetCallStore();
  }

  private _resetCallStore(): void {
    this._clearIOSLiveCommunicationKitIncoming();
    this._restoreSwitchCallTypeConfirmConfig();
    this._clearPendingSwitchCallType();
    this._clearSwitchCallTypeConfirmModal();
    this._stopTimer();
    this._ringController.reset();
    this.stopFloatWindow();
    this.cancelIncomingBanner();
    let notResetOrNotifyKeys = Object.keys(CALL_DATA_KEY).filter((key) => {
      switch (CALL_DATA_KEY[key]) {
        case NAME.CALL_STATUS:
        case NAME.LANGUAGE:
        case NAME.ENABLE_INCOMING_BANNER:
        case NAME.LOCAL_USER_INFO: {
          return false;
        }
        default: {
          return true;
        }
      }
    });
    notResetOrNotifyKeys = notResetOrNotifyKeys.map(
      (key) => CALL_DATA_KEY[key]
    );
    uni.$NEStore.reset(StoreName.CALL, notResetOrNotifyKeys);
    const callStatus = uni.$NEStore.getData(StoreName.CALL, NAME.CALL_STATUS);
    callStatus !== CallStatus.IDLE &&
      uni.$NEStore.reset(StoreName.CALL, [NAME.CALL_STATUS], true);
    uni.$NEStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, []);
  }
}

export const NECallKit = CallService.getInstance();
