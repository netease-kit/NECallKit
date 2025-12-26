import { SELECTCOLOR } from './BeautyConstants';
import { BeautyFilterModel } from './models/BeautyFilterModel';
import { BeautyDataService } from './services/BeautyDataService';

@Component
export struct BeautyFilterView {

  private viewModel = BeautyDataService.sharedInstance().filterViewModel;
  private dataArray: BeautyFilterModel[] = this.viewModel.dataArray;
  @State @Watch('gridCurrentIndexChanged') gridCurrentIndex: number = 0;
  @State sliderValue: number = this.dataArray[this.gridCurrentIndex].filterLevel * 100.0;
  @State sliderString: string = this.sliderValue.toString();
  @State sliderVisibility: Visibility = Visibility.Hidden;

  build() {
    Column() {
      Slider({
        value: this.sliderValue,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet,
        direction: Axis.Horizontal,
        reverse: false
      })
        .width(260)
        .height(40)
        .visibility(this.sliderVisibility)
        .trackThickness(1)
        .blockSize({ width: 13, height: 13 })
        .blockStyle({ type: SliderBlockType.SHAPE, shape: new Rect({ width: 13, height: 13 }) })
        .blockColor(SELECTCOLOR)// 设置滑块颜色
        .trackColor(Color.White)// 设置滑轨颜色
        .selectedColor(SELECTCOLOR)// 设置滑轨的已滑动颜色
        .showTips(true, this.sliderString)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderValue = value;
          // this.sliderString = FUNMNumberUtil.formatNumber(value, 0, true);
          const model = this.dataArray[this.gridCurrentIndex];
          this.viewModel.setFilterValue(model, value / 100.0);
        })

      Row() {
        Grid() {
          ForEach(this.dataArray, (model: BeautyFilterModel, index: number) => {
            GridItemBuilder({
              gridCurrentIndex: this.gridCurrentIndex,
              sliderValue: this.sliderValue,
              sliderString: this.sliderString,
              model: model,
              sliderVisibility: this.sliderVisibility,
              index: index
            })
          }, (model: BeautyFilterModel): string => model.filterName)
        }
        .rowsTemplate('1fr')
        .margin({ left: 10 })
        .width('100%')
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

  gridCurrentIndexChanged() {
    const model = this.dataArray[this.gridCurrentIndex];
    this.viewModel.setFilterValue(model, model.filterLevel);
  }
}

@Component
struct GridItemBuilder {
  @Link gridCurrentIndex: number;
  @Link sliderValue: number;
  @Link sliderString: string;
  @Link sliderVisibility: Visibility;
  index: number = 0;
  model: BeautyFilterModel | undefined = undefined;

  build() {
    GridItem() {
      Column() {
        Image($r(`app.media.${this.model?.filterName}`))
          .width(50)
          .height(50)
          .borderWidth(2)
          .borderColor(this.getBorderColor())
        Text(this.model?.filterName)
          .fontColor(this.getTextColor())
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .margin({ top: 3 })
      }
    }
    .width(67)
    .height(80)
    .onClick(() => {
      this.gridCurrentIndex = this.index;
      this.sliderValue = this.model?.filterLevel ? this.model?.filterLevel * 100.0 : 0;
      // this.sliderString = FUNMNumberUtil.formatNumber(this.sliderValue, 0, true);
      this.sliderVisibility = this.index == 0 ? Visibility.Hidden : Visibility.Visible;
    })
  }

  private getBorderColor(): ResourceColor {
    return this.gridCurrentIndex === this.index ? SELECTCOLOR : '#00000000';
  }

  private getTextColor(): ResourceColor {
    return this.gridCurrentIndex === this.index ? SELECTCOLOR : Color.White;
  }
}