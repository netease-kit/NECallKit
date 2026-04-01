import type {
  NECall,
  NECallInfo,
  NECallParam,
  NEGroupCall,
  NEGroupCallCallFnParams,
  NEGroupCallCallRes,
} from '@xkit-yx/call-kit'
import type {
  GlobalCallError,
  GlobalCallErrorCode,
  GlobalCallRegistry,
  UseCallResult,
  UseGroupCallResult,
} from '../interface'

const registry: GlobalCallRegistry = {
  callMounted: false,
  callReady: false,
  groupMounted: false,
  groupReady: false,
}

function createGlobalCallError(
  code: GlobalCallErrorCode,
  message: string
): GlobalCallError {
  const error = new Error(message) as GlobalCallError

  error.code = code
  return error
}

export function setCallProviderMounted(mounted: boolean): void {
  registry.callMounted = mounted

  if (!mounted) {
    registry.callReady = false
    registry.call = undefined
    registry.neCall = undefined
  }
}

export function registerCallProvider(
  handler: (opt: NECallParam) => Promise<NECallInfo | undefined>,
  neCall?: NECall
): void {
  registry.call = handler
  registry.neCall = neCall
  registry.callReady = true
}

export function unregisterCallProvider(): void {
  registry.callReady = false
  registry.call = undefined
  registry.neCall = undefined
}

export function setGroupProviderMounted(mounted: boolean): void {
  registry.groupMounted = mounted

  if (!mounted) {
    registry.groupReady = false
    registry.groupCall = undefined
    registry.groupJoin = undefined
    registry.neGroupCall = undefined
  }
}

export function registerGroupProvider(
  handlers: {
    groupCall: (
      opt: NEGroupCallCallFnParams
    ) => Promise<NEGroupCallCallRes | undefined>
    groupJoin: (opt: {
      callId: string
      rtcUid?: number
    }) => Promise<NEGroupCallCallRes | undefined>
  },
  neGroupCall?: NEGroupCall
): void {
  registry.groupCall = handlers.groupCall
  registry.groupJoin = handlers.groupJoin
  registry.neGroupCall = neGroupCall
  registry.groupReady = true
}

export function unregisterGroupProvider(): void {
  registry.groupReady = false
  registry.groupCall = undefined
  registry.groupJoin = undefined
  registry.neGroupCall = undefined
}

export function getGlobalCallRegistry(): GlobalCallRegistry {
  return registry
}

export function getCallInstance(): NECall | undefined {
  return registry.neCall
}

export function getGroupCallInstance(): NEGroupCall | undefined {
  return registry.neGroupCall
}

export function call(
  opt: NECallParam
): Promise<NECallInfo | undefined> {
  if (!registry.callReady || !registry.call) {
    return Promise.reject(
      createGlobalCallError(
        'CALL_PROVIDER_NOT_READY',
        'CallViewProvider is not ready. Mount the root-level singleton and complete neCallConfig setup before calling call().'
      )
    )
  }

  return registry.call(opt)
}

export function groupCall(
  opt: NEGroupCallCallFnParams
): Promise<NEGroupCallCallRes | undefined> {
  if (!registry.groupReady || !registry.groupCall) {
    return Promise.reject(
      createGlobalCallError(
        'GROUP_PROVIDER_NOT_READY',
        'GroupCallViewProvider is not ready. Mount the root-level singleton and complete neGroupCallConfig setup before calling groupCall().'
      )
    )
  }

  return registry.groupCall(opt)
}

export function groupJoin(opt: {
  callId: string
  rtcUid?: number
}): Promise<NEGroupCallCallRes | undefined> {
  if (!registry.groupReady || !registry.groupJoin) {
    return Promise.reject(
      createGlobalCallError(
        'GROUP_JOIN_NOT_READY',
        'GroupCallViewProvider is not ready. Mount the root-level singleton and complete neGroupCallConfig setup before calling groupJoin().'
      )
    )
  }

  return registry.groupJoin(opt)
}

export function useCall(): UseCallResult {
  return {
    call,
    neCall: registry.neCall,
  }
}

export function useGroupCall(): UseGroupCallResult {
  return {
    groupCall,
    groupJoin,
    neGroupCall: registry.neGroupCall,
  }
}
