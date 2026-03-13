import React, {
  useEffect,
  useMemo,
  useState,
  useCallback,
  useRef,
  forwardRef,
  useContext,
  useImperativeHandle,
} from 'react'
import Draggable from 'react-draggable'
import {
  NEGroupCall,
  NEGroupCallMember,
  NEGroupCallCallFnParams,
  NEGroupCallConfig,
  NEGroupCallReceiveInfo,
  NEGroupCallCallRes,
} from '@xkit-yx/call-kit'
import { Swiper, SwiperSlide } from 'swiper/react'
import { AddOutline } from 'antd-mobile-icons'
import { secondToDate } from '../../utils'
import avatarDefaultMan from '../../assets/avatar-default-man.png'
import videoOpen from '../../assets/video-open.png'
import videoClose from '../../assets/video-close.png'
import microphoneOpen from '../../assets/microphone-open.png'
import microphoneClose from '../../assets/microphone-close.png'
import hangup from '../../assets/hangup.png'
import audioAccept from '../../assets/audio-accept.png'

interface IGroupCallContext {
  neGroupCall?: NEGroupCall
  groupCall?: (
    opt: NEGroupCallCallFnParams
  ) => Promise<NEGroupCallCallRes | undefined>
  groupJoin?: (opt: {
    callId: string
    rtcUid?: number
  }) => Promise<NEGroupCallCallRes | undefined>
}

const GroupCallContext = React.createContext<IGroupCallContext>({})

const useGroupCall: () => IGroupCallContext = () => {
  return useContext(GroupCallContext)
}

const GroupCallProvider = GroupCallContext.Provider

export { GroupCallProvider, useGroupCall }

const Loading = () => {
  return (
    <div className="lds-ellipsis">
      <div />
      <div />
      <div />
      <div />
    </div>
  )
}

interface UserInfo {
  avatar: string
  nick: string
  tel: string
  account: string
  videoEnable?: boolean
  state: number
}

interface InvitedViewProps {
  callerAccid: string
  currentAccid: string
  members: UserInfo[]
  onAccept: () => void
  onReject: () => void
}

const InvitedView: React.FC<InvitedViewProps> = ({
  callerAccid,
  currentAccid,
  members,
  onAccept,
  onReject,
}) => {
  const prefixCls = 'necall-group'
  const callerInfo = members?.find((item) => item.account === callerAccid)
  const otherMembers = members?.filter(
    (item) => ![currentAccid, callerAccid].includes(item.account)
  )

  return (
    <div className={`${prefixCls}-invited-view-container`}>
      <div className={`${prefixCls}-caller-info`}>
        <img
          draggable="false"
          className={`${prefixCls}-caller-avatar`}
          src={callerInfo?.avatar || avatarDefaultMan}
          alt=""
        />
        <div className={`${prefixCls}-caller-nickname`}>
          {callerInfo?.nick || callerInfo?.tel}
        </div>
        <div className={`${prefixCls}-caller-tips`}>邀请您加入多人通话</div>
        {otherMembers && otherMembers.length > 0 && (
          <>
            <div className={`${prefixCls}-member-tips`}>
              还有{otherMembers.length}人参与通话
            </div>
            <div className={`${prefixCls}-member-list`}>
              {otherMembers.map((member) => (
                <img
                  draggable="false"
                  key={member.account}
                  className={`${prefixCls}-member-item`}
                  src={member.avatar || avatarDefaultMan}
                />
              ))}
            </div>
          </>
        )}
      </div>
      <div className={`${prefixCls}-called-btn-group`}>
        <div className={`${prefixCls}-btn`}>
          <img
            draggable="false"
            className={`${prefixCls}-img`}
            src={hangup}
            onClick={() => onReject()}
          />
          <span>拒绝</span>
        </div>
        <div className={`${prefixCls}-btn`}>
          <img
            draggable="false"
            className={`${prefixCls}-img`}
            src={audioAccept}
            onClick={() => onAccept()}
          />
          <span>接听</span>
        </div>
      </div>
    </div>
  )
}

interface InCallViewProps {
  members: UserInfo[] // 包含自己
  neGroupCall: NEGroupCall
  onHangup: () => void
}

