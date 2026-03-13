export interface commonError {
  code: number
  msg: string
}
export type NIMMsgScene = 'p2p' | 'team' | 'superTeam'
export type NIMMsgType =
  | 'video'
  | 'audio'
  | 'image'
  | 'text'
  | 'geo'
  | 'notification'
  | 'file'
  | 'tip'
  | 'robot'
  | 'g2'
  | 'custom'
export interface NIMMessage {
  account?: string
  /**
   * 消息场景：
   *
   * <ul><li>p2p：单聊场景</li><li>team：群聊场景</li><li>superteam：超大群场景</li></ul>
   */
  scene: NIMMsgScene
  /**
   * 消息发送方, 帐号
   */
  from: string
  /**
   * 消息发送方的昵称
   */
  fromNick?: string
  /**
   * 发送方的设备类型
   */
  fromClientType?: string
  /**
   * 发送端设备id
   */
  fromDeviceId?: string
  /**
   * 消息接收方, 帐号或群id
   */
  to: string
  /**
   * 时间戳
   */
  time: number
  /**
   * 发送方信息更新时间
   */
  userUpdateTime: number
  /**
   * 消息类型
   */
  type: NIMMsgType
  /**
   * 消息所属的会话的ID
   */
  sessionId: string
  /**
   * 聊天对象, 账号或者群id
   */
  target: string
  /**
   * 消息的流向
   *
   * 'in' 代表这是收到的消息.
   * 'out' 代表这是发出的消息
   */
  flow: string
  /**
   * 消息发送状态
   *
   * 'sending' 发送中
   * 'success' 发送成功
   * 'fail' 发送失败
   */
  status: string
  /**
   * 端测生成的消息id, 可作为消息唯一主键使用。
   */
  idClient: string
  /**
   * 服务器用于区分消息用的ID, 用于获取历史消息和获取包含关键词的历史消息。
   *
   * 注：此字段可能没有, 比如说消息被反垃圾过滤了。
   */
  idServer?: string
  /**
   * 文本消息的文本内容. 当 type 为 text 时存在
   */
  text?: string

  tip?: string
  /**
   * 自定义消息的消息内容, 开发者可以自行扩展, 建议封装成 JSON 序列化后的字符串. 当 type 为 custom 时存在
   */
  content?: string

  /**
   * 该消息在接收方是否应该被静音
   */
  isMuted?: boolean
  /**
   * 是否是重发的消息，默认是 false
   */
  resend?: boolean
  /**
   * 扩展字段
   *
   * 注：推荐传入 JSON 序列化的字符串
   */
  custom?: string
  /**
   * 自定义推送文案
   */
  pushContent?: string
  /**
   * 自定义的推送属性。更多说明及相关示例请参见<a href="https://doc.yunxin.163.com/messaging/docs/DQyNjc5NjE?platform=server" target="_blank">推送payload配置</a>
   *
   * 注：必须传入 JSON 序列化的字符串
   */
  pushPayload?: string
  /**
   * 特殊推送选项, 只在群会话中使用
   */
  apns?: {
    /**
     * 需要特殊推送的账号列表, 此字段不存在的话表示推送给当前会话内的所有用户
     */
    accounts?: string[]
    /**
     * 需要特殊推送的文案
     */
    content?: string
    /**
     * 是否强制推送, 默认 false
     *
     * true 表示即使推送列表中的用户屏蔽了当前会话（如静音）, 仍能够推送当前这条内容给相应用户
     */
    forcePush?: boolean
  }
  /**
   * 本地数据库自定义扩展字段，开启 db 时有效。
   */
  localCustom?: string
  /**
   * 发送方 'from' 是否在接收方 'to' 的黑名单列表中
   */
  isInBlackList?: boolean
  /**
   * 是否存储云端历史，默认 true
   */
  isHistoryable?: boolean
  /**
   * 是否支持漫游，默认 true
   */
  isRoamingable?: boolean
  /**
   * 是否支持发送者多端同步，默认 true
   */
  isSyncable?: boolean
  /**
   * 是否支持抄送，默认 true
   */
  cc?: boolean
  /**
   * 是否需要推送，默认 true
   */
  isPushable?: boolean
  /**
   * 是否要存离线，默认 true
   */
  isOfflinable?: boolean
  /**
   * 是否计入消息未读数，默认 true
   */
  isUnreadable?: boolean
  /**
   * 是否为应答消息（用于机器人等类似场景等应答消息内容）
   */
  isReplyMsg?: boolean
  /**
   * 群已读消息快照大小（即消息发送时的群人数-1）
   */
  tempTeamMemberCount?: number
  /**
   * 是否需要推送昵称
   */
  needPushNick?: boolean
  /**
   * 是否需要刷新服务器会话列表，默认是true
   */
  needUpdateSession?: boolean
  /**
   * 是否是本地数据库消息, 默认 false
   */
  isLocal?: boolean
  /**
   * 被回复消息的发送者账号
   */
  replyMsgFromAccount?: string
  /**
   * 被回复消息的接受者账号
   */
  replyMsgToAccount?: string
  /**
   * 被回复消息的时间
   */
  replyMsgTime?: number
  /**
   * 被回复消息的 idServer
   */
  replyMsgIdServer?: string
  /**
   * 被回复消息的 idClient
   */
  replyMsgIdClient?: string
  /**
   * thread 消息的发送者账号
   */
  threadMsgFromAccount?: string
  /**
   * thread消息的接受者账号
   */
  threadMsgToAccount?: string
  /**
   * thread消息的时间
   */
  threadMsgTime?: number
  /**
   * thread消息的idServer
   */
  threadMsgIdServer?: string
  /**
   * thread消息的idClient
   */
  threadMsgIdClient?: string
  /**
   * 该消息是否已被撤回或单向删除，获取 thread 消息列表时会用到
   */
  delete?: boolean
  /**
   * <a href="https://doc.yunxin.163.com/messaging/docs/jI3ODc2ODE?platform=server" target="_blank">第三方回调</a>的扩展字段
   */
  callbackExt?: string
  /**
   * 开发者自定义的消息子类型，格式为大于0的整数
   */
  subType?: number
  /**
   * 指定当前消息需要抄送到或者回调到的环境的名称。开通消息抄送或第三方回调后，该环境名称可在云信控制台中配置（如下图），最大 32 个字符。
   *
   *
   * @note
   *
   * <br>
   *
   * <ul><li>开通与配置消息抄送功能的详情，请参见<a href="https://doc.yunxin.163.com/messaging/docs/jY5MDk1NTQ?platform=server" target="_blank">开通消息抄送</a>。</li>
   *
   * <li>第三方回调相关详情，请参见<a href="https://doc.yunxin.163.com/messaging/docs/jI3ODc2ODE?platform=server" target="_blank">第三方回调概述</a>。</li></ul>
   *
   * <img style="max-width:100%;" src="https://yx-web-nosdn.netease.im/common/67dfaa431a321abfb77e5f238da47b62/自定义抄送环境.png" />
   */
  env?: string
  /**
   * 易盾反垃圾结果。
   *
   * 注：若开启了易盾反垃圾，并且针对文本或图片如果被反垃圾策略匹配中，端测会透传此反垃圾结果字段。
   */
  yidunAntiSpamRes?: string
}
