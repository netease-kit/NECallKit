<template>
  <template v-if="nim && isLogin">
    <CallViewProvider
      :ne-call-config="neCallConfig"
      :position="callProviderPosition"
    />
    <GroupCallViewProvider
      :ne-group-call-config="neGroupCallConfig"
      :position="groupProviderPosition"
      :on-invite-click="handleInviteClick"
    />
    <Call
      :account="account"
      @call="handleCall"
      @group-call="handleGroupCall"
    />
  </template>
  <Login
    v-else
    :account="account"
    :token="token"
    :loading="loading"
    @update:account="account = $event"
    @update:token="token = $event"
    @login="login"
  />
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, shallowRef, ref, watch } from 'vue'
import V2NIM from 'nim-web-sdk-ng'
import {
  CallViewProvider,
  GroupCallViewProvider,
  call,
  getCallInstance,
  getGroupCallInstance,
  groupCall,
} from '@xkit-yx/call-kit-vue3-ui'
import type {
  NECall,
  NECallEndInfo,
  NEGroupCall,
  NEGroupCallConfig,
  NEGroupCallMember,
  NEGroupCallReceiveInfo,
  NESetupConfig,
} from '@xkit-yx/call-kit'
import Call from '@/components/Call.vue'
import Login from '@/components/Login.vue'

const appkey = '3c576300158e8ad9f81963f318b87d3d'

const nim = shallowRef<any>(null)
const isLogin = ref(false)
const loading = ref(false)
const account = ref('')
const token = ref('')
const callInstance = shallowRef<NECall>()
const groupCallInstance = shallowRef<NEGroupCall>()
const groupCallMembers = ref<NEGroupCallMember[]>([])
const boundNimForKick = shallowRef<any>(null)

const callProviderPosition = computed(() => ({
  x: window.innerWidth / 2 - 200,
  y: 10,
}))

const groupProviderPosition = computed(() => ({
  x: Math.max(window.innerWidth / 2 + 20, 420),
  y: 10,
}))

const neCallConfig = computed<NESetupConfig>(() => ({
  nim: nim.value,
  appkey,
  account: account.value,
  token: token.value,
  debug: true,
}))

const neGroupCallConfig = computed<NEGroupCallConfig>(() => ({
  nim: nim.value,
  appkey,
  account: account.value,
  token: token.value,
  debug: true,
}))

function handleDemoCallEnd(value: NECallEndInfo): void {
  if (value.reasonCode === 3) {
    window.alert('对方正在通话中')
  } else if (value.reasonCode === 14) {
    window.alert('对方已拒绝')
  } else if (value.reasonCode === 17) {
    window.alert('其他端已拒绝')
  }
}

function unbindDemoCallEnd(): void {
  if (!callInstance.value) {
    return
  }

  callInstance.value.off('onCallEnd', handleDemoCallEnd)
  callInstance.value = undefined
}

async function bindDemoCallEnd(): Promise<void> {
  await nextTick()
  const instance = getCallInstance()

  if (!instance || callInstance.value === instance) {
    return
  }

  unbindDemoCallEnd()
  instance.on('onCallEnd', handleDemoCallEnd)
  callInstance.value = instance
}

function syncDemoGroupMembers(members: NEGroupCallMember[] = []): void {
  const previousBusyMembers = new Set(
    groupCallMembers.value
      .filter((item) => item.reason === 'busy')
      .map((item) => item.imAccid)
  )
  const nextBusyMembers = members
    .filter((item) => item.state === 3 && item.reason === 'busy')
    .map((item) => item.imAccid)
    .filter((item) => !previousBusyMembers.has(item))

  groupCallMembers.value = members

  if (nextBusyMembers.length === 0) {
    return
  }

  const busyMembersText = nextBusyMembers.join('、')

  window.alert(
    nextBusyMembers.length === 1
      ? `${busyMembersText} 正在通话中`
      : `以下成员正在通话中：${busyMembersText}`
  )
}

function handleDemoGroupReceiveInvited(value: NEGroupCallReceiveInfo): void {
  groupCallMembers.value = value.members || []
}

function handleDemoGroupMembersChange(value: NEGroupCallMember[]): void {
  syncDemoGroupMembers(value)
}

function handleDemoGroupCallEnd(): void {
  groupCallMembers.value = []
}

function unbindDemoGroupEvents(): void {
  if (!groupCallInstance.value) {
    groupCallMembers.value = []
    return
  }

  groupCallInstance.value.off('onReceiveInvited', handleDemoGroupReceiveInvited)
  groupCallInstance.value.off('onMembersChange', handleDemoGroupMembersChange)
  groupCallInstance.value.off('onCallEnd', handleDemoGroupCallEnd)
  groupCallInstance.value = undefined
  groupCallMembers.value = []
}

