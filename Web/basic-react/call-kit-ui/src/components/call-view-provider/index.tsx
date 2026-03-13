import React, {
  useEffect,
  useState,
  useCallback,
  useRef,
  useContext,
  useImperativeHandle,
  forwardRef,
} from 'react'
import Draggable from 'react-draggable'
import { Dialog, NoticeBar, Toast } from 'antd-mobile'
import {
  NECall,
  NECallParam,
  NECallInfo,
  SignalControllerCallType,
  NESetupConfig,
} from '@xkit-yx/call-kit'
import { EventTracking } from '@xkit-yx/utils'
import pkg from '../../../package.json'

import { secondToDate } from '../../utils'
import avatarDefaultMan from '../../assets/avatar-default-man.png'
import videoOpen from '../../assets/video-open.png'
import videoClose from '../../assets/video-close.png'
import microphoneOpen from '../../assets/microphone-open.png'
import microphoneClose from '../../assets/microphone-close.png'
import hangup from '../../assets/hangup.png'
import videoAccept from '../../assets/video-accept.png'
import audioAccept from '../../assets/audio-accept.png'
import switchVideo from '../../assets/switch-video.png'
import switchAudio from '../../assets/switch-audio.png'

interface ICallContext {
  call?: (opt: NECallParam) => Promise<NECallInfo | undefined>
  neCall?: NECall
}

const CallContext = React.createContext<ICallContext>({})

const useCall = (): ICallContext => {
  return useContext(CallContext)
}

const CallProvider = CallContext.Provider

export { CallProvider, useCall }

type CallType = SignalControllerCallType // 1 音频 2 视频

interface CommonError {
  code: number | string
  message: string
}
interface UserInfo {
  avatar: string
  nick: string
  tel: string
  account: string
}

interface InviteViewProps {
  onHangup: () => void
  calleeInfo?: UserInfo
  callType: CallType
}

const InviteView: React.FC<InviteViewProps> = ({
  onHangup,
  calleeInfo,
  callType,
}) => {
  const prefixCls = 'necall'
  const { neCall } = useCall()
  const previewRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (previewRef.current && neCall && callType === '2') {
      neCall.initAndPlayLocalSteam(previewRef.current)
    }
  }, [neCall, callType])

  return (
    <>
      <div className={`${prefixCls}-blur-bg-mark`} ref={previewRef}>
        <img
          draggable="false"
          className={`${prefixCls}-blur-bg-img`}
          src={calleeInfo?.avatar || avatarDefaultMan}
          alt=""
        />
      </div>
      <div className={`${prefixCls}-callee-info`}>
        <div>
          <div className={`${prefixCls}-callee-nickname`}>
            正在呼叫 {calleeInfo?.nick || calleeInfo?.tel}
          </div>
          <div className={`${prefixCls}-callee-tips`}>等待对方接听...</div>
        </div>
        <img
          className={`${prefixCls}-callee-avatar`}
          src={calleeInfo?.avatar || avatarDefaultMan}
          alt=""
        />
      </div>
      <div className={`${prefixCls}-calling-btn-group`}>
        <div className={`${prefixCls}-btn`} onClick={() => onHangup()}>
          <img draggable="false" className={`${prefixCls}-img`} src={hangup} />
          <span>取消</span>
        </div>
      </div>
    </>
  )
}

interface BeInvitedProps {
  onAccept: () => void
  onHangup: () => void
  callerInfo?: UserInfo
  callType: CallType
}
const BeInvitedView: React.FC<BeInvitedProps> = ({
  onAccept,
  onHangup,
  callerInfo,
  callType,
}) => {
  const prefixCls = 'necall'

  return (
    <>
      <div className={`${prefixCls}-blur-bg-mark`}>
        <img
          draggable="false"
          className={`${prefixCls}-blur-bg-img`}
          src={callerInfo?.avatar || avatarDefaultMan}
          alt=""
        />
      </div>
      <div className={`${prefixCls}-caller-info`}>
        <img
          className={`${prefixCls}-caller-avatar`}
          src={callerInfo?.avatar || avatarDefaultMan}
          alt=""
        />
        <div className={`${prefixCls}-caller-nickname`}>
          {callerInfo?.nick || callerInfo?.tel}
        </div>
        <div className={`${prefixCls}-caller-tips`}>
          {callType === '1' ? '邀请你进行语音通话...' : '邀请你进行视频通话...'}
        </div>
      </div>
      <div className={`${prefixCls}-called-btn-group`}>
        <div className={`${prefixCls}-btn`}>
          <img
            draggable="false"
            className={`${prefixCls}-img`}
            src={hangup}
            onClick={() => onHangup()}
          />
          <span>拒绝</span>
        </div>
        <div className={`${prefixCls}-btn`}>
          <img
            draggable="false"
            className={`${prefixCls}-img`}
            src={callType === '1' ? audioAccept : videoAccept}
            onClick={() => onAccept()}
          />
          <span>接听</span>
        </div>
      </div>
    </>
  )
}

