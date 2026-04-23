// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AbilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { NECallType, NEErrorCode } from '@yunxin/callkit';
import { CallUILog } from './CallUILog';
import { ToastUtils } from './ToastUtils';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { promptAction } from '@kit.ArkUI';

/**
 * 权限拒绝原因
 * @since 2.0.0
 */
export enum PermissionDenialReason {
  /** 用户拒绝 */
  USER_DENIED = 'user_denied',
  /** 用户永久拒绝（不再询问） */
  PERMANENTLY_DENIED = 'permanently_denied',
  /** 系统限制 */
  SYSTEM_RESTRICTED = 'system_restricted'
}

/**
 * 权限检查结果
 * @since 2.0.0
 */
export interface PermissionCheckResult {
  /** 错误码 */
  code: number;
  /** 权限拒绝原因（仅在权限被拒绝时有效） */
  denialReason?: PermissionDenialReason;
  /** 被拒绝的权限列表 */
  deniedPermissions?: string[];
}

/**
 * 权限 工具类
 * 提供与 权限相关 的工具方法
 */
export class PermissionUtils {
  private static readonly TAG = 'PermissionUtils';

  /**
   * 请求媒体权限（麦克风、摄像头）
   * - 音频通话：至少需要麦克风权限
   * - 视频通话：需要麦克风 + 摄像头权限
   * @param callType 通话类型
   * @returns 错误码：
   *          - NEErrorCode.SUCCESS：权限已全部授予
   *          - NEErrorCode.ERROR_PERMISSION_DENIED_MICROPHONE：麦克风权限未授予
   *          - NEErrorCode.ERROR_PERMISSION_DENIED_CAMERA：摄像头权限未授予
   */
  static async requestMediaPermissions(context: Context, callType: NECallType): Promise<number> {
    CallUILog.info(PermissionUtils.TAG, `requestMediaPermissions: callType=${callType}`);

    const atManager = AbilityAccessCtrl.createAtManager();

    if (!context) {
      CallUILog.error(PermissionUtils.TAG, 'requestMediaPermissions: context is null, skip permission request');
      // 如果拿不到 context，这里保守认为成功，后续底层仍会再次校验
      return NEErrorCode.SUCCESS;
    }
    // 根据通话类型决定需要的权限
    const permissions: Array<Permissions> = [
      'ohos.permission.MICROPHONE'
    ];
    if (callType === NECallType.VIDEO) {
      permissions.push('ohos.permission.CAMERA');
    }

    return new Promise<number>((resolve, reject) => {
      try {
        atManager.requestPermissionsFromUser(
          context,
          permissions,
          (err, data) => {
            if (err) {
              CallUILog.error(PermissionUtils.TAG, `requestMediaPermissions: requestPermissionsFromUser failed, err=${JSON.stringify(err)}`);
              reject(err);
              return;
            }

            // data.authResults 与 permissions 一一对应
            let micGranted = false;
            let cameraGranted = true; // 默认 true，音频通话时可能不会请求摄像头

            // 第一个一定是 MIC
            micGranted = data.authResults[0] === AbilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;

            // 如果是视频通话，第二个是 CAMERA
            if (callType === NECallType.VIDEO) {
              cameraGranted = data.authResults[1] === AbilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
            }

            CallUILog.info(
              PermissionUtils.TAG,
              `requestMediaPermissions: micGranted=${micGranted}, cameraGranted=${cameraGranted}, callType=${callType}`
            );

            if (!micGranted) {
              resolve(NEErrorCode.ERROR_PERMISSION_DENIED_MICROPHONE);
              return;
            }
            if (!cameraGranted) {
              resolve(NEErrorCode.ERROR_PERMISSION_DENIED_CAMERA);
              return;
            }

            resolve(NEErrorCode.SUCCESS);
          }
        );
      } catch (error) {
        CallUILog.error(PermissionUtils.TAG, `requestMediaPermissions: exception=${String(error)}`);
        reject(error);
      }
    });
  }

  /**
   * 检查权限是否已被永久拒绝
   * @param context 上下文
   * @param permission 权限名称
   * @returns 是否被永久拒绝
   * @since 2.0.0
   */
  static async isPermissionPermanentlyDenied(context: Context, permission: Permissions): Promise<boolean> {
    try {
      const atManager = AbilityAccessCtrl.createAtManager();
      const tokenId = await PermissionUtils.getTokenId(context);
      if (tokenId === 0) {
        return false;
      }
      const grantStatus = atManager.checkAccessTokenSync(tokenId, permission);
      // 如果权限未授予，可能是永久拒绝
      return grantStatus === AbilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    } catch (error) {
      CallUILog.error(PermissionUtils.TAG, `isPermissionPermanentlyDenied: exception=${String(error)}`);
      return false;
    }
  }

