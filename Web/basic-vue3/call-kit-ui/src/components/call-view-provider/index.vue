<template>
  <div
    v-if="callStatus !== 0"
    ref="draggableRootRef"
    v-draggable="{ cancel: dragCancelSelector, position }"
    class="necall-view"
  >
    <div ref="largeViewRef" class="necall-large-view" />
    <div
      ref="smallViewRef"
      class="necall-small-view"
      @click="switchPlayView"
    />

    <div v-if="noticeText" class="necall-notice-bar">
      <span>{{ noticeText }}</span>
      <button
        type="button"
        class="necall-notice-close"
        @click="noticeText = ''"
      >
        ×
      </button>
    </div>

    <template v-if="callStatus === 1">
      <div ref="previewRef" class="necall-blur-bg-mark">
        <img
          draggable="false"
          class="necall-blur-bg-img"
          :src="remoteAvatar"
          alt=""
        />
      </div>
      <div class="necall-callee-info">
        <div>
          <div class="necall-callee-nickname">正在呼叫 {{ remoteName }}</div>
          <div class="necall-callee-tips">等待对方接听...</div>
        </div>
        <img class="necall-callee-avatar" :src="remoteAvatar" alt="" />
      </div>
      <div class="necall-calling-btn-group">
        <div class="necall-btn" @click="handleHangup">
          <img draggable="false" class="necall-img" :src="hangupIcon" />
          <span>取消</span>
        </div>
      </div>
    </template>

    <template v-else-if="callStatus === 2">
      <div class="necall-blur-bg-mark">
        <img
          draggable="false"
          class="necall-blur-bg-img"
          :src="remoteAvatar"
          alt=""
        />
      </div>
      <div class="necall-caller-info">
        <img class="necall-caller-avatar" :src="remoteAvatar" alt="" />
        <div class="necall-caller-nickname">{{ remoteName }}</div>
        <div class="necall-caller-tips">
          {{ callType === '1' ? '邀请你进行语音通话...' : '邀请你进行视频通话...' }}
        </div>
      </div>
      <div class="necall-called-btn-group">
        <div class="necall-btn" @click="handleHangup">
          <img draggable="false" class="necall-img" :src="hangupIcon" />
          <span>拒绝</span>
        </div>
        <div class="necall-btn" @click="handleAccept">
          <img
            draggable="false"
            class="necall-img"
            :src="callType === '1' ? audioAcceptIcon : videoAcceptIcon"
          />
          <span>接听</span>
        </div>
      </div>
    </template>

    <template v-else-if="callStatus === 3">
      <template v-if="callType === '1'">
        <div class="necall-blur-bg-mark">
          <img
            draggable="false"
            class="necall-blur-bg-img"
            :src="remoteAvatar"
            alt=""
          />
        </div>
        <div class="necall-in-call-audio">
          <img class="necall-in-call-avatar" :src="remoteAvatar" alt="" />
          <div class="necall-in-call-title">通话中</div>
          <div class="necall-in-call-tips">{{ formattedDuration }}</div>
        </div>
      </template>
      <div v-else class="necall-in-call-duration">{{ formattedDuration }}</div>

      <div class="necall-in-call-btn-group">
        <img
          draggable="false"
          class="necall-microphone-btn"
          :src="enableLocalAudio ? microphoneOpenIcon : microphoneCloseIcon"
          @click="handleEnableLocalAudio"
        />
        <img
          v-if="callType === '2'"
          draggable="false"
          class="necall-video-btn"
          :src="enableLocalVideo ? videoOpenIcon : videoCloseIcon"
          @click="handleEnableLocalVideo"
        />
        <img
          v-if="showSwitchToVideo"
          draggable="false"
          class="necall-switch-btn"
          :src="switchVideoIcon"
          @click="requestSwitchCallType"
        />
        <img
          v-if="showSwitchToAudio"
          draggable="false"
          class="necall-switch-btn"
          :src="switchAudioIcon"
          @click="requestSwitchCallType"
        />
        <img
          draggable="false"
          class="necall-hangup-btn"
          :src="hangupIcon"
          @click="handleHangup"
        />
      </div>
    </template>

    <div v-if="switchDialog.visible" class="necall-dialog-mask">
      <div class="necall-dialog">
        <div class="necall-dialog-title">权限请求</div>
        <div class="necall-dialog-content">{{ switchDialog.content }}</div>
        <div class="necall-dialog-btn-group">
          <button
            type="button"
            class="necall-dialog-btn"
            @click="rejectSwitchCallType"
          >
            拒绝
          </button>
          <button
            type="button"
            class="necall-dialog-btn necall-dialog-btn-primary"
            @click="acceptSwitchCallType"
          >
            同意
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import {
  computed,
  defineComponent,
  nextTick,
  onMounted,
  onUnmounted,
  PropType,
  ref,
  shallowRef,
  watch,
} from 'vue'
import { NECall, NECallInfo, NECallParam } from '@xkit-yx/call-kit'
import pkg from '../../../package.json'
import draggable from '../../directives/draggable'
import type {
  CallType,
  CallViewStatus,
  CallViewProviderProps,
  CallViewProviderRef,
  NIMLike,
  Position,
  SwitchCallTypeBtn,
  UserInfo,
} from '../../interface'
import {
  registerCallProvider,
  setCallProviderMounted,
  unregisterCallProvider,
} from '../../runtime/singleton'
import {
  getUserByAccount,
  logConsoleError,
  secondToDate,
  trackInit,
} from '../../utils'
import avatarDefaultMan from '../../assets/avatar-default-man.png'
import audioAcceptIcon from '../../assets/audio-accept.png'
import hangupIcon from '../../assets/hangup.png'
import microphoneCloseIcon from '../../assets/microphone-close.png'
import microphoneOpenIcon from '../../assets/microphone-open.png'
import switchAudioIcon from '../../assets/switch-audio.png'
import switchVideoIcon from '../../assets/switch-video.png'
import videoAcceptIcon from '../../assets/video-accept.png'
import videoCloseIcon from '../../assets/video-close.png'
import videoOpenIcon from '../../assets/video-open.png'