interface SwitchCallTypeBtn {
  switchToVideo?: boolean
  switchToAudio?: boolean
}
interface InCallViewProps {
  onHangup: () => void
  callType: CallType
  remoteUserInfo?: UserInfo
  switchCallTypeBtn?: SwitchCallTypeBtn
}
const InCallView: React.FC<InCallViewProps> = (props) => {
  const { onHangup, remoteUserInfo, switchCallTypeBtn } = props
  const prefixCls = 'necall'
  const avatar = remoteUserInfo?.avatar || avatarDefaultMan
  const { neCall } = useCall()
  const [callType, setCallType] = useState<CallType>(props.callType)
  const [enableLocalAudio, setEnableLocalAudio] = useState<boolean>(true)
  const [enableLocalVideo, setEnableLocalVideo] = useState<boolean>(true)
  const [noticeText, setNoticeText] = useState<string>('')
  const [duration, setDuration] = useState<number>(0)
  const domRef = useRef<HTMLDivElement>(null)
  const dialogVisibilityRef = useRef<boolean>(false)

  useEffect(() => {
    const timer = setTimeout(() => {
      setDuration(duration + 1)
    }, 1000)

    return () => {
      clearTimeout(timer)
    }
  }, [duration])

  useEffect(() => {
    const handleCallTypeChange = (value) => {
      const callType = value.callType

      if (value.state === 1) {
        if (dialogVisibilityRef.current) return
        dialogVisibilityRef.current = true
        const content =
          callType === '1'
            ? '对方请求将视频转为音频，将直接关闭您的摄像头'
            : '对方请求将转音频为视频，需要打开您的摄像头'

        Dialog.confirm({
          title: '权限请求',
          content,
          cancelText: '拒绝',
          confirmText: '同意',
          onConfirm: () => {
            dialogVisibilityRef.current = false
            neCall?.switchCallType({ callType, state: 2 })
          },
          onCancel: () => {
            dialogVisibilityRef.current = false
            neCall?.switchCallType({ callType, state: 3 })
          },
          getContainer: domRef.current,
        })
      }

      if (value.state === 2) {
        setNoticeText('')
        setCallType(value.callType)
        setEnableLocalAudio(true)
        setEnableLocalVideo(true)
        if (neCall?.rtcController.localStream) {
          const hasVideo = neCall.rtcController.localStream.hasVideo()
          const enableVideo = callType === '2'

          if (enableVideo !== hasVideo) {
            if (enableVideo) {
              neCall.enableLocalVideo(enableVideo).then(() => {
                neCall.muteLocalVideo(!enableVideo)
              })
            } else {
              neCall.muteLocalVideo(!enableVideo).then(() => {
                neCall.enableLocalVideo(enableVideo)
              })
            }
          }

          neCall.muteLocalAudio(false)
        }
      }

      if (value.state === 3) {
        setNoticeText('')
        Toast.show({
          content: '对方拒绝了您的请求',
          duration: 3000,
          getContainer: domRef.current,
        })
      }
    }

    neCall?.on('onCallTypeChange', handleCallTypeChange)
    return () => {
      neCall?.off('onCallTypeChange', handleCallTypeChange)
    }
  }, [neCall])

  const switchCallType = useCallback(
    async (state: number) => {
      if (neCall) {
        const data = callType === '1' ? '2' : '1'

        setNoticeText('正在等待对方响应...')
        try {
          await neCall.switchCallType({ callType: data, state })
        } catch (err) {
          setNoticeText('')
          throw err
        }
      }
    },
    [neCall, callType]
  )

  const handleEnableLocalVideo = useCallback(() => {
    if (neCall) {
      const enableVideo = !enableLocalVideo

      if (enableVideo) {
        neCall.enableLocalVideo(enableVideo).then(() => {
          neCall.muteLocalVideo(!enableVideo)
        })
      } else {
        neCall.muteLocalVideo(!enableVideo).then(() => {
          neCall.enableLocalVideo(enableVideo)
        })
      }

      setEnableLocalVideo(!enableLocalVideo)
    }
  }, [neCall, enableLocalVideo])

  const handleEnableLocalAudio = useCallback(() => {
    if (neCall) {
      neCall.muteLocalAudio(enableLocalAudio)
      setEnableLocalAudio(!enableLocalAudio)
    }
  }, [neCall, enableLocalAudio])

  return (
    <div ref={domRef}>
      {noticeText && (
        <NoticeBar
          className={`${prefixCls}-notice`}
          content={noticeText}
          color="alert"
          onClose={() => setNoticeText('')}
          icon={null}
          closeable
        />
      )}
      {callType === '1' ? (
        <>
          <div className={`${prefixCls}-blur-bg-mark`}>
            <img
              draggable="false"
              className={`${prefixCls}-blur-bg-img`}
              src={avatar}
              alt=""
            />
          </div>
          <div className={`${prefixCls}-in-call-audio`}>
            <img
              className={`${prefixCls}-in-call-avatar`}
              src={avatar}
              alt=""
            />
            <div className={`${prefixCls}-in-call-title`}>通话中</div>
            <div className={`${prefixCls}-in-call-tips`}>
              {secondToDate(duration)}
            </div>
          </div>
        </>
      ) : (
        <div className={`${prefixCls}-in-call-duration`}>
          {secondToDate(duration)}
        </div>
      )}
      <div className={`${prefixCls}-in-call-btn-group`}>
        <img
          draggable="false"
          className={`${prefixCls}-microphone-btn`}
          src={enableLocalAudio ? microphoneOpen : microphoneClose}
          onClick={() => handleEnableLocalAudio()}
        />
        {callType === '2' && (
          <img
            draggable="false"
            className={`${prefixCls}-video-btn`}
            src={enableLocalVideo ? videoOpen : videoClose}
            onClick={() => handleEnableLocalVideo()}
          />
        )}
        {callType === '1' && (switchCallTypeBtn?.switchToVideo ?? false) && (
          <img
            draggable="false"
            className={`${prefixCls}-switch-btn`}
            src={switchVideo}
            onClick={() => switchCallType(1)}
          />
        )}
        {callType === '2' && (switchCallTypeBtn?.switchToAudio ?? true) && (
          <img
            draggable="false"
            className={`${prefixCls}-switch-btn`}
            src={switchAudio}
            onClick={() => switchCallType(1)}
          />
        )}

        <img
          draggable="false"
          className={`${prefixCls}-hangup-btn`}
          onClick={() => onHangup()}
          src={hangup}
        />
      </div>
    </div>
  )
}

