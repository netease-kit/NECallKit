import { common } from '@kit.AbilityKit';
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import {
  NECallKitBridge,
  NECallPresentationMode
} from '@yunxin/callkit_ui';

const LIFECYCLE_CANCELED = -10005;
const BACKGROUND_MODES: string[] = ['audioRecording', 'audioPlayback'];

interface HarmonyRuntimeError extends Error {
  code?: number;
}

export class HarmonyCallRuntime {
  private readonly _bridge: NECallKitBridge = NECallKitBridge.getInstance();
  private _context: common.UIAbilityContext | null = null;
  private _appKey: string = '';
  private _currentUserRtcUid: number = 0;
  private _accountId: string = '';
  private _configured: boolean = false;
  private _ready: boolean = false;
  private _generation: number = 0;
  private _lifecycleQueue: Promise<void> = Promise.resolve();
  private _backgroundRunning: boolean = false;

  public configure(
    context: common.UIAbilityContext,
    appKey: string,
    currentUserRtcUid: number,
    incomingBannerEnabled: boolean,
    autoFloatingWindowWhenHomeEnabled: boolean
  ): Promise<void> {
    const generation = this._generation;
    return this.enqueue(async (): Promise<void> => {
      this.ensureCurrentGeneration(generation);
      if (this._configured) {
        if (!this.sameConfiguration(
          context,
          appKey,
          currentUserRtcUid
        )) {
          if (this._ready) {
            throw new Error('Cannot change CallEngine setup while logged in');
          }
          await this.resetConfiguration();
          this.ensureCurrentGeneration(generation);
        } else {
          this.applyRuntimePolicies(
            incomingBannerEnabled,
            autoFloatingWindowWhenHomeEnabled
          );
          await this.startBackgroundRunning(context);
          return;
        }
      }

      await this._bridge.initWithAppKey({
        context,
        appKey,
        frameWork: 'UniApp-uts',
        channel: 'dcloud',
        currentUserRtcUid,
        presentationMode: NECallPresentationMode.HOST_MANAGED
      });
      this.ensureCurrentGeneration(generation);
      this._context = context;
      this._appKey = appKey;
      this._currentUserRtcUid = currentUserRtcUid;
      this._configured = true;
      this.applyRuntimePolicies(
        incomingBannerEnabled,
        autoFloatingWindowWhenHomeEnabled
      );
      await this.startBackgroundRunning(context);
    });
  }

  public login(accountId: string, token: string): Promise<void> {
    const generation = this._generation;
    return this.enqueue(async (): Promise<void> => {
      this.ensureCurrentGeneration(generation);
      if (!this._configured) {
        throw new Error('CallEngine.setup must complete before login');
      }
      if (this._ready && this._accountId === accountId) {
        return;
      }
      await this.loginBridge(accountId, token);
      this.ensureCurrentGeneration(generation);
      this._accountId = accountId;
      this._ready = true;
    });
  }

  public logout(): Promise<void> {
    this._generation++;
    const generation = this._generation;
    this._ready = false;
    this._accountId = '';
    return this.enqueue(async (): Promise<void> => {
      const context = this._context;
      try {
        await this.logoutBridge();
        this.ensureCurrentGeneration(generation);
      } finally {
        await this.stopBackgroundRunning(context);
      }
    });
  }

  public destroy(): Promise<void> {
    this._generation++;
    const generation = this._generation;
    this._ready = false;
    this._accountId = '';
    return this.enqueue(async (): Promise<void> => {
      const context = this._context;
      try {
        await this._bridge.destroy();
        this.ensureCurrentGeneration(generation);
      } finally {
        await this.stopBackgroundRunning(context);
      }
      this._context = null;
      this._appKey = '';
      this._currentUserRtcUid = 0;
      this._configured = false;
    });
  }

  public isReady(): boolean {
    return this._ready;
  }

  public isConfigured(): boolean {
    return this._configured;
  }

  private sameConfiguration(
    context: common.UIAbilityContext,
    appKey: string,
    currentUserRtcUid: number
  ): boolean {
    return this._context === context &&
      this._appKey === appKey &&
      this._currentUserRtcUid === currentUserRtcUid;
  }

  private async resetConfiguration(): Promise<void> {
    const context = this._context;
    try {
      await this._bridge.destroy();
    } finally {
      await this.stopBackgroundRunning(context);
    }
    this._context = null;
    this._appKey = '';
    this._currentUserRtcUid = 0;
    this._accountId = '';
    this._configured = false;
    this._ready = false;
  }

  private applyRuntimePolicies(
    incomingBannerEnabled: boolean,
    autoFloatingWindowWhenHomeEnabled: boolean
  ): void {
    this._bridge.setIncomingBannerEnabled(incomingBannerEnabled);
    this._bridge.setAutoFloatingWindowWhenHomeEnabled(
      autoFloatingWindowWhenHomeEnabled
    );
  }

  private async startBackgroundRunning(context: common.UIAbilityContext): Promise<void> {
    if (this._backgroundRunning) {
      return;
    }

    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(
        context,
        BACKGROUND_MODES,
        wantAgentObj
      );
      this._backgroundRunning = true;
      console.info('[Netease-Call][HarmonyOS] continuous background task started');
    } catch (error) {
      console.warn(
        `[Netease-Call][HarmonyOS] failed to start continuous background task: ${String(error)}`
      );
    }
  }

  private async stopBackgroundRunning(
    context: common.UIAbilityContext | null
  ): Promise<void> {
    if (!this._backgroundRunning || context === null) {
      return;
    }

    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      console.info('[Netease-Call][HarmonyOS] continuous background task stopped');
    } catch (error) {
      console.warn(
        `[Netease-Call][HarmonyOS] failed to stop continuous background task: ${String(error)}`
      );
    } finally {
      this._backgroundRunning = false;
    }
  }

  private enqueue(operation: () => Promise<void>): Promise<void> {
    const result = this._lifecycleQueue.then(operation);
    this._lifecycleQueue = result.catch((): void => {});
    return result;
  }

  private loginBridge(accountId: string, token: string): Promise<void> {
    return new Promise<void>((resolve, reject): void => {
      this._bridge.loginWithAccountId(
        accountId,
        token,
        (): void => resolve(),
        (code: number, message: string): void => reject(this.runtimeError(code, message))
      );
    });
  }

  private logoutBridge(): Promise<void> {
    return new Promise<void>((resolve, reject): void => {
      this._bridge.logoutOnSuccess(
        (): void => resolve(),
        (code: number, message: string): void => reject(this.runtimeError(code, message))
      );
    });
  }

  private ensureCurrentGeneration(generation: number): void {
    if (generation !== this._generation) {
      throw this.runtimeError(LIFECYCLE_CANCELED, 'Lifecycle operation canceled');
    }
  }

  private runtimeError(code: number, message: string): HarmonyRuntimeError {
    const error = new Error(message) as HarmonyRuntimeError;
    error.code = code;
    return error;
  }
}

export const harmonyCallRuntime = new HarmonyCallRuntime();
