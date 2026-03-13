import React, { useEffect } from 'react'
import qs from 'qs'
import pkg from '../package.json'
import NECallEngine from './neCall'
import NIM from '@yxim/nim-web-sdk/dist/SDK/NIM_Web_NIM'
import WebAT from 'hawk-web'
import { NESetupConfig } from './neCallTypes'

export default {
  title: 'CALL KIT/呼叫组件',
}
let nim

class NECallTest extends NECallEngine {
  constructor(data) {
    const { token, account, appkey } = data

    if (!nim) {
      nim = NIM.getInstance({
        debug: true,
        appKey: appkey,
        account,
        token,
      })
    }

    super()
  }

  public setup(params: NESetupConfig): void {
    super.setup({ ...params, nim, debug: true })
    const localView = document.getElementById('localView')

    localView && super.setLocalView(localView)
    const remoteView = document.getElementById('remoteView')

    remoteView && super.setRemoteView(remoteView)
  }
}

export const SingleApiTest: React.FC = () => {
  useEffect(() => {
    const query = qs.parse(location.search)
    const { testDeviceId, taskId } = query

    console.log(window.location.search)
    new WebAT({
      applicationName: 'callkit',
      platform: 'Web',
      taskId,
      version: pkg.version,
      deviceId: testDeviceId, // todo 修改为端1到id
      targets: {
        NECallEngine: NECallTest,
      },
    })
  }, [])
  return (
    <>
      <div id="localView"></div>
      <div id="remoteView"></div>
    </>
  )
}