  /**
   * 获取应用的 tokenId
   * @param context 上下文
   * @returns tokenId
   * @since 2.0.0
   */
  private static async getTokenId(context: Context): Promise<number> {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      return bundleInfo.appInfo?.accessTokenId ?? 0;
    } catch (error) {
      CallUILog.error(PermissionUtils.TAG, `getTokenId: exception=${String(error)}`);
      return 0;
    }
  }

  /**
   * 显示权限拒绝的引导提示
   * @param context 上下文
   * @param errorCode 错误码
   * @since 2.0.0
   */
  static showPermissionDeniedGuidance(context: common.UIAbilityContext, errorCode: number): void {
    let message = '';
    let buttonText = '去设置';

    switch (errorCode) {
      case NEErrorCode.ERROR_PERMISSION_DENIED_MICROPHONE:
        message = '麦克风权限未授予，无法进行通话。请在设置中开启麦克风权限。';
        break;
      case NEErrorCode.ERROR_PERMISSION_DENIED_CAMERA:
        message = '摄像头权限未授予，无法进行视频通话。请在设置中开启摄像头权限。';
        break;
      default:
        message = '媒体权限未授予，无法进行通话。请在设置中开启相关权限。';
        break;
    }

    try {
      promptAction.showDialog({
        title: '权限提示',
        message: message,
        buttons: [
          {
            text: '取消',
            color: '#666666'
          },
          {
            text: buttonText,
            color: '#007AFF'
          }
        ]
      }).then((result) => {
        if (result.index === 1) {
          // 用户点击了"去设置"
          PermissionUtils.openAppSettings(context);
        }
      }).catch((err: Error) => {
        CallUILog.error(PermissionUtils.TAG, `showDialog error: ${err.message}`);
      });
    } catch (error) {
      CallUILog.error(PermissionUtils.TAG, `showPermissionDeniedGuidance: exception=${String(error)}`);
      // 降级方案：显示简单的 toast
      ToastUtils.showToastWithString(context, message);
    }
  }

  /**
   * 打开应用设置页面
   * @param context 上下文
   * @since 2.0.0
   */
  static openAppSettings(context: common.UIAbilityContext): void {
    CallUILog.info(PermissionUtils.TAG, 'openAppSettings');
    try {
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const bundleName = bundleInfo.name;

      const want: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
          pushParams: bundleName
        }
      };

      context.startAbility(want).then(() => {
        CallUILog.info(PermissionUtils.TAG, 'openAppSettings: success');
      }).catch((err: Error) => {
        CallUILog.error(PermissionUtils.TAG, `openAppSettings: startAbility failed, err=${err.message}`);
        // 降级方案：尝试通用设置页面
        PermissionUtils.openGeneralSettings(context);
      });
    } catch (error) {
      CallUILog.error(PermissionUtils.TAG, `openAppSettings: exception=${String(error)}`);
      PermissionUtils.openGeneralSettings(context);
    }
  }

  /**
   * 打开通用设置页面（降级方案）
   * @param context 上下文
   * @since 2.0.0
   */
  private static openGeneralSettings(context: common.UIAbilityContext): void {
    try {
      const want: Want = {
        action: 'ohos.settings.action.SETTINGS'
      };
      context.startAbility(want).then(() => {
        CallUILog.info(PermissionUtils.TAG, 'openGeneralSettings: success');
      }).catch((err: Error) => {
        CallUILog.error(PermissionUtils.TAG, `openGeneralSettings: startAbility failed, err=${err.message}`);
      });
    } catch (error) {
      CallUILog.error(PermissionUtils.TAG, `openGeneralSettings: exception=${String(error)}`);
    }
  }

  /**
   * 获取权限拒绝的用户友好提示信息
   * @param errorCode 错误码
   * @returns 提示信息
   * @since 2.0.0
   */
  static getPermissionDeniedMessage(errorCode: number): string {
    switch (errorCode) {
      case NEErrorCode.ERROR_PERMISSION_DENIED_MICROPHONE:
        return '麦克风权限未授予';
      case NEErrorCode.ERROR_PERMISSION_DENIED_CAMERA:
        return '摄像头权限未授予';
      default:
        return '媒体权限未授予';
    }
  }

  /**
   * 显示权限拒绝 toast（兼容旧调用）
   * @param context 上下文（当前实现无需使用）
   * @param errorCode 错误码
   */
  static showPermissionDeniedToast(context: common.UIAbilityContext, errorCode: number): void {
    ToastUtils.showToastWithString(context, PermissionUtils.getPermissionDeniedMessage(errorCode));
  }
}
