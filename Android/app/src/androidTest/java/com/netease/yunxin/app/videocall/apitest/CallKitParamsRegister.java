// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.kit.call.NEResultObserver;
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate;
import com.netease.yunxin.kit.call.p2p.model.NERecordProvider;
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig;
import com.netease.yunxin.kit.call.p2p.param.NECallParam;
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam;
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam;
import com.netease.yunxin.kit.integrationtest.base.BaseParseAdapter;
import com.netease.yunxin.kit.integrationtest.register.ParamsRegister;
import com.netease.yunxin.nertc.nertcvideocall.model.JoinChannelCallBack;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCCallingDelegate;
import java.util.HashSet;
import java.util.Set;

public class CallKitParamsRegister implements ParamsRegister {

  @Override
  /** 注册需要特殊解析的参数类型 */
  public Set<Class<?>> getRegisterType() {
    Set<Class<?>> set = new HashSet<>();
    set.add(JoinChannelCallBack.class);
    set.add(RequestCallback.class);
    set.add(NERTCCallingDelegate.class);
    set.add(NESetupConfig.class);
    set.add(NECallParam.class);
    set.add(NEHangupParam.class);
    set.add(NESwitchParam.class);
    set.add(NERecordProvider.class);
    set.add(NECallEngineDelegate.class);
    set.add(NEResultObserver.class);
    return set;
  }

  @Override
  /** 注册参数类型的解析适配器 */
  public BaseParseAdapter<?> getParseAdapter() {
    return new CallKitParseAdapter<>();
  }
}
