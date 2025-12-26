import { SELECTCOLOR } from './BeautyConstants';
import { BeautyShapeModel } from './models/BeautyShapeModel';
import { CustomDialogCancelOrConfirm } from './common/CustomDialog';
import { BeautyDataService } from './services/BeautyDataService';

@Component
export struct BeautyShapeView {
  private dialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    width: '80%',
    height: '140vp',
    builder: CustomDialogCancelOrConfirm({
      title: '是否将所有参数恢复到\n默认值？',
      confirm: () => {
        this.onAccept()
      },
    }),
  })
  private viewModel = BeautyDataService.sharedInstance().shapeViewModel;
  private dataArray: BeautyShapeModel[] = this.viewModel.dataArray;
  @State gridCurrentIndex: number = 0;
  @State defaultValueInMiddle: boolean = false;
  @State sliderValue: number =
    this.defaultValueInMiddle ? (this.dataArray[this.gridCurrentIndex].currentValue * 100.0 - 50) :
      (this.dataArray[this.gridCurrentIndex].currentValue * 100.0);
  @State sliderString: string = this.sliderValue.toString();
  @State needToReset: boolean = true;

  build() {
    Column() {
      Stack({
        alignContent: Alignment.Center
      }) {
        if (this.defaultValueInMiddle) {
          Divider()
            .backgroundColor(Color.White)
            .width(2)
            .height(10)
        }
        Slider({
          value: this.sliderValue,
          min: this.defaultValueInMiddle ? -50 : 0,
          max: this.defaultValueInMiddle ? 50 : 100,
          step: 1,
          style: SliderStyle.OutSet,
          direction: Axis.Horizontal,
          reverse: false
        })
          .width(260)
          .height(40)
          .trackThickness(1)
          .blockSize({ width: 13, height: 13 })
          .blockStyle({ type: SliderBlockType.SHAPE, shape: new Rect({ width: 13, height: 13 }) })
          .blockColor('#5EC7FE')// 设置滑块颜色
          .trackColor(Color.White)// 设置滑轨颜色
          .selectedColor(this.defaultValueInMiddle ? Color.White : '#5EC7FE')// 设置滑轨的已滑动颜色
          .showTips(true, this.sliderString)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (!this.needToReset) {
              this.needToReset = true;
            }
            this.sliderValue = value;
            // this.sliderString = FUNMNumberUtil.formatNumber(value, 0, true);
            const model = this.dataArray[this.gridCurrentIndex];
            const shapeValue = this.defaultValueInMiddle ? ((value + 50) / 100.0) : value / 100.0
            this.viewModel.setShapeValue(model, shapeValue);
          })
      }

      Row() {
        Image($r('app.media.recover_item'))
          .width(50)
          .height(50)
          .margin({ left: 16 })
          .onClick(() => {
            this.dialogController.open();
          })

        Divider()
          .vertical(true)
          .color(Color.Gray)
          .strokeWidth(1)
          .height(40)
          .margin({ left: 15 })

        Grid() {
          ForEach(this.dataArray, (model: BeautyShapeModel, index: number) => {
            GridItemBuilder({
              gridCurrentIndex: this.gridCurrentIndex,
              sliderValue: this.sliderValue,
              sliderString: this.sliderString,
              defaultValueInMiddle: this.defaultValueInMiddle,
              index: index,
              model: model,
              needToReset: this.needToReset
            })
          }, (model: BeautyShapeModel): string => model.name)
        }
        .rowsTemplate('1fr')
        .margin({ left: 10 })
        .width('75%')
        .height(80)
      }
      .margin({ top: 20 })
      .width('100%')
      .height(40)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1F1D35')
  }

  private onAccept() {
    this.viewModel.recoverAllShapeValuesToDefault();
    const model = this.dataArray[this.gridCurrentIndex];
    this.sliderValue = this.defaultValueInMiddle ? (model.defaultValue * 100.0 - 50) : (model.defaultValue * 100.0);
    if (this.needToReset) {
      this.needToReset = false;
    }
  }
}

@Component
struct GridItemBuilder {
  @Link gridCurrentIndex: number
  @Link sliderValue: number
  @Link sliderString: string
  @Link defaultValueInMiddle: boolean;
  @Link needToReset: boolean;
  index: number = 0;
  model: BeautyShapeModel | undefined = undefined;

  build() {
    GridItem() {
      Column() {
        Image(this.getImageName())
          .width(50)
          .height(50)
        Text(this.model?.name)
          .fontColor(this.getTextColor())
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .margin({ top: 3 })
      }
    }
    .width(67)
    .height(80)
    .selected(this.gridCurrentIndex === this.index)
    .onClick(() => {
      this.gridCurrentIndex = this.index;
      if (this.model) {
        this.defaultValueInMiddle = this.model.defaultValueInMiddle;
        this.sliderValue =
          this.defaultValueInMiddle ? (this.model.currentValue * 100.0 - 50) : (this.model.currentValue * 100.0);
        // this.sliderString = FUNMNumberUtil.formatNumber(this.sliderValue, 0, true);
      }
      if (!this.needToReset) {
        this.needToReset = true;
      }
    })
  }

  private getImageName(): Resource {
    let imaName = '';
    if (this.gridCurrentIndex === this.index) {
      imaName = this.sliderValue !== 0 ? `${this.model?.imeName}_3` : `${this.model?.imeName}_2`;
    } else {
      imaName =
        (this.model?.defaultValueInMiddle ? ((this.model?.currentValue ?? 0) * 100.0 - 50 !== 0) :
          (this.model?.currentValue !== 0)) ?
          `${this.model?.imeName}_1` : `${this.model?.imeName}_0`;
    }

    if (!this.needToReset) {
      return $r(`app.media.${imaName}`);
    }

    return $r(`app.media.${imaName}`);
  }

  private getTextColor(): ResourceColor {
    return this.gridCurrentIndex === this.index ? SELECTCOLOR : Color.White;
  }
}