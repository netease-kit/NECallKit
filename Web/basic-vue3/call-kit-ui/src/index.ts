import './components/call-view-provider/style/index.less'
import './components/group-call-view-provider/style/index.less'
import 'swiper/swiper.less'

export { default as CallViewProvider } from './components/call-view-provider/index.vue'
export { default as GroupCallViewProvider } from './components/group-call-view-provider/index.vue'

export {
  call,
  getCallInstance,
  getGlobalCallRegistry,
  getGroupCallInstance,
  groupCall,
  groupJoin,
  useCall,
  useGroupCall,
} from './runtime/singleton'

export type {
  CallType,
  CallViewStatus,
  CallViewProviderProps,
  CallViewProviderRef,
  CommonError,
  GlobalCallError,
  GlobalCallErrorCode,
  GlobalCallRegistry,
  GroupCallViewStatus,
  GroupCallViewProviderProps,
  GroupCallViewProviderRef,
  NIMLike,
  NIMMessage,
  Position,
  SwitchCallTypeBtn,
  UseCallResult,
  UseGroupCallResult,
  UserInfo,
} from './interface'
