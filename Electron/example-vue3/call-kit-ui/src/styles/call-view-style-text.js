"use strict";

// Generated from packages/callkit-design/src/styles/call-view.vue3.css by scripts/generate-callkit-design.js.
// Do not edit manually.
// Keep the Electron wrapper self-contained in packaged apps.
const CALL_VIEW_STYLE_TEXT = String.raw`.necall-view {
  position: fixed;
  top: 12px;
  left: 50%;
  z-index: 98;
  width: min(375px, calc(100vw - 24px));
  height: min(606px, calc(100vh - 24px));
  transform: translateX(-50%);
  overflow: hidden;
  border-radius: 24px;
  background: #1d1d23;
  box-shadow: 0 16px 60px rgba(0, 0, 0, 0.32);
  color: #ffffff;
}

.necall-notice {
  position: fixed;
  top: 16px;
  left: 50%;
  z-index: 99;
  max-width: min(420px, calc(100vw - 24px));
  padding: 12px 18px;
  transform: translateX(-50%);
  border-radius: 999px;
  background: rgba(24, 28, 38, 0.92);
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.2);
  color: #ffffff;
  font-size: 14px;
  line-height: 1.4;
  text-align: center;
}

.necall-notice-bar {
  position: absolute;
  top: 12px;
  left: 12px;
  right: 12px;
  z-index: 12;
  min-height: 36px;
  padding: 8px 12px;
  border-radius: 10px;
  box-sizing: border-box;
  background: rgba(245, 34, 45, 0.88);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  font-size: 13px;
  line-height: 1.4;
}

.necall-reconnecting-bar {
  background: rgba(22, 119, 255, 0.88);
}

.necall-notice-close {
  border: 0;
  background: transparent;
  color: #ffffff;
  cursor: pointer;
  font-size: 18px;
  line-height: 1;
}

.necall-toast {
  position: absolute;
  top: 50%;
  left: 50%;
  z-index: 13;
  transform: translate(-50%, -50%);
  padding: 8px 16px;
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.68);
  color: #ffffff;
  font-size: 13px;
  white-space: nowrap;
  pointer-events: none;
}

.necall-dialog-mask {
  position: absolute;
  inset: 0;
  z-index: 14;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.45);
}

.necall-dialog {
  width: 280px;
  padding: 20px;
  border-radius: 14px;
  background: #ffffff;
  box-sizing: border-box;
  color: #1d1d23;
}

.necall-dialog-title {
  margin-bottom: 12px;
  font-size: 18px;
  font-weight: 600;
}

.necall-dialog-content {
  font-size: 14px;
  line-height: 1.5;
}

.necall-dialog-btn-group {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 16px;
}

.necall-dialog-btn {
  padding: 8px 16px;
  border: 0;
  border-radius: 999px;
  background: #ececf1;
  color: #1d1d23;
  cursor: pointer;
}

.necall-dialog-btn-primary {
  background: #1677ff;
  color: #ffffff;
}

.necall-view-content {
  position: relative;
  width: 100%;
  height: 100%;
}

.necall-video-stage {
  position: relative;
  width: 100%;
  height: 100%;
}

.necall-blur-bg-mark {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at top, rgba(89, 152, 255, 0.32), transparent 42%),
    linear-gradient(180deg, rgba(50, 55, 73, 0.92), rgba(18, 20, 31, 0.98));
}

.necall-video-mask {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(9, 11, 17, 0.12), rgba(9, 11, 17, 0.58)),
    radial-gradient(circle at top, rgba(89, 152, 255, 0.18), transparent 38%);
  pointer-events: none;
}

.necall-callee-info,
.necall-caller-info,
.necall-in-call-audio {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  width: calc(100% - 48px);
  text-align: center;
}

.necall-callee-info {
  top: 72px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  text-align: left;
}

.necall-callee-info-floating {
  z-index: 1;
}

.necall-callee-copy {
  padding-top: 8px;
}

.necall-callee-nickname,
.necall-caller-nickname,
.necall-in-call-title {
  font-size: 24px;
  font-weight: 600;
  line-height: 1.3;
}

.necall-callee-tips,
.necall-caller-tips,
.necall-in-call-tips {
  margin-top: 8px;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.78);
}

.necall-caller-info,
.necall-in-call-audio {
  top: 96px;
}

.necall-caller-avatar,
.necall-callee-avatar,
.necall-in-call-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #4f8cff, #17b6d8);
  color: #ffffff;
  font-weight: 700;
  letter-spacing: 0.5px;
  overflow: hidden;
}

.necall-caller-avatar,
.necall-in-call-avatar {
  width: 96px;
  height: 96px;
  margin: 0 auto;
  border-radius: 28px;
  font-size: 22px;
}

.necall-callee-avatar {
  width: 72px;
  height: 72px;
  border-radius: 22px;
  font-size: 16px;
}

.necall-calling-btn-group,
.necall-called-btn-group {
  position: absolute;
  right: 24px;
  bottom: 42px;
  left: 24px;
  display: flex;
  justify-content: center;
  gap: 36px;
  z-index: 1;
}

.necall-called-btn-group {
  gap: 108px;
}

.necall-called-btn-group .necall-btn-image {
  width: 64px;
  height: 64px;
}

.necall-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 0;
  border: 0;
  background: transparent;
  color: #ffffff;
  cursor: pointer;
}

.necall-btn:focus-visible {
  outline: 2px solid rgba(255, 255, 255, 0.78);
  outline-offset: 6px;
  border-radius: 18px;
}

.necall-btn-image {
  display: block;
  width: 75px;
  height: 75px;
  object-fit: contain;
  pointer-events: none;
  user-select: none;
}

.necall-btn-label {
  font-size: 13px;
}

.necall-large-view {
  position: absolute;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  background:
    radial-gradient(circle at top, rgba(87, 140, 255, 0.2), transparent 32%),
    linear-gradient(180deg, #11151f, #020304);
}

.necall-large-placeholder,
.necall-small-placeholder {
  display: flex;
  height: 100%;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.necall-placeholder-title {
  font-size: 18px;
  font-weight: 600;
}

.necall-placeholder-copy {
  margin-top: 8px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.72);
}

.necall-small-view {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 3;
  width: 125px;
  height: 202px;
  overflow: hidden;
  appearance: none;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 18px;
  padding: 0;
  background: rgba(17, 21, 31, 0.86);
  backdrop-filter: blur(8px);
  color: inherit;
  cursor: pointer;
  font: inherit;
  text-align: inherit;
}

.necall-small-view:focus-visible {
  outline: 2px solid rgba(255, 255, 255, 0.78);
  outline-offset: 2px;
}

.necall-small-placeholder {
  padding: 16px;
}

.necall-video-surface {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.necall-video-dom-host {
  position: absolute;
  inset: 0;
}

.necall-video-canvas {
  position: absolute;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: #090b11;
}

.necall-video-fallback {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 16px;
  text-align: center;
  background:
    radial-gradient(circle at top, rgba(87, 140, 255, 0.18), transparent 36%),
    linear-gradient(180deg, rgba(17, 21, 31, 0.35), rgba(2, 3, 4, 0.72));
  pointer-events: none;
}

.necall-video-closed,
.necall-remote-video-closed {
  position: absolute;
  inset: 0;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  text-align: center;
  color: #f7f8fb;
  font-size: 16px;
  font-weight: 600;
  background: #000;
  pointer-events: none;
}

.necall-in-call-duration {
  position: absolute;
  top: 20px;
  left: 50%;
  z-index: 4;
  transform: translateX(-50%);
  font-size: 16px;
  font-weight: 600;
}

.necall-switch-waiting-hint {
  position: absolute;
  top: 56px;
  left: 50%;
  z-index: 4;
  transform: translateX(-50%);
  max-width: calc(100% - 28px);
  padding: 6px 14px;
  border-radius: 999px;
  background: rgba(17, 21, 31, 0.72);
  backdrop-filter: blur(8px);
  color: rgba(247, 248, 251, 0.92);
  font-size: 13px;
  font-weight: 500;
  white-space: nowrap;
  pointer-events: none;
}

.necall-in-call-audio .necall-switch-waiting-hint {
  top: -44px;
}

.necall-in-call-btn-group {
  position: absolute;
  bottom: 38px;
  left: 50%;
  z-index: 4;
  display: flex;
  width: auto;
  min-height: 60px;
  max-width: calc(100% - 28px);
  padding: 10px 18px;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transform: translateX(-50%);
  border-radius: 999px;
  background: linear-gradient(180deg, rgba(57, 57, 71, 0.92), rgba(41, 41, 51, 0.95));
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

.necall-control-icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  padding: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
  line-height: 0;
}

.necall-control-icon-button:focus-visible {
  outline: 2px solid rgba(255, 255, 255, 0.78);
  outline-offset: 2px;
  border-radius: 999px;
}

.necall-in-call-btn-group .necall-control-icon-button.danger {
  width: 40px;
  height: 40px;
}

.necall-control-icon-image {
  display: block;
  width: 24px;
  height: 24px;
  object-fit: contain;
  pointer-events: none;
  user-select: none;
}

.necall-control-icon-image-hangup {
  width: 36px;
  height: 36px;
}

.necall-control-icon-button.secondary .necall-control-icon-image {
  width: 24px;
  height: 24px;
}

.necall-control-with-menu {
  display: inline-flex;
  align-items: center;
  gap: 0;
  flex-shrink: 0;
}

.necall-device-menu {
  position: relative;
}

.necall-device-menu-trigger {
  width: 18px;
  min-width: 18px;
  margin-left: -6px;
  padding: 0;
  line-height: 1;
  list-style: none;
}

.necall-device-menu-trigger::-webkit-details-marker {
  display: none;
}

.necall-device-menu-trigger::marker {
  content: '';
}

.necall-device-menu-arrow {
  display: block;
  width: 12px;
  height: 12px;
  color: rgba(255, 255, 255, 0.72);
  transition: transform 160ms ease, color 160ms ease;
}

.necall-device-menu[open] .necall-device-menu-trigger {
  background: rgba(255, 255, 255, 0.08);
}

.necall-device-menu[open] .necall-device-menu-arrow {
  transform: rotate(180deg);
  color: #ffffff;
}

.necall-device-menu-panel {
  position: absolute;
  bottom: calc(100% + 12px);
  left: 50%;
  z-index: 2;
  width: 220px;
  max-width: min(220px, calc(100vw - 48px));
  max-height: 260px;
  overflow: auto;
  padding: 12px;
  transform: translateX(-50%);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 18px;
  background: rgba(23, 27, 38, 0.96);
  box-shadow: 0 18px 48px rgba(0, 0, 0, 0.32);
}

.necall-device-menu-section + .necall-device-menu-section {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.necall-device-menu-section-title {
  margin-bottom: 8px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
}

.necall-device-menu-item {
  display: flex;
  width: 100%;
  padding: 8px 10px;
  align-items: center;
  justify-content: space-between;
  border: 0;
  border-radius: 12px;
  background: transparent;
  color: #ffffff;
  cursor: pointer;
  text-align: left;
}

.necall-device-menu-item:hover,
.necall-device-menu-item:focus-visible,
.necall-device-menu-item[data-selected='true'] {
  background: rgba(79, 140, 255, 0.22);
  outline: none;
}

.necall-device-menu-item-label {
  font-size: 13px;
}

.necall-device-menu-item-state {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.68);
}

@media (max-width: 640px) {
  .necall-view {
    top: 8px;
    width: calc(100vw - 16px);
    height: calc(100vh - 16px);
  }

  .necall-callee-info {
    width: calc(100% - 32px);
  }

  .necall-callee-nickname,
  .necall-caller-nickname,
  .necall-in-call-title {
    font-size: 20px;
  }

  .necall-in-call-btn-group {
    max-width: calc(100% - 24px);
    padding: 10px 12px;
    gap: 6px;
  }
}
`;

module.exports = {
  CALL_VIEW_STYLE_TEXT,
};
