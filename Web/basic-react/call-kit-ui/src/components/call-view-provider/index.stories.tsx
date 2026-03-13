import { Login, logoutFn, Session } from '@xkit-yx/login-react-ui'
import '@xkit-yx/login-react-ui/lib/style'
import { request } from '@xkit-yx/utils'
import { Button, Form, Input, message, Modal, Switch, Tag } from 'antd'
import 'antd/lib/button/style'
import { FormInstance } from 'antd/lib/form'
import 'antd/lib/input/style'
import 'antd/lib/modal/style'
import 'antd/lib/tag/style'
import WebAT from 'hawk-web'
import qs from 'qs'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import CallViewProvider, { useCall } from '.'
import './style'

import UIRecord from '@xkit-yx/ui-record'
import { secondToDate } from '../../utils'
import V2NIM, { V2NIMConst } from 'nim-web-sdk-ng'
import {
  V2NIMMessage,
  V2NIMMessageCallAttachment,
} from 'nim-web-sdk-ng/dist/v2/NIM_BROWSER_SDK/V2NIMMessageService'

const { Search } = Input

const baseUrl = process.env.BASEURL || ''
const appKey = process.env.APPKEY || ''

const urlMap = {
  loginRegisterByCode: '/auth/loginBySmsCode',
  getLoginSmsCode: '/auth/sendLoginSmsCode',
}

function parseSearch(search: string): { [key: string]: string } {
  const params: { [key: string]: string } = {}
  const searchParams = new URLSearchParams(search)

  // @ts-ignore
  for (const [key, value] of searchParams) {
    params[key] = value
  }

  return params
}

export default {
  title: 'CALL KIT/呼叫组件',
}

interface User {
  avatar: string
  imAccid: string
  mobile: string
  tel: string
  nickname: string
  nick: string
  account: string
  imToken?: string
  accessToken?: string
  isMyFriend?: boolean
}

interface FormItemProps {
  value?: string
  onChange?: (value: string) => void
}

interface TimeoutInputProps extends FormItemProps {
  onSetTimeout: () => void
}

const TimeoutInput = (props: TimeoutInputProps) => {
  const { value, onChange, onSetTimeout } = props

  return (
    <Input.Group compact>
      <Input
        style={{ width: 200 }}
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
      />
      <Button type="primary" onClick={() => onSetTimeout()}>
        设置
      </Button>
    </Input.Group>
  )
}

interface UserViewProps {
  userInfo: User
  nim: V2NIM
  onLogout: () => void
  messageList: V2NIMMessage[]
}

