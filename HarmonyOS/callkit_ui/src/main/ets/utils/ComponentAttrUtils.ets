// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { componentUtils, UIContext } from '@kit.ArkUI';
import { RectInfo } from '../data/Constants';

/**
 * 组件位置信息（像素单位）
 * 用于获取组件相对于窗口的精确位置
 * @since 2.1.0
 */
export class RectInfoInPx {
  left: number = 0;
  top: number = 0;
  right: number = 0;
  bottom: number = 0;
  width: number = 0;
  height: number = 0;
}

/**
 * 组件属性工具类
 * 提供获取组件位置和尺寸的工具方法
 * @since 2.1.0
 */
export class ComponentAttrUtils {
  /**
   * 根据组件 ID 获取组件相对于窗口的位置信息（像素单位）
   * @param context UIContext 实例
   * @param id 组件 ID（通过 .id('xxx') 设置）
   * @returns 组件位置信息，如果获取失败返回 null
   */
  public static getRectInfoById(context: UIContext | undefined, id: string): RectInfoInPx | null {
    if (!context || !id) {
      return null;
    }

    try {
      const componentInfo: componentUtils.ComponentInfo =
        context.getComponentUtils().getRectangleById(id);

      if (!componentInfo) {
        return null;
      }

      const rstRect: RectInfoInPx = new RectInfoInPx();

      // 考虑缩放导致的尺寸差异
      const widthScaleGap = componentInfo.size.width * (1 - componentInfo.scale.x) / 2;
      const heightScaleGap = componentInfo.size.height * (1 - componentInfo.scale.y) / 2;

      // 计算实际位置（考虑 translate 和 windowOffset）
      rstRect.left = componentInfo.translate.x + componentInfo.windowOffset.x + widthScaleGap;
      rstRect.top = componentInfo.translate.y + componentInfo.windowOffset.y + heightScaleGap;
      rstRect.right = rstRect.left + componentInfo.size.width - 2 * widthScaleGap;
      rstRect.bottom = rstRect.top + componentInfo.size.height - 2 * heightScaleGap;
      rstRect.width = rstRect.right - rstRect.left;
      rstRect.height = rstRect.bottom - rstRect.top;

      return rstRect;
    } catch (e) {
      return null;
    }
  }

  /**
   * 根据组件 ID 获取组件位置信息（转换为 RectInfo）
   * @param context UIContext 实例
   * @param id 组件 ID（通过 .id('xxx') 设置）
   * @returns RectInfo 对象，如果获取失败返回 null
   */
  public static getRectById(context: UIContext | undefined, id: string): RectInfo | null {
    const rectInPx = ComponentAttrUtils.getRectInfoById(context, id);
    if (!rectInPx) {
      return null;
    }
    return new RectInfo(rectInPx.left, rectInPx.top, rectInPx.width, rectInPx.height);
  }
}
