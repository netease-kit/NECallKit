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
  AudioPlaybackDevice,
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

const innerAudioContext = uni.createInnerAudioContext();

class CallService {
  static instance = null;
  public callEngine: any;
  private _timerId: number = -1;
  private _startTimeStamp: number = performanceNow();
  private _isInForeground: boolean = false;

  constructor() {
    console.log(`${NAME.PREFIX} constructor`);
    this.callEngine = new CallEngine();
    this._addListener();

    uni.onAppHide(() => {
      console.log(`${NAME.PREFIX} onAppHide`);
      this._isInForeground = false;
    });
    uni.onAppShow(() => {
      console.log(`${NAME.PREFIX} onAppShow`);
      this._isInForeground = true;
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
    this.callEngine.on("onCallReceived", (res) => {
      console.log(
        `${NAME.PREFIX} onCallReceived, data: ${JSON.stringify(res)}`
      );
      !this._isInForeground && this.bringAppToForeground();
      this._hasPermission(res?.info?.callType);
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
        [NAME.CHAT_GROUP_ID]: res?.info?.chatGroupId,
      };
      uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);
      getApp().globalData.timeout > 0 && this._navigateToCallPage();
    });

    this.callEngine.on("onCallConnected", (res) => {
      console.log(`${NAME.PREFIX} onCallConnected, data: ${JSON.stringify(res)}`);
      
      const callType = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.MEDIA_TYPE
      );
      this.startService(callType);
      
      const callStatus = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.CALL_STATUS
      );
      if (callStatus === CallStatus.CALLING) {
        uni.$NEStore.update(
          StoreName.CALL,
          NAME.CALL_STATUS,
          CallStatus.CONNECTED
        );
        uni.$NEStore.update(StoreName.CALL, NAME.CALL_TIPS, "");
        this._startTimer();
      }
    });

    this.callEngine.on("onCallEnd", (res) => {
      console.log(`${NAME.PREFIX} onCallEnd, data: ${JSON.stringify(res)}`);
      
      const callType = uni.$NEStore.getData(
        StoreName.CALL,
        NAME.MEDIA_TYPE
      );
      this.stopService(callType);
      
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this._resetCallStore();
      
      //呼叫超时
      if (res?.info?.reasonCode == 2) {
        const toastInfo = {
          key: CallTips.CALL_TIMEOUT,
        };
        toast.show(t(toastInfo));
        
        // innerAudioContext.src = '/static/audio/avchat_no_response.mp3';
        // innerAudioContext.play();
      }
      
      //对方已拒绝
      if (res?.info?.reasonCode == 14) {
        const toastInfo = {
          key: CallTips.OTHER_SIDE_REJECT_CALL,
        };
        toast.show(t(toastInfo));
        
        innerAudioContext.src = '/static/audio/avchat_peer_reject.mp3';
        innerAudioContext.play();
      }
      
      //对方忙线
      if (res?.info?.reasonCode == 3) {
        const toastInfo = {
          key: CallTips.OTHER_SIDE_LINE_BUSY,
        };
        toast.show(t(toastInfo));
        
        innerAudioContext.src = '/static/audio/avchat_peer_busy.mp3';
        innerAudioContext.play();
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
      this._navigateBackCallPage();
      this.stopFloatWindow();
      this._resetCallStore();
    });

    this.callEngine.on("onFloatWindowClick", (res) => {
      console.log(
        `${NAME.PREFIX} onFloatWindowClick, data: ${JSON.stringify(res)}`
      );
      this.stopFloatWindow();
      this._navigateToCallPage();
    });
  }

  private _removeListenr(): void {
    this.callEngine.off("onError");
    this.callEngine.off("onCallReceived");
    this.callEngine.off("onCallBegin");
    this.callEngine.off("onCallEnd");
    this.callEngine.off("onCallNotConnected");
    this.callEngine.off("onFloatWindowClick");
  }
  
  public init(options: InitParams): void {
    console.log(`${NAME.PREFIX} init setup, data: ${JSON.stringify(options)}`);
    this.callEngine.setup(options)
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
    const params: CallParams = {
      accountId: options.accountId,
      callType: options.callType,
      params: options.params,
      success: () => {
        this._hasPermission(options.callType);
        let callTips = CallTips.CALLER_CALLING_MSG;
        let updateStoreParams = {
          [NAME.CALL_ROLE]: CallRole.CALLER,
          [NAME.CALL_STATUS]: CallStatus.CALLING,
          [NAME.MEDIA_TYPE]: options?.callType,
          [NAME.CALL_TIPS]: t(callTips),
          [NAME.CHAT_GROUP_ID]: options?.info?.chatGroupID,
        };
        uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);
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
  }

  public accept(options?: AcceptParams): void {
    console.log(`${NAME.PREFIX} accept`);
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
    console.log(`${NAME.PREFIX} startFloatWindow`);
    this.callEngine.startFloatWindow({
      success: () => {
        console.log(`${NAME.PREFIX} startFloatWindow success `);
        uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, true);
        this._navigateBackCallPage();
      },
      fail: () => {
        console.log(`${NAME.PREFIX} startFloatWindow fail`);
      },
    });
  }


  public stopFloatWindow(): void {
    console.log(`${NAME.PREFIX} stopFloatWindow`);
    this.callEngine.stopFloatWindow();
    uni.$NEStore.update(StoreName.CALL, NAME.ENABLE_FLOAT_WINDOW, false);
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
        this.reject();
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

  private _hasPermission(type: number) {
    console.log(`${NAME.PREFIX} _hasPermission, data: ${type}`);
    this.callEngine.hasPermission({
      type,
      success: () => {
        console.log(`${NAME.PREFIX} _hasPermission success`);
      },
      fail: (errCode, errMsg) => {
        console.log(`${NAME.PREFIX} _hasPermission fail`);
        toast.show('未授权摄像头/麦克风权限！');
        this.handleExceptionExit();
      },
    });
  }

  private _resetCallStore(): void {
    this._stopTimer();
    this.stopFloatWindow();
    let notResetOrNotifyKeys = Object.keys(CALL_DATA_KEY).filter((key) => {
      switch (CALL_DATA_KEY[key]) {
        case NAME.CALL_STATUS:
        case NAME.LANGUAGE:
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
