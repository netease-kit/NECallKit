<template>
  <div class="container">
    <img class="background-image" :src="background" alt="background" />
    <div class="counter-warp">
      <div class="header-content">
        <img
          style="width: 212px; height: 27px"
          :src="logo"
          alt="logo"
        />
      </div>
      <div class="box">
        <div class="list-item">
          <label class="list-item-label">账号ID</label>
          <input
            class="input-box"
            type="text"
            :value="account"
            maxlength="50"
            placeholder="请输入账号ID"
            @input="handleAccountInput"
          />
        </div>
        <div class="list-item" style="margin-top: 15px">
          <label class="list-item-label">Token</label>
          <input
            class="input-box"
            type="text"
            :value="token"
            maxlength="50"
            placeholder="请输入Token"
            @input="handleTokenInput"
          />
        </div>
        <div class="login">
          <button class="loginBtn" :disabled="loading" @click="login">
            登录
          </button>
        </div>
        <div style="margin-top: 30px; text-align: center">
          <a
            href="https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7"
            style="color: #007bff"
            target="_blank"
            rel="noopener noreferrer"
          >
            如何获取云信账号与Token
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import './Login.css'
import background from '@/assets/background.svg'
import logo from '@/assets/logo.png'

const props = defineProps<{
  account: string
  token: string
  loading?: boolean
}>()

const emit = defineEmits<{
  (event: 'update:account', value: string): void
  (event: 'update:token', value: string): void
  (event: 'login'): void
}>()

function login(): void {
  if (!props.account) {
    window.alert('账号不能为空!')
    return
  }

  if (!props.token) {
    window.alert('Token不能为空!')
    return
  }

  emit('login')
}

function handleAccountInput(event: Event): void {
  emit('update:account', (event.target as HTMLInputElement)?.value || '')
}

function handleTokenInput(event: Event): void {
  emit('update:token', (event.target as HTMLInputElement)?.value || '')
}
</script>
