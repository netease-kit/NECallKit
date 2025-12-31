import React, { useEffect, useMemo } from 'react'
import { CallViewProvider, CallViewProviderRef } from '@xkit-yx/call-kit-react-ui'
import '@xkit-yx/call-kit-react-ui/es/style'
import V2NIM from 'nim-web-sdk-ng'
import Login from '../components/Login'
import Call from '../components/Call'

const appkey = '' // 请填写你的appkey

let nim: V2NIM | null = null

const IndexPage = () => {
  const [isLogin, setIsLogin] = React.useState(false)
  const callViewProviderRef = React.createRef<CallViewProviderRef>()

  const [loading, setLoading] = React.useState(false)
  const [account, setAccount] = React.useState("")
  const [token, setToken] = React.useState("")


  return nim && isLogin ? (
    <CallViewProvider
      ref={callViewProviderRef}
      neCallConfig={{
        nim,
        appkey, // 应用 
        debug: true,
      }}
      position={{
        x: window.innerWidth/2 - 200,
        y: 10,
      }}
    >
      <Call account={account} onCall={(accId, callType) => {
        callViewProviderRef.current?.call({
          accId, // 被叫im账号
          callType // 1: 音频通话 2: 视频通话
        })
        .catch((error) => {
          alert("呼叫失败：" + error.message)
        })
      }} />
    </CallViewProvider>
  ) : <Login
        account={account}
        onAccountChange={setAccount}
        token={token}
        onTokenChange={setToken}
        onLogin={() => {
          setLoading(true)
          nim = V2NIM.getInstance({
            appkey,
            account,
            token,
            apiVersion: 'v2',
            debugLevel: 'debug',
          })
          nim.V2NIMLoginService.login(account, token, {
            retryCount: 5,
          }).then(() => {
            setIsLogin(true)
          }).catch((error) => {
            alert("登录失败：" + error.message)
          }).finally(() => {
            setLoading(false)
          })
        }}
        loading={loading}
      />
}

export default IndexPage