import { vibrator } from '@kit.SensorServiceKit'
import { BusinessError } from '@ohos.base'

@Component
export struct BaseEffectBar {
  @Link isDown: boolean
  public barHeight: number = 40
  onButtonClick:((name: string) => void) | undefined
  onButtonPress:(() => void) | undefined
  onButtonPressFinish:(() => void) | undefined

  private _triggerVibrate(callback: (()=> void) | undefined) {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.effect.hard',
      }, {
        id: 0,
        usage: 'touch'
      }, (error: BusinessError) => {
        if (error) {
          console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        }
        callback?.()
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Image($r('app.media.ic_arrow_up')).width(25).height(25).rotate({
          angle: this.isDown ? 180 : 0
        })
          .onClick(() => {
            this.isDown = !this.isDown
          })
        Image($r('app.media.ic_record')).width(30).height(30)
          .onClick(() => {
            this.onButtonClick?.("record")
          })
          .priorityGesture(
            LongPressGesture()
              .onAction((event: GestureEvent|undefined) => {
                this._triggerVibrate(this.onButtonPress)
              })
              .onActionEnd(()=> {
                this._triggerVibrate(this.onButtonPressFinish)
              })
          )
        Image($r('app.media.ic_image_default')).width(25).height(25)
          .onClick(() => {
            this.onButtonClick?.("restoreDefault")
          })
      }
      .margin({ left: '5', right: '5', top: '5', bottom: '5' })
    }
    .margin({ left: '5%', right: '5%', top: '5', bottom: '5' })
    .height(this.barHeight)
    .width('90%')
  }

}