async function bindDemoGroupEvents(): Promise<void> {
  await nextTick()
  const instance = getGroupCallInstance()

  if (!instance || groupCallInstance.value === instance) {
    return
  }

  unbindDemoGroupEvents()
  instance.on('onReceiveInvited', handleDemoGroupReceiveInvited)
  instance.on('onMembersChange', handleDemoGroupMembersChange)
  instance.on('onCallEnd', handleDemoGroupCallEnd)
  groupCallInstance.value = instance
}

function getGroupCallBusyMessage(): string {
  const singleCallStatus = callInstance.value?.signalController?.callStatus ?? 0

  switch (singleCallStatus) {
    case 1:
      return '当前正在发起一对一呼叫，请稍后再试'
    case 2:
      return '当前有待处理的一对一来电，请先处理后再发起群呼'
    case 3:
      return '当前正在一对一通话中，请先结束当前通话'
  }

  switch (groupCallInstance.value?.callStatus) {
    case 1:
      return '当前有待处理的群组通话，请先处理后再发起新的群呼'
    case 2:
      return '当前正在群组通话中，请勿重复发起群呼'
    default:
      return ''
  }
}

function getActiveGroupMemberAccounts(): string[] {
  return groupCallMembers.value
    .filter(
      (item) => item.imAccid && item.imAccid !== account.value && item.state !== 3
    )
    .map((item) => item.imAccid)
}

function normalizeInviteeInput(value: string): string[] {
  return Array.from(
    new Set(
      value
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean)
    )
  )
}

watch(
  () => Boolean(nim.value && isLogin.value),
  (ready) => {
    if (!ready) {
      unbindDemoCallEnd()
      unbindDemoGroupEvents()
      return
    }

    void bindDemoCallEnd()
    void bindDemoGroupEvents()
  }
)

function handleKickedOffline(): void {
  const currentNim = boundNimForKick.value

  isLogin.value = false
  nim.value = null
  boundNimForKick.value = null

  if (currentNim) {
    currentNim.V2NIMLoginService.off('onKickedOffline', handleKickedOffline)
  }

  window.alert('您的账号在其他设备登录，已被踢下线')
}

function unbindKickedOffline(): void {
  if (boundNimForKick.value) {
    boundNimForKick.value.V2NIMLoginService.off('onKickedOffline', handleKickedOffline)
    boundNimForKick.value = null
  }
}

onBeforeUnmount(() => {
  unbindKickedOffline()
  unbindDemoCallEnd()
  unbindDemoGroupEvents()
})

async function login(): Promise<void> {
  loading.value = true

  try {
    const instance = (V2NIM as any).getInstance({
      appkey,
      account: account.value,
      token: token.value,
      apiVersion: 'v2',
      debugLevel: 'debug',
    })

    await instance.V2NIMLoginService.login(account.value, token.value, {
      retryCount: 5,
    })

    instance.V2NIMLoginService.on('onKickedOffline', handleKickedOffline)
    boundNimForKick.value = instance
    nim.value = instance
    isLogin.value = true
  } catch (error: any) {
    window.alert(`登录失败：${error?.message || error}`)
  } finally {
    loading.value = false
  }
}

async function handleCall(invitee: string, type: number): Promise<void> {
  try {
    await call({
      accId: invitee,
      callType: String(type) as '1' | '2',
    })
  } catch (error: any) {
    window.alert(`呼叫失败：${error?.message || error}`)
  }
}

async function handleGroupCall(
  members: string[],
  type: number
): Promise<void> {
  const busyMessage = getGroupCallBusyMessage()

  if (busyMessage) {
    window.alert(busyMessage)
    return
  }

  try {
    await groupCall({
      calleeList: members,
      callType: String(type) as '1' | '2',
    } as any)
  } catch (error: any) {
    window.alert(`群呼失败：${error?.message || error}`)
  }
}

async function handleInviteClick(): Promise<void> {
  if (!groupCallInstance.value || groupCallInstance.value.callStatus !== 2) {
    window.alert('当前没有进行中的群组通话')
    return
  }

  const activeMembers = getActiveGroupMemberAccounts()

  if (activeMembers.length >= 15) {
    window.alert('邀请已达上限')
    return
  }

  const input = window.prompt(
    `请输入要追加邀请的账号ID，多个账号用英文逗号分隔。\n当前通话成员：${
      activeMembers.join('、') || '无'
    }`,
    ''
  )

  if (input === null) {
    return
  }

  const activeMemberSet = new Set(activeMembers)
  const members = normalizeInviteeInput(input)
    .filter((item) => item !== account.value)
    .filter((item) => !activeMemberSet.has(item))

  if (members.length === 0) {
    window.alert('没有可追加邀请的账号')
    return
  }

  if (activeMembers.length + members.length > 15) {
    window.alert('邀请已达上限')
    return
  }

  try {
    await groupCallInstance.value.groupInvite({
      calleeList: members,
    })
  } catch (error: any) {
    window.alert(`追加邀请失败：${error?.message || error}`)
  }
}
</script>
