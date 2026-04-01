/// <reference path="./types/index.d.ts" />

interface IAppOption {
  globalData: {
    appkey: string
    nim: any
    neCall: any
    accountId: string
    isLoggedIn: boolean
  }
  initNIM(accountId: string, token: string): Promise<void>
}