const InCallView: React.FC<InCallViewProps> = ({
  members,
  neGroupCall,
  onHangup,
}) => {
  const prefixCls = 'necall-group'
  const [enableLocalAudio, setEnableLocalAudio] = useState(true)
  const [enableLocalVideo, setEnableLocalVideo] = useState(false)
  const [duration, setDuration] = useState(0)
  const domsRef = useRef<{ [key: string]: HTMLElement }>({})

  useEffect(() => {
    const timer = setTimeout(() => {
      setDuration(duration + 1)
    }, 1000)

    return () => {
      clearTimeout(timer)
    }
  }, [duration])

  useEffect(() => {
    members.forEach((member) => {
      const accId = member.account

      neGroupCall.setRtcView(domsRef.current[accId], accId)
    })
  }, [members, neGroupCall])

  useEffect(() => {
    // 延迟加入，避免自动占线挂断
    const timer = setTimeout(() => {
      neGroupCall.joinRtc({ video: false })
    }, 500)

    return () => {
      clearTimeout(timer)
    }
  }, [neGroupCall])

  const membersGroup = useMemo(() => {
    const _members = members.filter((member) => member.state !== 3)
    const result: { members: UserInfo[]; id: number }[] = []

    for (let i = 0, len = _members.length; i < len; i += 4) {
      result.push({
        id: result.length,
        members: _members.slice(i, i + 4),
      })
    }

    return result
  }, [members])

  const handleEnableLocalAudio = () => {
    setEnableLocalAudio(!enableLocalAudio)
    neGroupCall.enableLocalAudio(!enableLocalAudio)
  }

  const handleEnableLocalVideo = () => {
    setEnableLocalVideo(!enableLocalVideo)
    neGroupCall.enableLocalVideo(!enableLocalVideo)
  }

  const handleHangup = () => {
    onHangup()
  }

  return (
    <div className={`${prefixCls}-incall-view-container`}>
      <div className={`${prefixCls}-incall-scroll-view`}>
        <div className={`${prefixCls}-incall-duration`}>
          {secondToDate(duration)}
        </div>
        <Swiper slidesPerView={1}>
          {membersGroup.map((item) => {
            return (
              <SwiperSlide
                className={`${prefixCls}-incall-rtc-page`}
                key={item.id}
              >
                {item.members.map((member) => (
                  <div
                    key={member.account}
                    className={`${prefixCls}-incall-rtc-view`}
                    ref={(el) => el && (domsRef.current[member.account] = el)}
                  >
                    <div className={`${prefixCls}-incall-rtc-user`}>
                      <img
                        className={`${prefixCls}-incall-rtc-user-avatar`}
                        src={member.avatar || avatarDefaultMan}
                      />
                      {member.state !== 2 && <Loading />}
                    </div>
                    <div className={`${prefixCls}-incall-rtc-user-name`}>
                      {member.nick || member.tel}
                    </div>
                  </div>
                ))}
              </SwiperSlide>
            )
          })}
        </Swiper>
      </div>
      <div className={`${prefixCls}-in-call-btn-group`}>
        <img
          draggable="false"
          className={`${prefixCls}-microphone-btn`}
          src={enableLocalAudio ? microphoneOpen : microphoneClose}
          onClick={() => handleEnableLocalAudio()}
        />
        <img
          draggable="false"
          className={`${prefixCls}-video-btn`}
          src={enableLocalVideo ? videoOpen : videoClose}
          onClick={() => handleEnableLocalVideo()}
        />
        <img
          draggable="false"
          className={`${prefixCls}-hangup-btn`}
          onClick={() => handleHangup()}
          src={hangup}
        />
      </div>
    </div>
  )
}

interface GroupCallViewProviderProps {
  neGroupCallConfig: NEGroupCallConfig
  position?: { x: number; y: number }
  onInviteClick?: (event: React.MouseEvent<SVGSVGElement, MouseEvent>) => void
}

export interface GroupCallViewProviderRef {
  onMsg: (msg: string) => void
}

const GroupCallViewProvider = forwardRef<
  GroupCallViewProviderRef,
  React.PropsWithChildren<GroupCallViewProviderProps>