interface CallViewProps {
  neCallConfig: NESetupConfig
  uiConfig?: {
    switchCallTypeBtn?: SwitchCallTypeBtn
  }
  position?: { x: number; y: number }
}

export interface CallViewProviderRef {
  call: (opt: NECallParam) => Promise<NECallInfo | undefined>
  neCall?: NECall
}

const CallViewProvider = forwardRef<
  CallViewProviderRef,
  React.PropsWithChildren<CallViewProps>
>((props, ref) => {
  const prefixCls = 'necall'
  const { neCallConfig, position = { x: 100, y: 100 }, uiConfig } = props
  const draggableNodeRef = useRef<HTMLDivElement>(null)
  const smallViewRef = useRef<HTMLDivElement>(null)
  const largeViewRef = useRef<HTMLDivElement>(null)
  const localViewRef = useRef<HTMLDivElement>()
  const [neCall, setNeCall] = useState<NECall>()
  const [callStatus, setCallStatus] = useState<number>(0) // 0:闲置 1:正在呼叫 2:正在被呼叫 3: 连接建立中 4:通话中
  const [callType, setCallType] = useState<CallType>('1') // 1 音频 2 视频
  const [remoteUserInfo, setRemoteUserInfo] = useState<UserInfo>()

  useEffect(() => {
    if (neCallConfig) {
      const neCall = NECall.getInstance()

      // @ts-ignore
      window.__necall__ = neCall

      neCall.setup(neCallConfig)
      setNeCall(neCall)
      setCallStatus(0)
      // 接入统计
      const eventTracking = new EventTracking({
        appKey: neCallConfig.appkey,
        version: pkg.version,
        component: 'CallKitReactUI',
      })

      eventTracking.track('init', '')
      return () => {
        neCall.destroy()
      }
    }
    // 这里需要在第一次挂载时才执行
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    const remoteAccount = remoteUserInfo?.account

    if (smallViewRef.current && largeViewRef.current && remoteAccount) {
      neCall?.setLocalView(smallViewRef.current)
      neCall?.setRemoteView(largeViewRef.current)
      localViewRef.current = smallViewRef.current
      const handleCallTypeChange = (value) => {
        if (value.state === 2 && smallViewRef.current && largeViewRef.current) {
          neCall?.setLocalView(smallViewRef.current)
          neCall?.setRemoteView(largeViewRef.current)
        }
      }

      neCall?.on('onCallTypeChange', handleCallTypeChange)
      return () => {
        neCall?.off('onCallTypeChange', handleCallTypeChange)
      }
    }
  }, [neCall, remoteUserInfo])

  useEffect(() => {
    if (neCall) {
      const handleReceiveInvited = (value) => {
        setCallType(value.callType)
        setCallStatus(2)
        neCallConfig.nim.V2NIMUserService.getUserList([value.callerAccId])
          .then((data) => {
            const user = data[0]

            if (user) {
              setRemoteUserInfo({
                account: user.accountId,
                avatar: user.avatar || '',
                nick: user.name,
                tel: user.mobile || '',
              })
            }
          })
          .catch((err: unknown) => {
            const error = err as CommonError

            console.error(
              '获取对端用户信息失败',
              value.callerAccId,
              error.toString()
            )
          })
      }

      const handleCallConnected = () => {
        setCallStatus(3)
      }

      const handleCallEnd = () => {
        setCallStatus(0)
      }

      neCall.on('onReceiveInvited', handleReceiveInvited)
      neCall.on('onCallConnected', handleCallConnected)
      neCall.on('onCallEnd', handleCallEnd)
      return () => {
        neCall.off('onReceiveInvited', handleReceiveInvited)
        neCall.off('onCallConnected', handleCallConnected)
        neCall.off('onCallEnd', handleCallEnd)
      }
    }
  }, [neCall, neCallConfig])

  const handleCall: (opt: NECallParam) => Promise<NECallInfo | undefined> =
    useCallback(
      async (opt) => {
        if (neCall) {
          const res = await neCall.call(opt)

          setCallType(opt.callType)
          setCallStatus(1)
          neCallConfig.nim.V2NIMUserService.getUserList([opt.accId])
            .then((data) => {
              const user = data[0]

              if (user) {
                setRemoteUserInfo({
                  account: user.accountId,
                  avatar: user.avatar || '',
                  nick: user.name,
                  tel: user.mobile || '',
                })
              }
            })
            .catch((err: unknown) => {
              const error = err as CommonError

              console.error('获取对端用户信息失败', opt.accId, error.toString())
            })
          return res
        }

        return
      },
      [neCall, neCallConfig]
    )

  const handleAccept = useCallback(async () => {
    await neCall?.accept()
  }, [neCall])

  const handleHangup = useCallback(() => {
    setCallStatus(0)
    setRemoteUserInfo(undefined)
    neCall?.hangup()
  }, [neCall])

  const switchPlayView = useCallback(() => {
    const remoteAccount = remoteUserInfo?.account

    if (
      smallViewRef.current &&
      largeViewRef.current &&
      remoteAccount &&
      neCall
    ) {
      if (localViewRef.current === smallViewRef.current) {
        neCall.setLocalView(largeViewRef.current)
        neCall.setRemoteView(smallViewRef.current)
        localViewRef.current = largeViewRef.current
      } else {
        neCall.setLocalView(smallViewRef.current)
        neCall.setRemoteView(largeViewRef.current)
        localViewRef.current = smallViewRef.current
      }

      const rtcUid = neCall.getUidByAccId(remoteAccount)
      const remoteStream = neCall.rtcController.remoteStreams.find(
        (item) => item.getId() === rtcUid
      )

      neCall.rtcController.playLocalStream()
      remoteStream && neCall.rtcController.playRemoteStream(remoteStream)
    }
  }, [neCall, remoteUserInfo])

  useImperativeHandle(
    ref,
    () => ({
      call: handleCall,
      neCall: neCall,
    }),
    [neCall, handleCall]
  )

  return (
    <CallProvider value={{ call: handleCall, neCall: neCall }}>
      {callStatus !== 0 && (
        <Draggable
          nodeRef={draggableNodeRef}
          cancel={`.${prefixCls}-calling-btn-group .${prefixCls}-img, .${prefixCls}-called-btn-group .${prefixCls}-img, .${prefixCls}-in-call-btn-group, .${prefixCls}-small-view`}
        >
          <div
            style={{ top: position.y, left: position.x }}
            className={`${prefixCls}-view`}
            ref={draggableNodeRef}
          >
            <div className={`${prefixCls}-large-view`} ref={largeViewRef} />
            <div
              className={`${prefixCls}-small-view`}
              ref={smallViewRef}
              onClick={() => switchPlayView()}
            />
            {callStatus === 1 && (
              <InviteView
                calleeInfo={remoteUserInfo}
                callType={callType}
                onHangup={handleHangup}
              />
            )}
            {callStatus === 2 && (
              <BeInvitedView
                callerInfo={remoteUserInfo}
                callType={callType}
                onAccept={handleAccept}
                onHangup={handleHangup}
              />
            )}
            {callStatus === 3 && (
              <InCallView
                remoteUserInfo={remoteUserInfo}
                switchCallTypeBtn={uiConfig?.switchCallTypeBtn}
                callType={callType}
                onHangup={handleHangup}
              />
            )}
          </div>
        </Draggable>
      )}
      {props.children}
    </CallProvider>
  )
})

export default CallViewProvider
