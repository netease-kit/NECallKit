/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

import com.netease.yunxin.nertc.ui.service.foregroundservice.ServiceState

internal class CallForegroundServiceStateMachine {

    data class StopAction(val stopServiceNow: Boolean)

    data class StartAction(val stopSelfNow: Boolean)

    var state: ServiceState = ServiceState.IDLE
        private set

    var serviceId: String? = null
        private set

    fun markStarting(serviceId: String) {
        this.serviceId = serviceId
        state = ServiceState.STARTING
    }

    fun requestStop(serviceId: String?): StopAction {
        if (serviceId != null && serviceId != this.serviceId) {
            return StopAction(stopServiceNow = false)
        }
        return when (state) {
            ServiceState.STARTING -> {
                state = ServiceState.STOPPING
                StopAction(stopServiceNow = false)
            }
            ServiceState.RUNNING -> {
                reset()
                StopAction(stopServiceNow = true)
            }
            ServiceState.STOPPING,
            ServiceState.IDLE -> {
                reset()
                StopAction(stopServiceNow = false)
            }
        }
    }

    fun onForegroundStarted(serviceId: String?): StartAction {
        if (serviceId != null && this.serviceId != null && serviceId != this.serviceId) {
            return StartAction(stopSelfNow = true)
        }
        if (serviceId != null) {
            this.serviceId = serviceId
        }
        return if (state == ServiceState.STOPPING) {
            reset()
            StartAction(stopSelfNow = true)
        } else {
            state = ServiceState.RUNNING
            StartAction(stopSelfNow = false)
        }
    }

    fun resetIfCurrent(serviceId: String?) {
        if (serviceId != null && serviceId == this.serviceId) {
            reset()
        }
    }

    fun reset() {
        state = ServiceState.IDLE
        serviceId = null
    }
}
