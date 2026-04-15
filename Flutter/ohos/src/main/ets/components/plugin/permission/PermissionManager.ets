import { abilityAccessCtrl, bundleManager, common, Want, Permissions } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { CallUILog } from '../utils/CallUILog';

const TAG = 'PermissionManager';

/** 权限提示内容接口 */
interface PermissionAlertContent {
  title: string;
  message: string;
}

/** 权限 index → 鸿蒙权限字符串映射 */
function indexToPermission(index: number): Permissions | null {
  switch (index) {
    case 0: return 'ohos.permission.CAMERA';
    case 1: return 'ohos.permission.MICROPHONE';
    case 2: return 'ohos.permission.USE_BLUETOOTH';
    default: return null;
  }
}

/** 权限名称映射（用于生成提示文案） */
function getPermissionName(permission: Permissions): string {
  switch (permission) {
    case 'ohos.permission.CAMERA': return '摄像头';
    case 'ohos.permission.MICROPHONE': return '麦克风';
    case 'ohos.permission.USE_BLUETOOTH': return '蓝牙';
    default: return '权限';
  }
}

export class PermissionManager {
  /** 查询多个权限是否全部已授予（同步）*/
  hasPermissions(indices: number[], context: common.UIAbilityContext): boolean {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const tokenId = context.applicationInfo?.accessTokenId ?? 0;
      for (const idx of indices) {
        const perm = indexToPermission(idx);
        if (perm === null) continue;
        const status = atManager.checkAccessTokenSync(tokenId, perm);
        if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          return false;
        }
      }
      return true;
    } catch (e) {
      CallUILog.e(TAG, `hasPermissions error: ${(e as Error)?.message ?? e}`);
      return false;
    }
  }

  /** 动态申请权限，结果通过 callback 返回（0=Granted, 1=Denied, 2=Requesting）*/
  requestPermissions(
    indices: number[],
    context: common.UIAbilityContext,
    callback: (result: number) => void
  ): void {
    const permissions: Array<Permissions> = [];
    for (const idx of indices) {
      const perm = indexToPermission(idx);
      if (perm !== null) {
        permissions.push(perm);
      }
    }

    if (permissions.length === 0) {
      callback(0);
      return;
    }

    try {
      const atManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(context, permissions)
        .then((data) => {
          // 检查是否所有权限都已授予
          const allGranted = data.authResults.every(
            r => r === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
          );
          
          if (allGranted) {
            CallUILog.i(TAG, 'All permissions granted');
            callback(0); // Granted
          } else {
            // 收集被拒绝的权限
            const deniedPermissions: Array<Permissions> = [];
            for (let i = 0; i < data.authResults.length; i++) {
              if (data.authResults[i] !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
                deniedPermissions.push(permissions[i]);
              }
            }
            
            CallUILog.w(TAG, `Permissions denied: ${JSON.stringify(deniedPermissions)}`);
            
            // 显示权限被拒绝的引导对话框
            this.showPermissionDeniedDialog(context, deniedPermissions)
              .then((shouldOpenSettings) => {
                if (shouldOpenSettings) {
                  // 用户点击"去设置"，返回 Requesting 状态
                  callback(2); // Requesting
                } else {
                  // 用户点击"取消"，返回 Denied 状态
                  callback(1); // Denied
                }
              })
              .catch(() => {
                callback(1); // Denied
              });
          }
        })
        .catch((e: Error) => {
          CallUILog.e(TAG, `requestPermissions error: ${e?.message ?? e}`);
          callback(1);
        });
    } catch (e) {
      CallUILog.e(TAG, `requestPermissions exception: ${(e as Error)?.message ?? e}`);
      callback(1);
    }
  }

  /** 显示权限被拒绝的引导对话框
   * @returns Promise<boolean> - true: 用户选择去设置, false: 用户取消
   */
  private showPermissionDeniedDialog(
    context: common.UIAbilityContext,
    deniedPermissions: Array<Permissions>
  ): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        const alertContent = this.generatePermissionAlertContent(deniedPermissions);
        const title = alertContent.title;
        const message = alertContent.message;
        
        CallUILog.i(TAG, `Showing permission denied dialog: ${title}`);
        
        promptAction.showDialog({
          title: title,
          message: message,
          buttons: [
            {
              text: '取消',
              color: '#666666'
            },
            {
              text: '去设置',
              color: '#007AFF'
            }
          ]
        }).then((result) => {
          if (result.index === 1) {
            // 用户点击"去设置"
            CallUILog.i(TAG, 'User chose to go to settings');
            this.startToPermissionSetting(context);
            resolve(true);
          } else {
            // 用户点击"取消"
            CallUILog.i(TAG, 'User cancelled permission request');
            resolve(false);
          }
        }).catch((e: Error) => {
          CallUILog.e(TAG, `showDialog error: ${e?.message ?? e}`);
          resolve(false);
        });
      } catch (e) {
        CallUILog.e(TAG, `showPermissionDeniedDialog exception: ${(e as Error)?.message ?? e}`);
        resolve(false);
      }
    });
  }

  /** 根据被拒绝的权限生成对话框内容 */
  private generatePermissionAlertContent(
    deniedPermissions: Array<Permissions>
  ): PermissionAlertContent {
    if (deniedPermissions.length === 0) {
      const content: PermissionAlertContent = {
        title: '权限申请',
        message: '需要访问您的相关权限，用于音视频通话功能。'
      };
      return content;
    }

    // 检查是否包含麦克风权限
    const hasMicrophone = deniedPermissions.includes('ohos.permission.MICROPHONE');
    // 检查是否包含摄像头权限
    const hasCamera = deniedPermissions.includes('ohos.permission.CAMERA');

    if (hasMicrophone && hasCamera) {
      // 同时缺少麦克风和摄像头权限
      const content: PermissionAlertContent = {
        title: '麦克风和摄像头权限未开启',
        message: '无法使用麦克风和摄像头，请前往"设置 > 应用和元服务 > 当前应用"中打开相应的权限。'
      };
      return content;
    } else if (hasMicrophone) {
      // 只缺少麦克风权限
      const content: PermissionAlertContent = {
        title: '麦克风权限未开启',
        message: '无法使用麦克风，请前往"设置 > 应用和元服务 > 当前应用"中打开麦克风权限。'
      };
      return content;
    } else if (hasCamera) {
      // 只缺少摄像头权限
      const content: PermissionAlertContent = {
        title: '摄像头权限未开启',
        message: '无法使用摄像头，请前往"设置 > 应用和元服务 > 当前应用"中打开摄像头权限。'
      };
      return content;
    } else {
      // 其他权限
      const permNames = deniedPermissions.map(p => getPermissionName(p)).join('、');
      const content: PermissionAlertContent = {
        title: '权限未开启',
        message: `无法使用${permNames}，请前往"设置 > 应用和元服务 > 当前应用"中打开相应的权限。`
      };
      return content;
    }
  }

  /** 跳转系统应用权限设置页 */
  startToPermissionSetting(context: common.UIAbilityContext): void {
    try {
      const bundleName = context.abilityInfo?.bundleName ?? '';
      const want: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: { pushParams: bundleName },
      };
      context.startAbility(want).catch((e: Error) => {
        CallUILog.e(TAG, `startToPermissionSetting failed: ${e?.message ?? e}`);
      });
    } catch (e) {
      CallUILog.e(TAG, `startToPermissionSetting exception: ${(e as Error)?.message ?? e}`);
    }
  }
}
