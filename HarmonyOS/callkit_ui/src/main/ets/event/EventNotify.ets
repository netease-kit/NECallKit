// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * Event callback function type
 */
export type NEEventCallback = (arg?: Record<string, Object>) => void;

/**
 * Event notification manager
 * Singleton pattern for event registration and notification
 */
export class NEEventNotify {
  private static instance: NEEventNotify = new NEEventNotify();

  private messageQueue: Map<string, Array<NEEventCallback>> = new Map();

  /**
   * Private constructor for singleton pattern
   */
  private constructor() {
  }

  /**
   * Get singleton instance
   * @returns NEEventNotify instance
   */
  public static getInstance(): NEEventNotify {
    return NEEventNotify.instance;
  }

  /**
   * Register an event callback
   * @param eventName Event name
   * @param callback Callback function, can be null
   */
  public register(eventName: string, callback?: NEEventCallback): void {
    if (callback != null) {
      let callbacks = this.messageQueue.get(eventName);
      if (callbacks == null) {
        callbacks = new Array<NEEventCallback>();
        this.messageQueue.set(eventName, callbacks);
      }
      callbacks.push(callback);
    }
  }

  /**
   * Unregister an event callback
   * @param eventName Event name
   * @param callback Callback function, can be null
   */
  public unregister(eventName: string, callback?: NEEventCallback): void {
    if (callback != null) {
      let callbacks = this.messageQueue.get(eventName);
      if (callbacks != null) {
        let index = callbacks.indexOf(callback);
        if (index !== -1) {
          callbacks.splice(index, 1);
        }
      }
    }
  }

  /**
   * Notify all registered callbacks for an event
   * @param eventName Event name
   * @param arg Optional arguments to pass to callbacks
   */
  public notify(eventName: string, arg?: Record<string, Object>): void {
    let callbacks = this.messageQueue.get(eventName);
    if (callbacks != null && callbacks.length > 0) {
      for (let i = 0; i < callbacks.length; i++) {
        callbacks[i](arg);
      }
    }
  }
}

/**
 * Event name constants
 */
export const loginSuccessEvent: string = 'LOGIN_SUCCESS_EVENT';
export const logoutSuccessEvent: string = 'LOGOUT_SUCCESS_EVENT';
export const imSDKInitSuccessEvent: string = 'IM_SDK_INIT_SUCCESS_EVENT';




