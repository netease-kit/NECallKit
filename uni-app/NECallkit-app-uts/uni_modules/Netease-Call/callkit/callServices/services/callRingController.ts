import { NAME } from "../const/index";

const INCOMING_RING = "/static/audio/avchat_ring.mp3";
const OUTGOING_RING = "/static/audio/avchat_connecting.mp3";
const PEER_REJECT_RING = "/static/audio/avchat_peer_reject.mp3";
const PEER_BUSY_RING = "/static/audio/avchat_peer_busy.mp3";

export class CallRingController {
  private _loopAudioContext: any = null;
  private _effectAudioContext: any = null;

  public startIncomingRing(): void {
    this._startLoopRing(INCOMING_RING);
  }

  public startOutgoingRing(): void {
    this._startLoopRing(OUTGOING_RING);
  }

  public stopLoopRing(): void {
    if (this._loopAudioContext) {
      this._loopAudioContext.stop();
      this._loopAudioContext.destroy();
      this._loopAudioContext = null;
    }
  }

  public playPeerRejectRing(): void {
    this._playEffectRing(PEER_REJECT_RING);
  }

  public playPeerBusyRing(): void {
    this._playEffectRing(PEER_BUSY_RING);
  }

  public reset(): void {
    this.stopLoopRing();
    if (this._effectAudioContext) {
      this._effectAudioContext.stop();
      this._effectAudioContext.destroy();
      this._effectAudioContext = null;
    }
  }

  private _startLoopRing(src: string): void {
    this.stopLoopRing();
    console.log(`${NAME.PREFIX} CallRingController start loop ring: ${src}`);
    this._loopAudioContext = uni.createInnerAudioContext();
    this._loopAudioContext.loop = true;
    this._loopAudioContext.src = src;
    this._loopAudioContext.play();
  }

  private _playEffectRing(src: string): void {
    if (this._effectAudioContext) {
      this._effectAudioContext.stop();
      this._effectAudioContext.destroy();
      this._effectAudioContext = null;
    }
    console.log(`${NAME.PREFIX} CallRingController play effect ring: ${src}`);
    this._effectAudioContext = uni.createInnerAudioContext();
    this._effectAudioContext.loop = false;
    this._effectAudioContext.src = src;
    this._effectAudioContext.play();
  }
}
