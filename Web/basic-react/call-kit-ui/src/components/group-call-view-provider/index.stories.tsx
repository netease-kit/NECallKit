import V2NIM from 'nim-web-sdk-ng'
import React, { useEffect, useRef, useState } from 'react'
import GroupCallViewProvider, {
  GroupCallViewProviderRef,
  useGroupCall,
} from './index'
import { request, Storage } from '@xkit-yx/utils'
import { Login, Session, logoutFn } from '@xkit-yx/login-react-ui'
import '@xkit-yx/login-react-ui/lib/style'
import { Tag, Button, Input, Form, message, Modal } from 'antd'
import 'antd/lib/tag/style'
import 'antd/lib/button/style'
import 'antd/lib/input/style'
import 'antd/lib/message/style'
import 'antd/lib/modal/style'
import './style'

import { NEGroupCallMember } from '@xkit-yx/call-kit'
import { commonError } from '../../types'

const { Search } = Input

const baseUrl = process.env.BASEURL || ''
const appKey = process.env.APPKEY || ''

const urlMap = {
  loginRegisterByCode: '/auth/loginBySmsCode',
  getLoginSmsCode: '/auth/sendLoginSmsCode',
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
  inCall?: boolean
  reason?: string
}

interface UserViewProps {
  userInfo: User
  onLogout: () => void
}

const UserView: React.FC<UserViewProps> = (props) => {
  const { userInfo, onLogout } = props
  const [storage, setStorage] = useState(
    new Storage('localStorage', `group-call-demo-${userInfo.imAccid}`)
  )
  const [searchResult, setSearchResult] = useState<User>()
  const [searchResultList, setSearchResultList] = useState<User[]>([])
  const [members, setMembers] = useState<NEGroupCallMember[]>([])
  const [selectedUsers, setSelectedUsers] = useState<User[]>([])
  const [form] = Form.useForm()
  const { groupCall, neGroupCall } = useGroupCall()

  useEffect(() => {
    const storage = new Storage(
      'localStorage',
      `group-call-demo-${userInfo.imAccid}`
    )

    setStorage(storage)
  }, [userInfo.imAccid])

  useEffect(() => {
    const searchResultList = storage?.get('searchResultList') || []

    setSearchResultList(searchResultList)
  }, [storage])

  useEffect(() => {
    function handleMembersChange(members: NEGroupCallMember[]) {
      const end = !!members.find(
        (member) => member.imAccid === userInfo.imAccid && member.state === 3
      )

      if (end) {
        members = members.filter((member) => member.state === 3)
      }

      setMembers(members)
    }

    neGroupCall?.on('onMembersChange', handleMembersChange)
    return () => {
      neGroupCall?.off('onMembersChange', handleMembersChange)
    }
  }, [neGroupCall, userInfo])

  const handleLogout = async () => {
    Modal.confirm({
      title: '确认注销当前登录账户？',
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        if (neGroupCall?.callStatus !== 0) {
          await neGroupCall?.groupHangup()
        }

        await logoutFn()
        onLogout()

        window.location.reload()
      },
    })
  }

  const onSearch = async () => {
    try {
      const data = await form.validateFields(['mobile'])
      const index = searchResultList.findIndex(
        (item) => item.mobile === data.mobile
      )

      if (index !== -1) {
        setSearchResult(searchResultList[index])
        setSearchResultList([
          ...searchResultList.splice(index, 1).concat(searchResultList),
        ])
        return
      }

      const res = await request({
        url: `${baseUrl}/p2pVideoCall/caller/searchSubscriber`,
        headers: {
          accessToken: userInfo.accessToken,
          appKey,
        },
        data,
      })

      if (!res.data) {
        message.error('搜索结果为空')
        return
      }

      if (res.data.imAccid === userInfo.imAccid) {
        message.error('不能搜索自己')
      } else {
        const list = [res.data, ...searchResultList]

        setSearchResult(res.data)
        setSearchResultList(list)
        storage.set('searchResultList', list)
      }
    } catch (err: unknown) {
      const error = err as commonError

      if (error.msg) {
        message.error(error.msg)
      }
    }
  }

  const handleGroupCall = async () => {
    if (!navigator.onLine) {
      message.error('网络异常，请检查网络')
      return
    }

    if (neGroupCall?.callStatus === 0) {
      const pushContent = form.getFieldValue('pushContent')

      groupCall?.({
        calleeList: selectedUsers.map((item) => item.imAccid),
        pushParam: {
          pushMode: pushContent ? 1 : 0,
          pushContent: pushContent,
        },
      }).then(() => {
        setSelectedUsers([])
      })
    }

    if (neGroupCall?.callStatus === 2) {
      neGroupCall
        ?.groupInvite({
          calleeList: selectedUsers.map((item) => item.imAccid),
        })
        .then(() => {
          setSelectedUsers([])
        })
    }
  }

  const handleSelect = (user: User, isSelect: boolean) => {
    if (!isSelect) {
      if (
        members.filter(
          (member) => member.state !== 3 && member.imAccid !== userInfo.imAccid
        ).length +
          selectedUsers.length >=
        15
      ) {
        message.error('邀请已达上限')
        return
      }

      setSelectedUsers([...selectedUsers, user])
    } else {
      setSelectedUsers(
        selectedUsers.filter((item) => item.imAccid !== user.imAccid)
      )
    }
  }

  const userItem = (item: User) => {
    const isSelected = !!selectedUsers.find(
      (user) => user.imAccid === item.imAccid
    )
    let inCall = false
    let reason = ''
    const member = members.find((member) => member.imAccid === item.imAccid)

    if (member) {
      member.state === 3
        ? (reason = member.reason)
        : (inCall = neGroupCall?.callStatus !== 0)
    }

    return (
      <div key={item.imAccid} style={{ marginBottom: 10 }}>
        <img style={{ width: 30, height: 30 }} src={item.avatar} />
        (手机号：{item.mobile}){reason ? `断开原因：${reason}` : ''}
        <>
          {inCall ? (
            <Button disabled style={{ marginLeft: 10 }}>
              连线中
            </Button>
          ) : (
            <Button
              type={isSelected ? 'default' : 'primary'}
              style={{ marginLeft: 10 }}
              onClick={() => handleSelect(item, isSelected)}
            >
              {isSelected ? '取消' : '添加'}
            </Button>
          )}
        </>
      </div>
    )
  }

  return (
    <>
      <div>
        {userInfo.nickname}（手机号：{userInfo.mobile}）{' '}
        <Tag color="#87d068">已登录</Tag>
        <Button onClick={() => handleLogout()}>退出登录</Button>
      </div>
      <Form form={form} validateTrigger={false} style={{ marginTop: 10 }}>
        <Form.Item name="pushContent">
          <Input
            style={{ width: 200, display: 'block', marginTop: 10 }}
            placeholder="邀请时候推送的内容"
          />
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
      <p>搜索结果</p>
      {searchResult && userItem(searchResult)}
      <p>搜索列表</p>
      {searchResultList.map((item) => userItem(item))}
      <p>待呼叫用户</p>
      <div style={{ width: 300, marginBottom: 20 }}>
        {selectedUsers.map((item) => (
          <img
            style={{
              width: 30,
              height: 30,
              marginRight: 10,
              marginBottom: 10,
              cursor: 'pointer',
            }}
            src={item.avatar}
            key={item.imAccid}
            onClick={() => handleSelect(item, true)}
          />
        ))}
      </div>
      {selectedUsers.length > 0 && (
        <Button
          type="primary"
          style={{ marginLeft: 10 }}
          onClick={() => handleGroupCall()}
        >
          {`发起呼叫(${
            members.filter(
              (member) =>
                member.state !== 3 && member.imAccid !== userInfo.imAccid
            ).length + selectedUsers.length
          }/15)`}
        </Button>
      )}
    </>
  )
}

