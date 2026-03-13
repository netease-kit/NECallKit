# 网易云信

## 安装

```bash
npm install @xkit-yx/call-kit-react-ui
// or
yarn add @xkit-yx/call-kit-react-ui
```

## 单呼

### 使用示例

#### 初始化

```tsx
import React, { useState, useEffect } from 'react'
import { CallViewProvider } from '@xkit-yx/call-kit-react-ui'
import NIM from 'xxxx' // im sdk path

// ...

export default () => {
  const [nim, setNim] = useState()

  useEffect(() => {
    const im = NIM.getInstance({
      appKey: 'xxxx', // im appkey
      token: 'xxxx', // im token
      account: 'xxxx', // im account
      debugLevel: 'debug',
      lbsUrls: ['xxxx'],
      linkUrl: 'xxxx',
      onconnect: () => {
        setNim(im)
      },
    })
    return () => {
      im.disconnect()
    }
  }, [])

  return nim ? (
    <CallViewProvider
      neCallConfig={{
        nim,
        appKey,
        currentUserInfo: { accId: 'xxx' }, // 当前用户的accId
        debug: true,
      }}
      position={{
        x: 500,
        y: 10,
      }}
    >
      <App />
    </CallViewProvider>
  ) : null
}
```

#### 其他子组件

```tsx
import { useCall } from '@xkit-yx/call-kit-react-ui'

// ...

export default () => {
  const { call } = useCall()
  const handleClick = () => {
    call({
      accId: 'userId',
      type: '2',
    })
  }
  return <button onClick={handleClick}>发起呼叫</button>
}
```

## 群呼

### 使用示例

#### 初始化

```tsx
import React, { useState, useEffect } from 'react'
import {
  GroupCallViewProvider,
  GroupCallViewProviderRef,
} from '@xkit-yx/call-kit-react-ui'
import NIM from 'xxxx' // im sdk path

// ...

export default () => {
  const [nim, setNim] = useState()
  const groupCallViewProviderRef = useRef<GroupCallViewProviderRef>(null)

  useEffect(() => {
    const im = NIM.getInstance({
      appKey: 'xxxx', // im appkey
      token: 'xxxx', // im token
      account: 'xxxx', // im account
      debugLevel: 'debug',
      lbsUrls: ['xxxx'],
      linkUrl: 'xxxx',
      onconnect: () => {
        setNim(im)
      },
      shouldIgnoreMsg: (msg) => {
        if (msg.type === 'custom') {
          return groupCallViewProviderRef.current?.onMsg?.(msg.content)
        } else {
          return false
        }
      },
    })
    return () => {
      im.disconnect()
    }
  }, [])

  return nim ? (
    <GroupCallViewProvider
      neGroupCallConfig={{
        nim,
        currentUserInfo: { accId: 'xxx' },
        appKey,
        debug: true,
      }}
      position={{ x: 500, y: 10 }}
      ref={groupCallViewProviderRef}
    >
      <App />
    </GroupCallViewProvider>
  ) : null
}
```

#### 其他子组件

```tsx
import { useGroupCall } from '@xkit-yx/call-kit-react-ui'

// ...

export default () => {
  const { groupCall } = useGroupCall()
  const handleClick = () => {
    groupCall({ calleeList: ['xxxxx'] })
  }
  return <button onClick={handleClick}>发起呼叫</button>
}
```
