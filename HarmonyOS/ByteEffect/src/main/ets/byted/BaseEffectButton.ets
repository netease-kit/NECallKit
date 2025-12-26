import { ButtonShowController, EffectButtonItem } from './modeldatas/EffectButtonItem'
import { Decimal } from '@kit.ArkTS'

@Component
export struct BaseEffectButton {

  @ObjectLink controller: ButtonShowController
  private unSelectFilter: number[] = [0.6, 0, 0, 0, 0,
                                    0, 0.6, 0, 0, 0,
                                    0, 0, 0.6, 0, 0,
                                    0, 0, 0, 1, 0]
  private selectFilter: number[] = [1, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0,
                                    0, 0, 1, 0, 0,
                                    0, 0, 0, 1, 0]

  onClickEffectButton:((buttonItem: EffectButtonItem)=> void) | undefined

  private equalFloat(num1: number, num2: number): boolean{
    return new Decimal(num1 - num2).abs().toNumber() < 0.01
  }

  build() {
    Button({
      type: ButtonType.Normal,
      stateEffect: true
    }){
      Column() {
        Image($r(this.controller.buttonItem?.getMaterial()?.icon))
          .width(this.controller.isStickerOrComposer() ? 50 : 30)
          .height(this.controller.isStickerOrComposer() ? 50 : 30)
          .margin({ bottom: 3 })
          .colorFilter(this.controller.isHighLight || this.controller.isStickerOrComposer() ? this.selectFilter : this.unSelectFilter)
          .borderWidth(2)
          .borderColor(this.controller.isStickerOrComposer() && this.controller.isHighLight ? 'rgb(255, 255, 255)' : Color.Transparent)

        Text(this.controller.buttonItem?.getMaterial()?.title).fontSize(10).fontColor(this.controller.isHighLight ? 'rgb(255, 255, 255)' : 'rgb(204, 204, 204)')

        Circle({ width: 4, height: 4 }).margin({ top: 8}).fill(this.controller.isPointOn ? '#30D8D8' : Color.Transparent)
      }.alignItems(HorizontalAlign.Center)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
    .width(60)
    .height(60)

    .onClick(() =>{
      this.controller.buttonItem?.setSelected(true)
      this.controller.parentItem!.setSelectChild(this.controller.buttonItem)
      if (this.onClickEffectButton) {
        this.onClickEffectButton(this.controller.buttonItem)
      }

    })
  }
}