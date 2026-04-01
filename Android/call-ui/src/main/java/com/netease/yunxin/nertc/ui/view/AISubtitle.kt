/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.view

import android.content.Context
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.util.AttributeSet
import android.widget.ScrollView
import androidx.appcompat.widget.AppCompatTextView
import com.netease.lava.nertc.sdk.NERtcAsrCaptionResult
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.ui.base.fetchNickname

class AISubtitle(context: Context, attrs: AttributeSet?) : ScrollView(context, attrs) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val translationInfo = mutableListOf<TranslationInfo>()
    private lateinit var textView: AppCompatTextView
    private val isShowTranslation: Boolean = false

    init {
        initView()
    }

    private fun initView() {
        isVerticalScrollBarEnabled = true
        isScrollbarFadingEnabled = false
        // 设置半透明灰色背景
        setBackgroundColor(0x80000000.toInt())
        textView = AppCompatTextView(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            setPadding(16, 16, 16, 16)
            textSize = 14f
            setTextColor(0xFFFFFFFF.toInt())
        }
        addView(textView)
    }

    private val rtcCallback = object : NERtcCallbackExTemp() {

        override fun onAsrCaptionResult(
            result: Array<out NERtcAsrCaptionResult>?,
            resultCount: Int
        ) {
            if (result != null) {
                for (ret in result) {
                    if (ret.isFinal && isShowTranslation == ret.haveTranslation) {
                        val translationInfoItem = TranslationInfo().apply {
                            uid = ret.uid
                            text = if (isShowTranslation) ret.translatedText else ret.content
                            haveTranslation = ret.haveTranslation
                        }
                        translationInfo.add(translationInfoItem)
                        // 只保留最新的两条字幕
                        if (translationInfo.size > 2) {
                            translationInfo.removeAt(0)
                        }

                        val accId =
                            NECallEngine.sharedInstance().getUserWithRtcUid(ret.uid)?.accId
                        if (accId != null) {
                            accId.fetchNickname { name ->
                                translationInfoItem.displayName = name
                                updateView()
                            }
                        } else {
                            translationInfoItem.displayName = ret.uid.toString()
                            updateView()
                        }
                    }
                }
            }
        }
    }

    private fun updateView() {
        val spannableBuilder = SpannableStringBuilder()
        for ((index, message) in translationInfo.withIndex()) {
            val displayName =
                message.displayName
                    ?: NECallEngine.sharedInstance().getUserWithRtcUid(message.uid)?.accId
                    ?: message.uid.toString()
            val fullText = "$displayName:\n${message.text}\n"
            formatAISubtitleText(spannableBuilder, displayName, fullText)
            if (index < translationInfo.size - 1) {
                spannableBuilder.append("\n")
            }
        }
        mainHandler.post {
            textView.text = spannableBuilder
            visibility = VISIBLE
            post {
                fullScroll(FOCUS_DOWN)
            }
        }
    }

    private fun formatAISubtitleText(
        spannableBuilder: SpannableStringBuilder,
        displayName: String,
        fullText: String
    ) {
        val spannableString = SpannableString(fullText)
        val nameStart = 0
        val nameEnd = displayName.length + 1
        spannableString.setSpan(
            ForegroundColorSpan(0xFFD9CC66.toInt()),
            nameStart,
            nameEnd,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        spannableString.setSpan(
            StyleSpan(Typeface.BOLD),
            nameStart,
            nameEnd,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        spannableBuilder.append(spannableString)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcCallback)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcCallback)
    }

    private class TranslationInfo {
        var uid: Long = 0
        var text: String = ""
        var displayName: String? = null
        var haveTranslation = false
    }
}