const UserView: React.FC<UserViewProps> = (props) => {
  const { userInfo, nim, onLogout, messageList } = props
  const [searchResult, setSearchResult] = useState<User>()
  const [searchErrMsg, setSearchErrMsg] = useState<string>('')
  const [messageTexts, setMessageTexts] = useState<
    { text: string; id: number }[]
  >([])
  const formRef = useRef<FormInstance>(null)
  const { call, neCall } = useCall()

  const handleMessage = (
    attach: V2NIMMessageCallAttachment,
    imAccid: string
  ): void => {
    let account = imAccid
    let msg = ''

    switch (attach.status) {
      case 1: {
        msg += '正常接听'
        const item = attach.durations.find(
          (duration) => duration.accountId !== userInfo.imAccid
        )

        if (item) {
          account = item.accountId
          msg += `通话时长 ${secondToDate(item.duration)}`
        }

        break
      }

      case 2:
        msg += '未接听'
        break
      case 3:
        msg += '拒绝'
        break
      case 4:
        msg += '超时'
        break
      case 5:
        msg += '占线'
        break
      default:
        msg += '未知'
        break
    }

    nim.V2NIMUserService.getUserList([account]).then((res) => {
      res.forEach((user) => {
        msg = user.mobile + '，' + msg
        setMessageTexts([{ text: msg, id: Date.now() }, ...messageTexts])
      })
    })
  }

  useEffect(() => {
    messageList.forEach((msg) => handleMessage(msg.attachment, msg.senderId))
  }, [messageList])

  useEffect(() => {
    const handleMessageSend = (data: V2NIMMessage) => {
      handleMessage(data.attachment, data.receiverId)
    }

    neCall?.on('onRecordSend', handleMessageSend)
    return () => {
      neCall?.off('onRecordSend', handleMessageSend)
    }
  }, [neCall, messageTexts])

  const handleAddFriend = () => {
    if (searchResult) {
      nim.V2NIMFriendService.addFriend(searchResult.imAccid, {
        addMode: V2NIMConst.V2NIMFriendAddMode.V2NIM_FRIEND_MODE_TYPE_ADD,
        postscript: '',
      }).then(() => {
        setSearchResult({ ...searchResult, isMyFriend: true })
      })
    }
  }

  const handleLogout = async () => {
    Modal.confirm({
      title: '确认注销当前登录账户？',
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        await neCall?.hangup()
        await logoutFn()
        onLogout()
        window.location.reload()
      },
    })
  }

  const onSearch = async () => {
    try {
      const data = await formRef.current?.validateFields(['mobile'])

      setSearchErrMsg('')
      setSearchResult(undefined)
      const res = await request({
        url: `${baseUrl}/p2pVideoCall/caller/searchSubscriber`,
        headers: {
          accessToken: userInfo.accessToken,
          appKey,
        },
        data,
      })

      if (!res.data) {
        setSearchErrMsg('搜索结果为空')
        return
      }

      if (res.data.imAccid === userInfo.imAccid) {
        setSearchErrMsg('不能搜索自己')
      } else {
        try {
          const isMyFriend = (
            await nim.V2NIMFriendService.checkFriend([res.data.imAccid])
          )[res.data.imAccid]

          setSearchResult({
            ...res.data,
            isMyFriend,
          })
        } catch (error) {
          setSearchErrMsg('失败，请重新搜索')
        }
      }
    } catch (err: unknown) {
      const error = err as { msg: string }

      error.msg && setSearchErrMsg(error.msg)
    }
  }

  const handleSetCallTimeout = async () => {
    try {
      const data = await formRef.current?.validateFields(['callTimeout'])

      if (data.callTimeout >= 120 * 1000) {
        message.error('超过120秒，请重新设置')
      } else {
        neCall?.setTimeout(data.callTimeout)
        message.success('设置成功')
      }
    } catch (err) {
      message.error('设置失败')
    }
  }

  const handleCall = async (type: '1' | '2') => {
    const accId = searchResult?.imAccid || ''

    if (!navigator.onLine) {
      message.error('网络异常，请检查网络')
      return
    }

    call?.({
      accId,
      callType: type,
    })
  }

  const setEnableSwitchCallTypeConfirm = (
    type: 'video' | 'audio',
    enable: boolean
  ) => {
    if (type === 'video') {
      neCall?.setCallConfig({ enableSwitchVideoConfirm: enable })
    }

    if (type === 'audio') {
      neCall?.setCallConfig({ enableSwitchAudioConfirm: enable })
    }
  }

  const setEnableJoinRTCChannelWhenCall = (enable: boolean) => {
    neCall?.setCallConfig({ enableJoinRtcWhenCall: enable })
  }

  return (
    <>
      <div>
        {userInfo.nickname}（手机号：{userInfo.mobile}）{' '}
        <Tag color="#87d068">已登录</Tag>
        <Button onClick={() => handleLogout()}>退出登录</Button>
      </div>
      <Form ref={formRef} validateTrigger={false} style={{ marginTop: 10 }}>
        <Form.Item
          label="超时时间"
          name="callTimeout"
          initialValue={30}
          rules={[
            {
              required: true,
              message: '请输入超时时间',
            },
            {
              pattern: /^\+?[1-9]\d*$/,
              message: '请输入大于0的整数',
            },
          ]}
        >
          <TimeoutInput onSetTimeout={handleSetCallTimeout} />
        </Form.Item>
        <Form.Item
          label="切换为视频需要确认"
          name="confirmVideo"
          valuePropName="checked"
        >
          <Switch
            onChange={(e) => setEnableSwitchCallTypeConfirm('video', e)}
          />
        </Form.Item>
        <Form.Item
          label="切换为音频需要确认"
          name="confirmAudio"
          valuePropName="checked"
        >
          <Switch
            onChange={(e) => setEnableSwitchCallTypeConfirm('audio', e)}
          />
        </Form.Item>
        <Form.Item
          label="是否提前加入RTC房间"
          name="joinRtcChannel"
          valuePropName="checked"
        >
          <Switch onChange={(e) => setEnableJoinRTCChannelWhenCall(e)} />
        </Form.Item>
        <Form.Item
          name="mobile"
          rules={[
            { required: true, message: '请填写手机号' },
            {
              pattern:
                /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/,
              message: '请填写正确的手机号',
            },
          ]}
        >
          <Search
            style={{ width: 200, display: 'block', marginTop: 10 }}
            maxLength={11}
            placeholder="通过手机号搜索用户"
            onSearch={onSearch}
            enterButton
          />
        </Form.Item>
      </Form>
      <div style={{ color: 'red' }}>{searchErrMsg}</div>
      {searchResult && (
        <>
          {searchResult.nickname}
          (手机号：{searchResult.mobile})
          {searchResult?.isMyFriend ? (
            <>
              <Button
                type="primary"
                style={{ marginLeft: 10 }}
                onClick={() => handleCall('1')}
              >
                拨打音频
              </Button>
              <Button
                type="primary"
                style={{ marginLeft: 10 }}
                onClick={() => handleCall('2')}
              >
                拨打视频
              </Button>
            </>
          ) : (
            <Button
              type="primary"
              style={{ marginLeft: 10 }}
              onClick={() => handleAddFriend()}
            >
              添加好友
            </Button>
          )}
        </>
      )}
      {messageTexts.map((msg) => (
        <p key={msg.id}>{msg.text}</p>
      ))}
    </>
  )
}

