import type { DefineComponent } from 'vue';
import type {
  LocalViewBinding,
  NECall,
  NECallDeviceInfo,
  NECallDiagnostics,
  NECallEndInfo,
  NECallInfo,
  NECallParam,
  NECallTypeChangeInfo,
  NECallVideoRenderer,
  NEHangupParam,
  NEInviteInfo,
  NELoginConfig,
  NESetupConfig,
  RemoteViewBinding,
  ElectronCallKitRuntimeEnvOptions,
  ElectronCallKitRuntimeEnvResult,
} from '@xkit-yx/electron-callkit-sdk';

export type CallRole = 'none' | 'caller' | 'callee';
export type CallViewStatus = 0 | 1 | 2 | 3;
export type CallType = 1 | 2;
export type CallDeviceInfo = NECallDeviceInfo;
export type CallDiagnostics = NECallDiagnostics;

export interface CallDeviceState {
  videoCaptureDevices: CallDeviceInfo[];
  currentVideoCaptureDeviceId: string;
  audioRecordingDevices: CallDeviceInfo[];
  currentAudioRecordingDeviceId: string;
  audioPlaybackDevices: CallDeviceInfo[];
  currentAudioPlaybackDeviceId: string;
}

export interface CallMediaState {
  localAudioEnabled: boolean;
  localVideoEnabled: boolean;
  remoteVideoAvailable: boolean;
  remoteVideoMuted: boolean;
  remoteAudioMuted: boolean;
  localAudioMuted: boolean;
  rtcInitCompleted: boolean;
}

export interface CallState extends CallDeviceState, CallMediaState {
  callInfo?: NECallInfo;
  inviteInfo?: NEInviteInfo;
  lastEndInfo?: NECallEndInfo;
  connected: boolean;
  callStatus: CallViewStatus;
  callRole: CallRole;
  remoteAccount: string;
  callType: CallType;
  durationSeconds: number;
  kickedOfflineInfo?: {
    reason?: number;
    reasonDesc?: string;
    clientType?: number;
    customClientType?: number;
    timestampMs?: string;
  };
  lastDebugLog: string;
  noticeText: string;
  pendingSwitchCallType?: 1 | 2 | '1' | '2';
  outgoingSwitchCallType?: 1 | 2 | '1' | '2';
  diagnostics?: CallDiagnostics;
}

export interface CallEffects {
  startIncomingRing(): void | Promise<void>;
  startOutgoingRing(): void | Promise<void>;
  stopRing(): void | Promise<void>;
  acquireWakeLock(): void | Promise<void>;
  releaseWakeLock(): void | Promise<void>;
}

export interface CallkitRuntimeRingAssets {
  incomingRingUrl?: string;
  outgoingRingUrl?: string;
}

export interface CallkitRuntimeOptions {
  sdk?: NECall;
  host?: unknown;
  callEffects?: Partial<CallEffects>;
  ringAssets?: CallkitRuntimeRingAssets;
}

export interface CallkitRuntime {
  sdk: NECall;
  neCall: NECall;
  state: CallState;
  getState(): CallState;
  subscribe(listener: (state: CallState) => void): () => void;
  attach(): void;
  detach(): void;
  setup(config: NESetupConfig): Promise<NECallDiagnostics>;
  login(config?: NELoginConfig): Promise<NECallDiagnostics>;
  logout(): Promise<NECallDiagnostics>;
  getDiagnostics(): NECallDiagnostics;
  refreshDevices(): CallState;
  destroy(): void;
  call(payload: NECallParam): Promise<NECallInfo | undefined>;
  accept(): Promise<NECallInfo | undefined>;
  hangup(payload?: NEHangupParam): void;
  switchCallType(payload: NECallTypeChangeInfo): void;
  getCallInfo(): unknown | null;
  getCallConfig(): unknown | null;
  getVersion(): string;
  setTimeout(seconds: number): void;
  createVideoRenderer(): NECallVideoRenderer | null;
  setLocalView(binding: LocalViewBinding): void;
  setRemoteView(binding: RemoteViewBinding): void;
  setVideoCaptureDevice(deviceId: string): CallState;
  setAudioRecordingDevice(deviceId: string): CallState;
  setAudioPlaybackDevice(deviceId: string): CallState;
  setLocalAudioEnabled(enabled: boolean): void;
  setLocalVideoEnabled(enabled: boolean): void;
}

export interface SwitchCallTypeConfig {
  switchToVideo?: boolean;
  switchToAudio?: boolean;
}

export type SwitchCallTypeBtn = SwitchCallTypeConfig;

export interface Position {
  x: number;
  y: number;
}

export interface CallViewProviderProps {
  runtime?: CallkitRuntime | null;
  sdk?: NECall | null;
  switchCallTypeConfig?: SwitchCallTypeConfig;
  suppressIdleNotice?: boolean;
  uiConfig?: {
    switchCallTypeBtn?: SwitchCallTypeBtn;
  };
  position?: Position;
}

export interface CallViewProviderSlotProps {
  runtime: CallkitRuntime;
  state: CallState;
}

export interface CallViewProviderRef extends CallkitRuntime {}

export interface UseCallResult extends CallkitRuntime {}

export type UseCallStateResult = CallState;

export function resolveElectronCallKitRuntimeEnv(
  options?: ElectronCallKitRuntimeEnvOptions
): ElectronCallKitRuntimeEnvResult;
export function applyElectronCallKitRuntimeEnv(
  options?: ElectronCallKitRuntimeEnvOptions
): ElectronCallKitRuntimeEnvResult;
export function createCallkitRuntime(options?: CallkitRuntimeOptions): CallkitRuntime;
export function createIpcCallkitRuntime(
  host?: unknown,
  options?: CallkitRuntimeOptions
): CallkitRuntime;
export const DEFAULT_RING_ASSETS: CallkitRuntimeRingAssets;
export function useCall(): UseCallResult | undefined;
export function useCallkitRuntime(): CallkitRuntime | undefined;
export function useCallState(): UseCallStateResult;

export const CallViewProvider: DefineComponent<CallViewProviderProps>;
