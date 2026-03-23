<template>
  <div
    v-if="callStatus !== 0 && neGroupCall"
    ref="draggableRootRef"
    v-draggable="{
      handle: '.necall-group-drag-handle',
      cancel: '.necall-group-called-btn-group, .necall-group-in-call-btn-group, .necall-group-invite-btn',
      position,
    }"
    class="necall-group-view"
  >
    <div class="necall-group-drag-handle" />

    <button
      v-if="onInviteClick && callStatus === 2"
      type="button"
      class="necall-group-invite-btn"
      @click="emitInviteClick"
    >
      +
    </button>

    <template v-if="callStatus === 1 && callerAccid">
      <div class="necall-group-invited-view-container">
        <div class="necall-group-caller-info">
          <img
            draggable="false"
            class="necall-group-caller-avatar"
            :src="callerAvatar"
            alt=""
          />
          <div class="necall-group-caller-nickname">{{ callerName }}</div>
          <div class="necall-group-caller-tips">邀请您加入多人通话</div>
          <template v-if="otherMembers.length > 0">
            <div class="necall-group-member-tips">
              还有{{ otherMembers.length }}人参与通话
            </div>
            <div class="necall-group-member-list">
              <img
                v-for="member in otherMembers"
                :key="member.account"
                draggable="false"
                class="necall-group-member-item"
                :src="member.avatar || avatarDefaultMan"
                alt=""
              />
            </div>
          </template>
        </div>
        <div class="necall-group-called-btn-group">
          <div class="necall-group-btn" @click="handleHangup">
            <img
              draggable="false"
              class="necall-group-img"
              :src="hangupIcon"
            />
            <span>拒绝</span>
          </div>
          <div class="necall-group-btn" @click="handleAccept">
            <img
              draggable="false"
              class="necall-group-img"
              :src="audioAcceptIcon"
            />
            <span>接听</span>
          </div>
        </div>
      </div>
    </template>

    <template v-else-if="callStatus === 2">
      <div class="necall-group-incall-view-container">
        <div class="necall-group-incall-scroll-view">
          <div class="necall-group-incall-duration">{{ hasAnyoneAnswered ? formattedDuration : '等待接听' }}</div>
          <Swiper :slides-per-view="1" @swiper="handleSwiperReady" @slideChange="handleSlideChange">
            <SwiperSlide
              v-for="page in memberPages"
              :key="page.id"
              :swiper-ref="swiperRef"
              class="necall-group-incall-rtc-page"
            >
              <div
                v-for="member in page.members"
                :key="member.account"
                class="necall-group-incall-rtc-view"
                :ref="(el) => setRtcViewRef(member.account, el)"
              >
                <div class="necall-group-incall-rtc-user">
                  <img
                    class="necall-group-incall-rtc-user-avatar"
                    :src="member.avatar || avatarDefaultMan"
                    alt=""
                  />
                  <div v-if="member.state !== 2" class="lds-ellipsis">
                    <div />
                    <div />
                    <div />
                    <div />
                  </div>
                </div>
                <div class="necall-group-incall-rtc-user-name">
                  {{ member.nick || member.tel || member.account }}
                </div>
              </div>
            </SwiperSlide>
          </Swiper>
          <div v-if="memberPages.length > 1" class="necall-group-pagination">
            <span
              v-for="(_, index) in memberPages"
              :key="index"
              class="necall-group-pagination-bullet"
              :class="{ 'necall-group-pagination-bullet-active': index === currentPage }"
            />
          </div>
        </div>

        <div class="necall-group-in-call-btn-group">
          <img
            draggable="false"
            class="necall-group-microphone-btn"
            :src="enableLocalAudio ? microphoneOpenIcon : microphoneCloseIcon"
            @click="handleEnableLocalAudio"
          />
          <img
            draggable="false"
            class="necall-group-video-btn"
            :src="enableLocalVideo ? videoOpenIcon : videoCloseIcon"
            @click="handleEnableLocalVideo"
          />
          <img
            draggable="false"
            class="necall-group-hangup-btn"
            :src="hangupIcon"
            @click="handleHangup"
          />
        </div>
      </div>
    </template>
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
import {
  NEGroupCall,
  NEGroupCallCallFnParams,
  NEGroupCallCallRes,
} from '@xkit-yx/call-kit'
import { Swiper, SwiperSlide } from 'swiper/vue'
import pkg from '../../../package.json'
import draggable from '../../directives/draggable'
import type {
  GroupCallViewStatus,
  GroupCallViewProviderProps,
  GroupCallViewProviderRef,
  NIMLike,
  NIMMessage,
  Position,
  UserInfo,
} from '../../interface'
import {
  registerGroupProvider,
  setGroupProviderMounted,
  unregisterGroupProvider,
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
import videoCloseIcon from '../../assets/video-close.png'
import videoOpenIcon from '../../assets/video-open.png'

interface GroupMemberState {
  imAccid: string
  state: number
}

export default defineComponent({
  name: 'GroupCallViewProvider',
  components: {
    Swiper,
    SwiperSlide,
  },
  directives: {
    draggable,
  },
  props: {
    neGroupCallConfig: {
      type: Object as PropType<GroupCallViewProviderProps['neGroupCallConfig']>,
      required: true,
    },
    position: {
      type: Object as PropType<Position>,
      default: () => ({ x: 100, y: 100 }),
    },
    onInviteClick: {
      type: Function as PropType<GroupCallViewProviderProps['onInviteClick']>,
      default: undefined,
    },
  },
  setup(props, { expose }) {
    const neGroupCall = shallowRef<NEGroupCall>()
    const callStatus = ref<GroupCallViewStatus>(0)
    const members = ref<UserInfo[]>([])
    const callerAccid = ref('')
    const duration = ref(0)
    const enableLocalAudio = ref(true)
    const enableLocalVideo = ref(false)
    const draggableRootRef = ref<HTMLDivElement>()
    const rtcViewRefs = ref<Record<string, HTMLDivElement>>({})
    const swiperRef = ref<any>()
    const currentPage = ref(0)
    const lastPayload = ref({
      content: '',
      time: 0,
    })

    const formattedDuration = computed(() => secondToDate(duration.value))
    const currentAccount = computed(
      () =>
        (props.neGroupCallConfig.nim as unknown as NIMLike | undefined)
          ?.account || ''
    )
    const callerInfo = computed(() =>
      members.value.find((item) => item.account === callerAccid.value)
    )
    const callerAvatar = computed(
      () => callerInfo.value?.avatar || avatarDefaultMan
    )
    const callerName = computed(
      () =>
        callerInfo.value?.nick ||
        callerInfo.value?.tel ||
        callerInfo.value?.account ||
        ''
    )
    const otherMembers = computed(() =>
      members.value.filter(
        (item) =>
          ![currentAccount.value, callerAccid.value].includes(item.account)
      )
    )
    // 是否有被叫方已接听（主叫方发起群呼后计时器等待此条件才启动）
    const hasAnyoneAnswered = computed(() =>
      members.value.some(
        (m) => m.account !== currentAccount.value && m.state === 2
      )
    )
    const memberPages = computed(() => {
      const activeMembers = members.value.filter((member) => member.state !== 3)
      const pages: Array<{ id: number; members: UserInfo[] }> = []

      for (let index = 0; index < activeMembers.length; index += 4) {
        pages.push({
          id: pages.length,
          members: activeMembers.slice(index, index + 4),
        })
      }

      return pages
    })

    async function updateMembers(nextMembers: GroupMemberState[]): Promise<void> {
      const resolvedMembers = await Promise.all(
        nextMembers.map(async (member) => {
          const cached = members.value.find(
            (item) => item.account === member.imAccid
          )

          if (cached) {
            return {
              ...cached,
              state: member.state,
            }
          }

          try {
            const profile = await getUserByAccount(
              props.neGroupCallConfig.nim as unknown as NIMLike,
              member.imAccid
            )

            return {
              account: profile?.account || member.imAccid,
              avatar: profile?.avatar || '',
              nick: profile?.nick || '',
              tel: profile?.tel || '',
              state: member.state,
            }
          } catch (err: unknown) {
            logConsoleError('获取对端用户信息失败', member.imAccid, err)

            return {
              account: member.imAccid,
              avatar: '',
              nick: '',
              tel: '',
              state: member.state,
            }
          }
        })
      )

      members.value = resolvedMembers
    }

    function resetGroupState(): void {
      callStatus.value = 0
      callerAccid.value = ''
      duration.value = 0
      enableLocalAudio.value = true
      enableLocalVideo.value = false
      members.value = []
      rtcViewRefs.value = {}
      currentPage.value = 0
    }

    async function handleCall(
      opt: NEGroupCallCallFnParams
    ): Promise<NEGroupCallCallRes | undefined> {
      if (!neGroupCall.value) {
        return undefined
      }

      const result = await neGroupCall.value.groupCall(opt)

      await updateMembers(
        (result?.members || []) as GroupMemberState[]
      )
      callStatus.value = 2
      return result
    }

    async function handleJoin(opt: {
      callId: string
      rtcUid?: number
    }): Promise<NEGroupCallCallRes | undefined> {
      if (!neGroupCall.value) {
        return undefined
      }

      const result = await neGroupCall.value.groupJoin(opt)

      if ((result as any)?.members) {
        await updateMembers((result as any).members)
      }

      callStatus.value = 2
      return result
    }

    async function handleAccept(): Promise<void> {
      const result = await neGroupCall.value?.groupAccept()

      await updateMembers((result?.members || []) as GroupMemberState[])
      callStatus.value = 2
    }

    function handleHangup(): void {
      neGroupCall.value?.groupHangup()
      resetGroupState()
    }

    function handleEnableLocalAudio(): void {
      const nextValue = !enableLocalAudio.value

      enableLocalAudio.value = nextValue
      ;(neGroupCall.value as any)?.enableLocalAudio?.(nextValue)
    }

    function handleEnableLocalVideo(): void {
      const nextValue = !enableLocalVideo.value

      enableLocalVideo.value = nextValue
      ;(neGroupCall.value as any)?.enableLocalVideo?.(nextValue)
    }

    function setRtcViewRef(account: string, element: any): void {
      if (!element) {
        delete rtcViewRefs.value[account]
        return
      }

      rtcViewRefs.value[account] = element
    }

    // Device change handling via nertc client events
    type DeviceChangeEvt = { state: 'ACTIVE' | 'INACTIVE' | 'CHANGED'; device: { deviceId: string } }

    function isActiveDeviceAffected(_track: MediaStreamTrack | null, evt: DeviceChangeEvt): boolean {
      return evt.state === 'ACTIVE' || evt.state === 'INACTIVE' || evt.device.deviceId === 'default'
    }

    const handleRecordingDeviceChanged = async (evt: DeviceChangeEvt): Promise<void> => {
      if (callStatus.value !== 2 || !enableLocalAudio.value) {
        return
      }
      const groupInstance = neGroupCall.value as any
      const localStream = groupInstance?.rtcController?.localStream
      if (!isActiveDeviceAffected(null, evt)) {
        return
      }
      try {
        await groupInstance.enableLocalAudio?.(false)
        await groupInstance.enableLocalAudio?.(true)
      } catch {
        // ignore
      }
    }

    const handleCameraChanged = async (evt: DeviceChangeEvt): Promise<void> => {
      if (callStatus.value !== 2 || !enableLocalVideo.value) {
        return
      }
      const groupInstance = neGroupCall.value as any
      const localStream = groupInstance?.rtcController?.localStream
      if (!isActiveDeviceAffected(null, evt)) {
        return
      }
      try {
        await groupInstance.enableLocalVideo?.(false)
        await groupInstance.enableLocalVideo?.(true)
      } catch {
        // ignore
      }
    }

    function emitInviteClick(event: MouseEvent): void {
      props.onInviteClick?.(event)
    }

    function handleSwiperReady(instance: any): void {
      swiperRef.value = instance
    }

    function handleSlideChange(instance: any): void {
      currentPage.value = instance.activeIndex
    }

    const handleReceiveInvited = async (value: any) => {
      callerAccid.value = value.callerAccid
      await updateMembers(value.members || [])
      callStatus.value = 1
    }

    const handleMembersChange = async (value: any[]) => {
      if (callStatus.value === 2) {
        await updateMembers(value as GroupMemberState[])
      }
    }

    const handleCallEnd = () => {
      resetGroupState()
    }

    const handleNimMessage = (msg: NIMMessage) => {
      if (msg.type === 'custom') {
        forwardNimPayload(msg.content)
      }
    }

    const handleCustomNotifications = (msgs: Array<{ content?: unknown }>) => {
      msgs.forEach((msg) => {
        forwardNimPayload(msg.content)
      })
    }

    const forwardNimPayload = (content: unknown) => {
      if (!content || !neGroupCall.value) {
        return
      }

      const payload =
        typeof content === 'string' ? content : JSON.stringify(content)
      const now = Date.now()

      if (
        lastPayload.value.content === payload &&
        now - lastPayload.value.time < 500
      ) {
        return
      }

      lastPayload.value = {
        content: payload,
        time: now,
      }

      ;(neGroupCall.value as any)?.receiveNimMsg?.(payload)
    }

    // 加入 RTC：callStatus 变为 2 时触发（与计时器解耦）
    watch(
      [() => callStatus.value, () => neGroupCall.value],
      ([status, instance], _prev, onCleanup) => {
        if (status !== 2 || !instance) {
          return
        }

        const joinTimer = window.setTimeout(() => {
          ;(instance as any)?.joinRtc?.({ video: false })
        }, 500)

        onCleanup(() => {
          window.clearTimeout(joinTimer)
        })
      },
      { immediate: true }
    )

    // 计时器：仅在首个被叫方接听后启动（主叫发起群呼时不计时）
    watch(
      [() => callStatus.value, hasAnyoneAnswered],
      ([status, anyoneAnswered], _prev, onCleanup) => {
        if (status !== 2 || !anyoneAnswered) {
          if (status !== 2) {
            duration.value = 0
          }
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
      [memberPages, () => neGroupCall.value, () => callStatus.value],
      async () => {
        if (callStatus.value !== 2 || !neGroupCall.value) {
          return
        }

        await nextTick()
        members.value.forEach((member) => {
          const element = rtcViewRefs.value[member.account]

          if (element) {
            ;(neGroupCall.value as any)?.setRtcView?.(element, member.account)
          }
        })
      },
      { deep: true }
    )

    onMounted(() => {
      setGroupProviderMounted(true)

      const instance = NEGroupCall.getInstance()

      instance.setup(props.neGroupCallConfig)
      neGroupCall.value = instance
      callStatus.value = 0

      trackInit({
        appKey: props.neGroupCallConfig.appkey,
        version: pkg.version,
        component: 'GroupCallKitVueUI',
      })

      instance.on('onReceiveInvited', handleReceiveInvited)
      instance.on('onMembersChange', handleMembersChange)
      instance.on('onCallEnd', handleCallEnd)

      const client = (instance as any).rtcController?.client
      if (client) {
        client.on('recording-device-changed', handleRecordingDeviceChanged)
        client.on('camera-changed', handleCameraChanged)
      }

      const nim = props.neGroupCallConfig.nim as unknown as NIMLike

      nim.on('msg', handleNimMessage as (payload: any) => void)
      nim.V2NIMNotificationService?.on(
        'onReceiveCustomNotifications',
        handleCustomNotifications as (payload: any) => void
      )

      registerGroupProvider(
        {
          groupCall: handleCall,
          groupJoin: handleJoin,
        },
        instance
      )
    })

    onUnmounted(() => {
      if (neGroupCall.value) {
        neGroupCall.value.off('onReceiveInvited', handleReceiveInvited)
        neGroupCall.value.off('onMembersChange', handleMembersChange)
        neGroupCall.value.off('onCallEnd', handleCallEnd)
        neGroupCall.value.destroy()
      }

      const client = (neGroupCall.value as any)?.rtcController?.client
      if (client) {
        client.off('recording-device-changed', handleRecordingDeviceChanged)
        client.off('camera-changed', handleCameraChanged)
      }

      const nim = props.neGroupCallConfig.nim as unknown as NIMLike

      nim.off('msg', handleNimMessage as (payload: any) => void)
      nim.V2NIMNotificationService?.off(
        'onReceiveCustomNotifications',
        handleCustomNotifications as (payload: any) => void
      )

      unregisterGroupProvider()
      setGroupProviderMounted(false)
    })

    expose({
      groupCall: handleCall,
      groupJoin: handleJoin,
      get neGroupCall() {
        return neGroupCall.value
      },
    } as GroupCallViewProviderRef)

    return {
      audioAcceptIcon,
      avatarDefaultMan,
      callStatus,
      callerAccid,
      callerAvatar,
      callerName,
      draggableRootRef,
      emitInviteClick,
      enableLocalAudio,
      enableLocalVideo,
      formattedDuration,
      hasAnyoneAnswered,
      handleAccept,
      handleEnableLocalAudio,
      handleEnableLocalVideo,
      handleHangup,
      hangupIcon,
      memberPages,
      microphoneCloseIcon,
      microphoneOpenIcon,
      neGroupCall,
      onInviteClick: props.onInviteClick,
      otherMembers,
      position: props.position,
      setRtcViewRef,
      handleSwiperReady,
      handleSlideChange,
      currentPage,
      swiperRef,
      videoCloseIcon,
      videoOpenIcon,
    }
  },
})
</script>