export const Single: React.FC = () => {
  // 0： 初始化
  // 1： 已登录
  // 2： 未登录
  const autoLogin = true
  const [loginState, setLoginState] = useState<number>(autoLogin ? 0 : 2)
  const [messageList, setMessageList] = useState<V2NIMMessage[]>([])
  const [userInfo, setUserInfo] = useState<User>()

  const nim = useMemo(() => {
    if (userInfo) {
      return V2NIM.getInstance({
        appkey: appKey,
        token: userInfo?.imToken,
        account: userInfo?.imAccid,
        debugLevel: 'debug',
        apiVersion: 'v2',
      })
    }
  }, [userInfo])

  useEffect(() => {
    if (nim && userInfo) {
      // 当 App 完成渲染后，登录 IM
      nim.V2NIMLoginService.login(userInfo.imAccid, userInfo.imToken || '', {
        retryCount: 5,
      })
    }

    // 当 App 卸载时，登出 IM
    return () => {
      if (nim) {
        nim.V2NIMLoginService.logout()
      }
    }
  }, [nim, userInfo])

  useEffect(() => {
    const onDataSync = () => {
      nim?.V2NIMUserService.updateSelfUserProfile({
        name: userInfo?.nickname,
        avatar: userInfo?.avatar,
        mobile: userInfo?.mobile,
      })
    }

    const onReceiveMessages = (msgs: V2NIMMessage[]) => {
      msgs.forEach((item) => {
        if (
          item.messageType ===
          V2NIMConst.V2NIMMessageType.V2NIM_MESSAGE_TYPE_CALL
        ) {
          setMessageList([...messageList, item])
        }
      })
    }

    if (nim) {
      nim.V2NIMLoginService.on('onDataSync', onDataSync)
      nim.V2NIMMessageService.on('onReceiveMessages', onReceiveMessages)
    }

    return () => {
      if (nim) {
        nim.V2NIMLoginService.off('onDataSync', onDataSync)
        nim.V2NIMMessageService.off('onReceiveMessages', onReceiveMessages)
      }
    }
  }, [nim, userInfo])

  const loginProps = {
    autoLogin,
    componentTag: 'call',
    baseDomain: baseUrl,
    appKey,
    parentScope: 2,
    scope: 7,
    urlMap,
    success: async (res) => {
      setUserInfo(res)
      setLoginState(1)
    },
    fail: () => {
      setLoginState(2)
    },
  }

  useEffect(() => {
    new UIRecord()
  }, [])

  useEffect(() => {
    const query = qs.parse(location.search)
    const { testDeviceId, taskId } = query

    console.log('UI自动化测试设备', window.location.search, testDeviceId)
    new WebAT({
      applicationName: 'callkitUI',
      platform: 'web',
      taskId,
      version: '1.7.0',
      deviceId: testDeviceId,
      targets: {},
    })
  }, [])

  return (
    <Session {...loginProps} memoryMode="sessionStorage">
      {loginState === 0 && null}
      {loginState === 1 && userInfo && nim && (
        <CallViewProvider
          neCallConfig={{
            nim,
            appkey: appKey,
            debug: true,
            enableMarkInviteEventDelay:
              // @ts-ignore
              parseSearch(location.search).enableMarkInviteEventDelay == 1
                ? true
                : false,
          }}
          uiConfig={{
            switchCallTypeBtn: {
              switchToVideo: true,
            },
          }}
          position={{
            x: 500,
            y: 10,
          }}
        >
          <UserView
            userInfo={userInfo}
            nim={nim}
            messageList={messageList}
            onLogout={() => setLoginState(2)}
          />
        </CallViewProvider>
      )}
      {loginState === 2 && <Login />}
    </Session>
  )
}