interface SwitchDialogState {
  visible: boolean
  callType: CallType
  content: string
}

export default defineComponent({
  name: 'CallViewProvider',
  directives: {
    draggable,
  },
  props: {
    neCallConfig: {
      type: Object as PropType<CallViewProviderProps['neCallConfig']>,
      required: true,
    },
    position: {
      type: Object as PropType<Position>,
      default: () => ({ x: 100, y: 100 }),
    },
    uiConfig: {
      type: Object as PropType<CallViewProviderProps['uiConfig']>,
      default: undefined,
    },
  },
  setup(props, { expose }) {
    const neCall = shallowRef<NECall>()
    const callStatus = ref<CallViewStatus>(0)
    const callType = ref<CallType>('1')
    const remoteAccount = ref('')
    const remoteUserInfo = ref<UserInfo>()
    const enableLocalAudio = ref(true)
    const enableLocalVideo = ref(true)
    const isAccepting = ref(false)
    const noticeText = ref('')
    const duration = ref(0)
    const switchDialog = ref<SwitchDialogState>({
      visible: false,
      callType: '1',
      content: '',
    })

    const draggableRootRef = ref<HTMLDivElement>()
    const previewRef = ref<HTMLDivElement>()
    const smallViewRef = ref<HTMLDivElement>()
    const largeViewRef = ref<HTMLDivElement>()
    const localViewTarget = ref<'small' | 'large'>('small')

    const dragCancelSelector =
      '.necall-calling-btn-group, .necall-called-btn-group, .necall-in-call-btn-group, .necall-small-view, .necall-dialog-mask, .necall-notice-bar'

    const remoteAvatar = computed(
      () => remoteUserInfo.value?.avatar || avatarDefaultMan
    )
    const remoteName = computed(
      () =>
        remoteUserInfo.value?.nick ||
        remoteUserInfo.value?.tel ||
        remoteUserInfo.value?.account ||
        ''
    )
    const formattedDuration = computed(() => secondToDate(duration.value))
    const switchCallTypeBtn = computed<SwitchCallTypeBtn | undefined>(
      () => props.uiConfig?.switchCallTypeBtn
    )
    const showSwitchToVideo = computed(
      () =>
        callStatus.value === 3 &&
        callType.value === '1' &&
        (switchCallTypeBtn.value?.switchToVideo ?? false)
    )
    const showSwitchToAudio = computed(
      () =>
        callStatus.value === 3 &&
        callType.value === '2' &&
        (switchCallTypeBtn.value?.switchToAudio ?? true)
    )

    async function loadRemoteUser(account: string): Promise<void> {
      try {
        const profile = await getUserByAccount(
          props.neCallConfig.nim as unknown as NIMLike,
          account
        )

        if (profile) {
          remoteUserInfo.value = profile
        }
      } catch (err: unknown) {
        logConsoleError('获取对端用户信息失败', account, err)
      }
    }

    function resetCallState(): void {
      callStatus.value = 0
      duration.value = 0
      noticeText.value = ''
      isAccepting.value = false
      remoteAccount.value = ''
      remoteUserInfo.value = undefined
      switchDialog.value.visible = false
      localViewTarget.value = 'small'
      enableLocalAudio.value = true
      enableLocalVideo.value = true
    }

    function applyAcceptedCallType(nextType: CallType): void {
      callType.value = nextType
      enableLocalAudio.value = true
      enableLocalVideo.value = true
      noticeText.value = ''

      const callInstance = neCall.value as any
      const localStream = callInstance?.rtcController?.localStream

      if (!localStream) {
        return
      }

      const hasVideo = localStream.hasVideo?.() ?? false
      const enableVideo = nextType === '2'

      if (enableVideo !== hasVideo) {
        if (enableVideo) {
          callInstance.enableLocalVideo?.(true).then(() => {
            callInstance.muteLocalVideo?.(false)
          })
        } else {
          callInstance.muteLocalVideo?.(true).then(() => {
            callInstance.enableLocalVideo?.(false)
          })
        }
      }

      callInstance.muteLocalAudio?.(false)
    }

    function bindCallViews(): void {
      const account = remoteAccount.value
      const callInstance = neCall.value as any

      if (!account || !callInstance || !smallViewRef.value || !largeViewRef.value) {
        return
      }

      callInstance.setLocalView?.(smallViewRef.value)
      callInstance.setRemoteView?.(largeViewRef.value)
      localViewTarget.value = 'small'
    }

    async function handleCall(
      opt: NECallParam
    ): Promise<NECallInfo | undefined> {
      if (!neCall.value) {
        return undefined
      }

      noticeText.value = ''
      const nextType = opt.callType as CallType
      const result = await neCall.value.call(opt)

      remoteAccount.value = opt.accId
      callType.value = nextType
      callStatus.value = 1
      await loadRemoteUser(opt.accId)
      return result
    }

    async function handleAccept(): Promise<void> {
      if (!neCall.value || isAccepting.value || callStatus.value !== 2) {
        return
      }

      noticeText.value = ''
      isAccepting.value = true

      try {
        bindCallViews()
        await neCall.value.accept()
      } catch (err: unknown) {
        const error = err as { message?: string }

        if (error?.message === 'not be call') {
          resetCallState()
          return
        }

        isAccepting.value = false
        logConsoleError(
          '接听失败',
          remoteUserInfo.value?.account || '',
          err
        )
      }
    }

    function handleHangup(): void {
      resetCallState()
      neCall.value?.hangup()
    }

    function switchPlayView(): void {
      const remoteAccount = remoteUserInfo.value?.account
      const callInstance = neCall.value as any

      if (
        !remoteAccount ||
        !callInstance ||
        !smallViewRef.value ||
        !largeViewRef.value
      ) {
        return
      }

      if (localViewTarget.value === 'small') {
        callInstance.setLocalView?.(largeViewRef.value)
        callInstance.setRemoteView?.(smallViewRef.value)
        localViewTarget.value = 'large'
      } else {
        callInstance.setLocalView?.(smallViewRef.value)
        callInstance.setRemoteView?.(largeViewRef.value)
        localViewTarget.value = 'small'
      }

      const rtcUid = callInstance.getUidByAccId?.(remoteAccount)
      const remoteStream = callInstance.rtcController?.remoteStreams?.find(
        (item: { getId: () => unknown }) => item.getId() === rtcUid
      )

      callInstance.rtcController?.playLocalStream?.()
      if (remoteStream) {
        callInstance.rtcController?.playRemoteStream?.(remoteStream)
      }
    }

    function handleEnableLocalAudio(): void {
      const callInstance = neCall.value as any

      if (!callInstance) {
        return
      }

      callInstance.muteLocalAudio?.(enableLocalAudio.value)
      enableLocalAudio.value = !enableLocalAudio.value
    }

    function handleEnableLocalVideo(): void {
      const callInstance = neCall.value as any

      if (!callInstance) {
        return
      }

      const nextEnableVideo = !enableLocalVideo.value

      if (nextEnableVideo) {
        callInstance.enableLocalVideo?.(true).then(() => {
          callInstance.muteLocalVideo?.(false)
        })
      } else {
        callInstance.muteLocalVideo?.(true).then(() => {
          callInstance.enableLocalVideo?.(false)
        })
      }

      enableLocalVideo.value = nextEnableVideo
    }

    // Device change handling via nertc client events
    type DeviceChangeEvt = { state: 'ACTIVE' | 'INACTIVE' | 'CHANGED'; device: { deviceId: string } }

    function isActiveDeviceAffected(_track: MediaStreamTrack | null, evt: DeviceChangeEvt): boolean {
      return evt.state === 'ACTIVE' || evt.state === 'INACTIVE' || evt.device.deviceId === 'default'
    }

    const handleRecordingDeviceChanged = async (evt: DeviceChangeEvt): Promise<void> => {
      if (callStatus.value !== 3 || !enableLocalAudio.value) {
        return
      }
      const callInstance = neCall.value as any
      const localStream = callInstance?.rtcController?.localStream
      if (!isActiveDeviceAffected(null, evt)) {
        return
      }
      try {
        await callInstance.rtcController.enableLocalAudio(false)
        await callInstance.rtcController.enableLocalAudio(true)
      } catch {
        // ignore
      }
    }

    const handleCameraChanged = async (evt: DeviceChangeEvt): Promise<void> => {
      if (callStatus.value !== 3 || !enableLocalVideo.value || callType.value !== '2') {
        return
      }
      const callInstance = neCall.value as any
      const localStream = callInstance?.rtcController?.localStream
      if (!isActiveDeviceAffected(null, evt)) {
        return
      }
      try {
        await callInstance.rtcController.enableLocalVideo(false)
        await callInstance.rtcController.enableLocalVideo(true)
      } catch {
        // ignore
      }
    }

    async function requestSwitchCallType(): Promise<void> {
      if (!neCall.value) {
        return
      }

      const nextType = callType.value === '1' ? '2' : '1'

      noticeText.value = '正在等待对方响应...'

      try {
        await (neCall.value as any).switchCallType?.({
          callType: nextType,
          state: 1,
        })
      } catch (err) {
        noticeText.value = ''
        throw err
      }
    }

    function acceptSwitchCallType(): void {
      if (!neCall.value) {
        return
      }

      switchDialog.value.visible = false
      ;(neCall.value as any).switchCallType?.({
        callType: switchDialog.value.callType,
        state: 2,
      })
    }

    function rejectSwitchCallType(): void {
      if (!neCall.value) {
        return
      }

      switchDialog.value.visible = false
      ;(neCall.value as any).switchCallType?.({
        callType: switchDialog.value.callType,
        state: 3,
      })
    }

    const handleReceiveInvited = async (value: any) => {
      noticeText.value = ''
      remoteAccount.value = value.callerAccId
      callType.value = value.callType as CallType
      callStatus.value = 2
      await loadRemoteUser(value.callerAccId)
    }

    const handleCallConnected = () => {
      noticeText.value = ''
      isAccepting.value = false
      callStatus.value = 3
    }

    const handleCallEnd = () => {
      resetCallState()
    }

    const handleCallTypeChange = (value: any) => {
      const nextType = value.callType as CallType

      if (value.state === 1) {
        switchDialog.value = {
          visible: true,
          callType: nextType,
          content:
            nextType === '1'
              ? '对方请求将视频转为音频，将直接关闭您的摄像头'
              : '对方请求将音频转为视频，需要打开您的摄像头',
        }
        return
      }

      if (value.state === 2) {
        applyAcceptedCallType(nextType)
        return
      }

      if (value.state === 3) {
        noticeText.value = ''
        switchDialog.value.visible = false
        noticeText.value = '对方拒绝了您的请求'
      }
    }

    watch(
      () => callStatus.value,
      (status, _prev, onCleanup) => {
        if (status !== 3) {
          duration.value = 0
          return
        }

        const timer = window.setInterval(() => {
          duration.value += 1
        }, 1000)

        onCleanup(() => {
          window.clearInterval(timer)
        })
      },
      { immediate: true }
    )

    watch(
      [
        () => neCall.value,
        () => remoteAccount.value,
        () => callType.value,
        smallViewRef,
        largeViewRef,
      ],
      async () => {
        if (!neCall.value || !remoteAccount.value || !smallViewRef.value || !largeViewRef.value) {
          return
        }

        await nextTick()
        bindCallViews()
      }
    )

    watch(
      [() => callStatus.value, () => callType.value, previewRef],
      async () => {
        if (
          callStatus.value !== 1 ||
          callType.value !== '2' ||
          !previewRef.value ||
          !neCall.value
        ) {
          return
        }

        await nextTick()
        ;(neCall.value as any).initAndPlayLocalSteam?.(previewRef.value)
      }
    )

    onMounted(() => {
      setCallProviderMounted(true)

      const instance = NECall.getInstance()

      if (typeof window !== 'undefined') {
        ;(window as any).__necall__ = instance
      }

      instance.setup(props.neCallConfig)
      neCall.value = instance
      callStatus.value = 0

      trackInit({
        appKey: props.neCallConfig.appkey,
        version: pkg.version,
        component: 'CallKitVueUI',
      })

      instance.on('onReceiveInvited', handleReceiveInvited)
      instance.on('onCallConnected', handleCallConnected)
      instance.on('onCallEnd', handleCallEnd)
      instance.on('onCallTypeChange', handleCallTypeChange)

      const client = (instance as any).rtcController?.client
      if (client) {
        client.on('recording-device-changed', handleRecordingDeviceChanged)
        client.on('camera-changed', handleCameraChanged)
      }

      registerCallProvider(handleCall, instance)
    })

    onUnmounted(() => {
      if (neCall.value) {
        neCall.value.off('onReceiveInvited', handleReceiveInvited)
        neCall.value.off('onCallConnected', handleCallConnected)
        neCall.value.off('onCallEnd', handleCallEnd)
        neCall.value.off('onCallTypeChange', handleCallTypeChange)
        neCall.value.destroy()
      }

      const client = (neCall.value as any)?.rtcController?.client
      if (client) {
        client.off('recording-device-changed', handleRecordingDeviceChanged)
        client.off('camera-changed', handleCameraChanged)
      }

      unregisterCallProvider()
      setCallProviderMounted(false)
    })

    expose({
      call: handleCall,
      get neCall() {
        return neCall.value
      },
    } as CallViewProviderRef)

    return {
      audioAcceptIcon,
      callStatus,
      callType,
      dragCancelSelector,
      draggableRootRef,
      enableLocalAudio,
      enableLocalVideo,
      formattedDuration,
      handleAccept,
      handleEnableLocalAudio,
      handleEnableLocalVideo,
      handleHangup,
      hangupIcon,
      largeViewRef,
      microphoneCloseIcon,
      microphoneOpenIcon,
      noticeText,
      position: props.position,
      previewRef,
      rejectSwitchCallType,
      remoteAvatar,
      remoteName,
      requestSwitchCallType,
      showSwitchToAudio,
      showSwitchToVideo,
      smallViewRef,
      switchAudioIcon,
      switchDialog,
      switchPlayView,
      switchVideoIcon,
      videoAcceptIcon,
      videoCloseIcon,
      videoOpenIcon,
      acceptSwitchCallType,
    }
  },
})
</script>
