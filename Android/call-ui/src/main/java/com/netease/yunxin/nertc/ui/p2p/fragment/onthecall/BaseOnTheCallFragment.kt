/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.onthecall

import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment

open class BaseOnTheCallFragment : BaseP2pCallFragment() {

    override fun onCreateAction() {
        super.onCreateAction()

        // 开启AI字幕功能
//        val config = NERtcASRCaptionConfig()
//        config.dstLanguageArr = arrayOf("en") // 指定字幕的目标语言，zh表示简体中文
//        NERtcEx.getInstance().startASRCaption(config)
    }

    override fun onDestroyAction() {
        super.onDestroyAction()
        // 关闭AI字幕功能
//        NERtcEx.getInstance().stopASRCaption()
    }
}
