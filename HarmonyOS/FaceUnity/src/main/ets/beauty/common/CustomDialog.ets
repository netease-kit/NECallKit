import { SELECTCOLOR } from '../BeautyConstants'

@CustomDialog
export struct CustomDialogCancelOrConfirm {
  title: string = ''
  controller: CustomDialogController
  cancel?: () => void
  confirm?: () => void

  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .margin(20)
      Divider().vertical(false).strokeWidth(1).width('100%')
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        Button('取消')
          .fontSize(18)
          .onClick(() => {
            this.controller.close()
            if (this.cancel) {
              this.cancel()
            }
          })
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Black)
        Divider().vertical(true).strokeWidth(1).height('100%')
        Button('确定')
          .fontSize(18)
          .onClick(() => {
            this.controller.close()
            if (this.confirm) {
              this.confirm()
            }
          })
          .backgroundColor(Color.Transparent)
          .fontColor(SELECTCOLOR)
      }
      .width('100%')
      .height(50)
    }
  }
}