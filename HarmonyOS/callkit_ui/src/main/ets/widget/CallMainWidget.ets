// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { CallManager } from '../impl/CallManager';
import { NECallType, NECallStatus, NECallRole, NECamera } from '../CallDefine';
import { Constants, setStateEvent, setStateEventRefreshTiming } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import { CallsP2PUserWidget } from './CallP2PUserWidget';
import { CallFunctionWidget } from './CallFunctionWidget';

/**
 * 通话组件
 * 对应 Flutter 版本的 CallsWidget
 * 负责状态管理、事件监听、渲染单个用户通话界面和功能按钮
 */
@Component
export struct CallMainWidget {
  close: () => void = () => {};
  
  @State isMultiPerson: boolean = false;
  
  private setStateCallBack = () => {
    const state = CallState.instance;
    if (this.isMultiPerson || state.remoteUserList.length >= 2) {
      this.isMultiPerson = true;
    }
  }

  aboutToAppear(): void {
    // 注册状态变化事件
    NEEventNotify.getInstance().register(setStateEvent, this.setStateCallBack);
    
    // 检查是否多人通话
    if (CallState.instance.remoteUserList.length >= 2) {
      this.isMultiPerson = true;
    }
  }

  aboutToDisappear(): void {
    // 注销事件监听
    NEEventNotify.getInstance().unregister(setStateEvent, this.setStateCallBack);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 单个用户通话界面（占据全屏）
      if (!this.isMultiPerson) {
        CallsP2PUserWidget({ close: this.close })
          .width('100%')
          .height('100%')
      }
      
      // 功能按钮（悬浮在底部上层）
      CallFunctionWidget({ close: this.close })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#2D2D2D')
  }
}