>((props, ref) => {
  const prefixCls = 'necall-group'
  const {
    neGroupCallConfig,
    position = { x: 100, y: 100 },
    onInviteClick,
  } = props
  const draggableNodeRef = useRef<HTMLDivElement>(null)
  const [neGroupCall, setNeGroupCall] = useState<NEGroupCall>()
  const [callStatus, setCallStatus] = useState<number>(0)
  const [members, setMembers] = useState<UserInfo[]>([])
  const [callerAccid, setCallerAccid] = useState<string>()

  useEffect(() => {
    if (neGroupCallConfig) {
      const neGroupCall = NEGroupCall.getInstance()

      neGroupCall.setup(neGroupCallConfig)
      setNeGroupCall(neGroupCall)
      setCallStatus(0)
      return () => {
        neGroupCall?.destroy()
      }
    }
    // 这里需要在第一次挂载时才执行
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const getUserByNimAccount: (account: string) => Promise<UserInfo> =
    useCallback(
      (account) => {
        return neGroupCallConfig.nim.V2NIMUserService.getUserList([
          account,
        ]).then((res) => {
          const user = res[0]

          return {
            avatar: user?.avatar,
            nick: user?.name,
            tel: user?.mobile,
            account: user?.accountId,
          }
        })
      },
      [neGroupCallConfig]
    )

  const updateMembers = useCallback(
    async (value: NEGroupCallMember[]) => {
      const _members: UserInfo[] = []

      for (const member of value) {
        const _member = members.find((item) => item.account === member.imAccid)

        if (_member) {
          _member.state = member.state
          _members.push(_member)
        } else {
          const res = await getUserByNimAccount(member.imAccid)

          res.state = member.state
          _members.push(res)
        }
      }

      setMembers(_members)
    },
    [members, getUserByNimAccount]
  )

  useEffect(() => {
    function handleReceiveInvited(value: NEGroupCallReceiveInfo) {
      setCallerAccid(value.callerAccid)
      updateMembers(value.members).then(() => {
        setCallStatus(1)
      })
    }

    function handleMembersChange(value: NEGroupCallMember[]) {
      // 通话中，更新成员列表
      callStatus === 2 && updateMembers(value)
    }

    function handleCallEnd() {
      setCallStatus(0)
    }

    neGroupCall?.on('onReceiveInvited', handleReceiveInvited)
    neGroupCall?.on('onMembersChange', handleMembersChange)
    neGroupCall?.on('onCallEnd', handleCallEnd)
    return () => {
      neGroupCall?.off('onReceiveInvited', handleReceiveInvited)
      neGroupCall?.off('onMembersChange', handleMembersChange)
      neGroupCall?.off('onCallEnd', handleCallEnd)
    }
  }, [
    neGroupCall,
    getUserByNimAccount,
    neGroupCallConfig,
    updateMembers,
    callStatus,
  ])

  const handleCall: (
    opt: NEGroupCallCallFnParams
  ) => Promise<NEGroupCallCallRes | undefined> = useCallback(
    async (opt) => {
      if (neGroupCall) {
        const res = await neGroupCall.groupCall(opt)

        await updateMembers(res.members)
        setCallStatus(2)
        return res
      }

      return
    },
    [neGroupCall, updateMembers]
  )

  const handleJoin: (opt: {
    callId: string
    rtcUid?: number
  }) => Promise<NEGroupCallCallRes | undefined> = useCallback(
    async (opt) => {
      if (neGroupCall) {
        const res = await neGroupCall.groupJoin(opt)

        setCallStatus(2)
        return res
      }

      return
    },
    [neGroupCall]
  )

  const handleAccept = () => {
    if (neGroupCall) {
      neGroupCall
        .groupAccept()
        .then((res) => {
          return updateMembers(res.members)
        })
        .then(() => {
          setCallStatus(2)
        })
    }
  }

  const handleHangup = () => {
    if (neGroupCall) {
      neGroupCall.groupHangup()
      setCallStatus(0)
    }
  }

  useImperativeHandle(
    ref,
    () => ({
      onMsg: (msg) => {
        return neGroupCall?.receiveNimMsg(msg)
      },
      groupCall: handleCall,
      groupJoin: handleJoin,
      neGroupCall: neGroupCall,
    }),
    [neGroupCall, handleCall, handleJoin]
  )

  return (
    <GroupCallProvider
      value={{
        groupCall: handleCall,
        groupJoin: handleJoin,
        neGroupCall: neGroupCall,
      }}
    >
      {callStatus !== 0 && neGroupCall && (
        <Draggable
          nodeRef={draggableNodeRef}
          handle={`.${prefixCls}-drag-handle`}
          cancel={`.${prefixCls}-called-btn-group .${prefixCls}-img, .${prefixCls}-in-call-btn-group`}
        >
          <div
            style={{ top: position.y, left: position.x }}
            className={`${prefixCls}-view`}
            ref={draggableNodeRef}
          >
            <div className={`${prefixCls}-drag-handle`} />
            {onInviteClick && callStatus === 2 && (
              <AddOutline
                className={`${prefixCls}-invite-btn`}
                onClick={onInviteClick}
              />
            )}
            {callStatus === 1 && callerAccid && (
              <InvitedView
                members={members}
                currentAccid={neGroupCallConfig.nim.account}
                callerAccid={callerAccid}
                onAccept={handleAccept}
                onReject={handleHangup}
              />
            )}
            {callStatus === 2 && (
              <InCallView
                neGroupCall={neGroupCall}
                members={members}
                onHangup={handleHangup}
              />
            )}
          </div>
        </Draggable>
      )}
      {props.children}
    </GroupCallProvider>
  )
})

export default GroupCallViewProvider
