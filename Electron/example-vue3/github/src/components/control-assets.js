'use strict';

const path = require('path');
const { pathToFileURL } = require('url');

function createAsset(filename, variant = 'default') {
  return Object.freeze({
    filename,
    variant,
    src: pathToFileURL(path.resolve(__dirname, '../assets', filename)).href,
  });
}

const CONTROL_ASSETS = Object.freeze({
  audioEnabled: createAsset('microphone-open.png'),
  audioMuted: createAsset('microphone-close.png'),
  videoEnabled: createAsset('video-open.png'),
  videoDisabled: createAsset('video-close.png'),
  acceptAudio: createAsset('audio-accept.png', 'action'),
  acceptVideo: createAsset('video-accept.png', 'action'),
  switchAudio: createAsset('switch-audio.png'),
  switchVideo: createAsset('switch-video.png'),
  hangup: createAsset('hangup.png', 'hangup'),
});

function resolveControlAsset(name, options = {}) {
  switch (name) {
    case 'audio':
      return options.muted ? CONTROL_ASSETS.audioMuted : CONTROL_ASSETS.audioEnabled;
    case 'video':
      return options.disabled ? CONTROL_ASSETS.videoDisabled : CONTROL_ASSETS.videoEnabled;
    case 'accept-audio':
      return CONTROL_ASSETS.acceptAudio;
    case 'accept-video':
      return CONTROL_ASSETS.acceptVideo;
    case 'switch-audio':
      return CONTROL_ASSETS.switchAudio;
    case 'switch-video':
      return CONTROL_ASSETS.switchVideo;
    case 'hangup':
      return CONTROL_ASSETS.hangup;
    default:
      return null;
  }
}

module.exports = {
  resolveControlAsset,
};
