package com.netease.yunxin.nertc.ui.base

internal data class CallPageReleaseDecision(
    val finishCall: Boolean,
    val releaseUiState: Boolean,
    val stopVideoPreview: Boolean
)

internal fun decideCallPageRelease(
    isCallActive: Boolean,
    isFloating: Boolean
): CallPageReleaseDecision {
    val keepFloatingCall = isCallActive && isFloating
    return CallPageReleaseDecision(
        finishCall = isCallActive && !keepFloatingCall,
        releaseUiState = !keepFloatingCall,
        stopVideoPreview = !keepFloatingCall
    )
}
