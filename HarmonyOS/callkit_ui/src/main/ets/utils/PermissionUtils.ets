// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AbilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { NECallType, NEErrorCode } from '@necallkit/callkit';
import { CallUILog } from './CallUILog';

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
}

