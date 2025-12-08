import { defineStore } from 'pinia'

export const useMessageStore = defineStore('message', {
  state: () => ({ messages: [] }),
  actions: {
    addMessages(msgList) {
      this.messages = [...msgList, ...this.messages]
    },
    clearMessages() {
      this.messages = []
    }
  }
})