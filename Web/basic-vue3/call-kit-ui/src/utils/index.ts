import { EventTracking } from '@xkit-yx/utils'
import type {
  CommonError,
  NIMLike,
  NIMUserProfile,
  TrackInitOptions,
  UserInfo,
} from '../interface'

export function secondToDate(result: number): string {
  let h: number | string = Math.floor(result / 3600)
  let m: number | string = Math.floor((result / 60) % 60)
  let s: number | string = Math.floor(result % 60)

  if (s < 10) {
    s = `0${s}`
  }

  if (m < 10) {
    m = `0${m}`
  }

  if (h === 0) {
    return `${m}:${s}`
  }

  if (h < 10) {
    h = `0${h}`
  }

  return `${h}:${m}:${s}`
}

export function normalizeUserInfo(user?: Partial<NIMUserProfile>): UserInfo {
  return {
    account: user?.accountId || '',
    avatar: user?.avatar || '',
    nick: user?.name || '',
    tel: user?.mobile || '',
  }
}

export async function getUserByAccount(
  nim: NIMLike | undefined,
  account: string
): Promise<UserInfo | undefined> {
  if (!nim || !account) {
    return undefined
  }

  const users = await nim.V2NIMUserService.getUserList([account])

  return normalizeUserInfo(users[0])
}

export function logConsoleError(
  message: string,
  account: string,
  err: unknown
): void {
  const error = err as Partial<CommonError>
  const detail = error?.toString?.() || error?.message || String(err)

  console.error(message, account, detail)
}

export async function ensureCameraPermission(): Promise<boolean> {
  if (
    typeof navigator === 'undefined' ||
    !navigator.mediaDevices ||
    !navigator.mediaDevices.getUserMedia
  ) {
    return false
  }

  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video: true })

    stream.getTracks().forEach((track) => {
      track.stop()
    })

    return true
  } catch {
    return false
  }
}

export function trackInit(options: TrackInitOptions): void {
  const eventTracking = new EventTracking({
    appKey: options.appKey,
    version: options.version,
    component: options.component,
  })

  eventTracking.track('init', '')
}