export const Group: React.FC = () => {
  // 0： 初始化
  // 1： 已登录
  // 2： 未登录
  const autoLogin = true
  const groupCallViewProviderRef = useRef<GroupCallViewProviderRef>(null)
  const [loginState, setLoginState] = useState<number>(autoLogin ? 0 : 2)
  const [nim, setNim] = useState<V2NIM>()
  const [userInfo, setUserInfo] = useState<User>()

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
    if (userInfo) {
      const nim = V2NIM.getInstance({
        appkey: appKey,
        token: userInfo?.imToken,
        account: userInfo?.imAccid,
        debugLevel: 'debug',
        apiVersion: 'v2',
      })

      nim.V2NIMLoginService.login(userInfo.imAccid, userInfo.imToken || '', {
        retryCount: 5,
      })

      if (nim) {
        nim.V2NIMLoginService.on('onDataSync', () => {
          nim?.V2NIMUserService.updateSelfUserProfile({
            name: userInfo?.nickname,
            avatar: userInfo?.avatar,
            mobile: userInfo?.mobile,
          })
          setNim(nim)
        })
        nim.V2NIMNotificationService.on(
          'onReceiveCustomNotifications',
          (msgs) => {
            msgs.forEach((msg) => {
              groupCallViewProviderRef.current?.onMsg?.(msg.content)
            })
          }
        )
      }

      return () => {
        if (nim) {
          nim.V2NIMLoginService.logout()
        }
      }
    }
  }, [userInfo])

  return (
    <Session {...loginProps} memoryMode="sessionStorage">
      {loginState === 0 && null}
      {loginState === 1 && userInfo && nim && (
        <GroupCallViewProvider
          neGroupCallConfig={{
            nim,
            appkey: appKey,
            debug: true,
          }}
          position={{ x: 500, y: 10 }}
          ref={groupCallViewProviderRef}
        >
          <UserView userInfo={userInfo} onLogout={() => setLoginState(2)} />
        </GroupCallViewProvider>
      )}
      {loginState === 2 && <Login />}
    </Session>
  )
}
