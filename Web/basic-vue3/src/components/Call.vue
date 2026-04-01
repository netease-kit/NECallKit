<template>
  <div class="call-container">
    <div>
      <div
        style="
          display: flex;
          align-items: center;
          padding: 10px 0;
          color: #1f1f26;
        "
      >
        <label>您的ID</label>
        <div style="margin-left: 10px">{{ account }}</div>
      </div>

      <div class="call-section-title">一对一通话</div>
      <div class="search">
        <div class="call-input-box">
          <input
            v-model.trim="invitee"
            class="input-search-user"
            type="text"
            maxlength="50"
            placeholder="请输入账号ID"
          />
        </div>
        <div class="btn-search" @click="startCall">呼叫</div>
      </div>

      <div class="call-radio-row">
        <div>呼叫类型</div>
        <div class="call-radio-group">
          <label class="call-radio-label">
            <input v-model="callType" type="radio" :value="2" />
            <span>视频呼叫</span>
          </label>
          <label class="call-radio-label">
            <input v-model="callType" type="radio" :value="1" />
            <span>音频呼叫</span>
          </label>
        </div>
      </div>
    </div>

    <div class="call-divider" />

    <div>
      <div class="call-section-title">群组通话</div>
      <div class="search">
        <div class="call-input-box">
          <input
            v-model.trim="groupMembers"
            class="input-search-user"
            type="text"
            maxlength="200"
            placeholder="多个账号用英文逗号分隔"
          />
        </div>
        <div class="btn-search" @click="startGroupCall">发起群呼</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import './Call.css'

const props = defineProps<{
  account: string
}>()

const emit = defineEmits<{
  (event: 'call', invitee: string, callType: number): void
  (event: 'group-call', members: string[], callType: number): void
}>()

const invitee = ref('')
const groupMembers = ref('')
const callType = ref(2)

function startCall(): void {
  if (!invitee.value) {
    window.alert('请输入账号ID')
    return
  }

  if (props.account === invitee.value) {
    window.alert('不能呼叫自己')
    return
  }

  emit('call', invitee.value, callType.value)
}

function startGroupCall(): void {
  const members = groupMembers.value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean)
    .filter((item) => item !== props.account)

  if (members.length === 0) {
    window.alert('请至少输入一个被叫账号')
    return
  }

  emit('group-call', members, callType.value)
}
</script>
