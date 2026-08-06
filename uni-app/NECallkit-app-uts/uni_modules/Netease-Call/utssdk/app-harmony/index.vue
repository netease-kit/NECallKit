<template>
  <embed
    tag="necall-page"
    class="defaultStyles"
    :options="nativeOptions"
    @accept="onAccept"
    @reject="onReject"
    @hangup="onHangup"
    @microphonetoggle="onMicrophoneToggle"
    @cameratoggle="onCameraToggle"
    @speakertoggle="onSpeakerToggle"
    @switchcamera="onSwitchCamera"
    @switchaudio="onSwitchAudio"
    @switchvideo="onSwitchVideo"
    @floatingwindow="onFloatingWindow"
  ></embed>
</template>

<script lang="uts">
export default {
  name: 'call-view',
  emits: [
    'accept',
    'reject',
    'hangup',
    'microphonetoggle',
    'cameratoggle',
    'speakertoggle',
    'switchcamera',
    'switchaudio',
    'switchvideo',
    'floatingwindow'
  ],
  props: {
    callStatus: { type: String, default: 'idle' },
    callRole: { type: String, default: 'unknown' },
    mediaType: { type: Number, default: 0 },
    callDuration: { type: String, default: '00:00' },
    isGroupCall: { type: Boolean, default: false },
    isLocalMicOpen: { type: Boolean, default: true },
    isLocalCameraOpen: { type: Boolean, default: true },
    isSpeakerphoneOn: { type: Boolean, default: false },
    enableFloatingWindow: { type: Boolean, default: true },
    supportAudioToVideo: { type: Boolean, default: true },
    supportVideoToAudio: { type: Boolean, default: true },
    microphoneText: { type: String, default: '' },
    speakerText: { type: String, default: '' },
    hangupText: { type: String, default: '' },
    acceptText: { type: String, default: '' },
    rejectText: { type: String, default: '' }
  },
  computed: {
    nativeOptions() {
      return {
        callStatus: this.callStatus,
        callRole: this.callRole,
        mediaType: this.mediaType,
        callDuration: this.callDuration,
        isGroupCall: this.isGroupCall,
        isLocalMicOpen: this.isLocalMicOpen,
        isLocalCameraOpen: this.isLocalCameraOpen,
        isSpeakerphoneOn: this.isSpeakerphoneOn,
        enableFloatingWindow: this.enableFloatingWindow,
        supportAudioToVideo: this.supportAudioToVideo,
        supportVideoToAudio: this.supportVideoToAudio,
        microphoneText: this.microphoneText,
        speakerText: this.speakerText,
        hangupText: this.hangupText,
        acceptText: this.acceptText,
        rejectText: this.rejectText
      };
    }
  },
  methods: {
    onAccept(event) { this.$emit('accept', event); },
    onReject(event) { this.$emit('reject', event); },
    onHangup(event) { this.$emit('hangup', event); },
    onMicrophoneToggle(event) { this.$emit('microphonetoggle', event); },
    onCameraToggle(event) { this.$emit('cameratoggle', event); },
    onSpeakerToggle(event) { this.$emit('speakertoggle', event); },
    onSwitchCamera(event) { this.$emit('switchcamera', event); },
    onSwitchAudio(event) { this.$emit('switchaudio', event); },
    onSwitchVideo(event) { this.$emit('switchvideo', event); },
    onFloatingWindow(event) { this.$emit('floatingwindow', event); }
  }
}
</script>

<style>
.defaultStyles {
  width: 100%;
  height: 100%;
  background-color: transparent;
}
</style>
