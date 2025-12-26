import { BaseEffectButton } from './BaseEffectButton'
import { ColorBar, ColorBarController, ColorBarCreaterParams} from './ColorBar'
import { EffectManagerData } from './manager/EffectManagerData'
import { EffectButtonItem, FilterButtonItem } from './modeldatas/EffectButtonItem'
import { ComposerNode } from './modeldatas/ComposerNode'
import { ComponentContent, promptAction } from "@kit.ArkUI"
import { BaseEffectBar } from './BaseEffectBar'

@Observed
export class TabItem {
  public  title : string = ""
  public id : number = 0
  public groupItem : EffectButtonItem
  constructor(title: string, id: number, groupItem: EffectButtonItem) {
    this.title = title
    this.id = id
    this.groupItem = groupItem
  }
}

@Observed
export class EffectTabsController {
  vCurTabItems: TabItem[] = []
  vShowRootTabs: boolean = true
  curChildItem: EffectButtonItem | null = null
  curFilterItem: FilterButtonItem | null = null

  //Slider
  vSliderValue:number = 0.0
  vSliderStart:number = 0
  vSliderEnd:number = 100
  vSliderVisible: boolean = true
  //colorBar
  colorTabBar: ComponentContent<ColorBarCreaterParams> | null = null
  selectNodes: Set<ComposerNode>
  updateComposerNodesCallback:((nodes:Set<ComposerNode>)=>void) | undefined
  updateComposerNodesIntensityCallback:((nodes:Set<ComposerNode>)=>void) | undefined

  constructor(updateComposerNodesCallback:((nodes: Set<ComposerNode>)=>void) | undefined, updateComposerNodesIntensityCallback: ((nodes:Set<ComposerNode>)=>void) | undefined) {
    this.selectNodes = new Set<ComposerNode>()
    this.updateComposerNodesCallback = updateComposerNodesCallback
    this.updateComposerNodesIntensityCallback = updateComposerNodesIntensityCallback
  }

  onColorChangeCallback() {
    this.updateComposerNodesIntensityCallback?.(this.selectNodes)
  }

  getScrollIndex(item: EffectButtonItem): number {
    if (item.hasChildren()) {
      for (let i = 0; i < item.getChildren().length; i++) {
        if (item.getChildren()[i].getMaterial().title == item.getSelectChild()?.getMaterial().title) {
          //尽量居中
          if (i < 3)
            return 0

          return i - 3
        }
      }
    }
    return 0
  }

  goBack(): void {
    this.colorTabBar = null
    let curTabGroupItem = this.vCurTabItems[0].groupItem
    if (curTabGroupItem.getParent() && curTabGroupItem.getParent()!.getParent() == null) {
      //to root
      this.vShowRootTabs = true
    } else if (curTabGroupItem.getParent()) {
      //to parent
      this.vCurTabItems = [new TabItem(curTabGroupItem.getParent()!.getMaterial().title, curTabGroupItem.getParent()!.getId(), curTabGroupItem.getParent()!)]
    }
  }

  intoChildTabs(childTabItem: EffectButtonItem, uiContext: UIContext) {
    this.vCurTabItems = [new TabItem(childTabItem.getMaterial().title, childTabItem.getId(), childTabItem)]
    this.vShowRootTabs = false
    //colorbar
    if (childTabItem.getColorItems().length > 0) {
      this.colorTabBar = new ComponentContent<ColorBarCreaterParams>(
        uiContext,
        wrapBuilder(buildColorCircle),
        new ColorBarCreaterParams(childTabItem, this.onColorChangeCallback.bind(this))
      )
    } else {
      this.colorTabBar = null
    }
  }

  removeAllNode(buttonItem: EffectButtonItem): boolean {
    let bRemove = false
    for (let item of buttonItem.getChildren()) {
      if (item.hasChildren()) {
        bRemove = this.removeAllNode(item) || bRemove
      }

      if (this.selectNodes.has(item.getNode())) {
        this.selectNodes.delete(item.getNode())
        bRemove = true
      }
    }

    return bRemove
  }

  childItemSelect(childItem: EffectButtonItem) {
    this.vSliderVisible = childItem.getNode().keyArray.length > 0
    childItem.mController?.updatePointOn()
    this.curChildItem = childItem
    if (childItem.getEnableNegative()) {
      this.vSliderStart = -50
      this.vSliderEnd = 50
    } else {
      this.vSliderStart = 0
      this.vSliderEnd = 100
    }

    this.vSliderValue = this.vSliderStart + childItem.getIntensityArray()[0] * (this.vSliderEnd - this.vSliderStart)
    let bNodeChange = false
    if (childItem.getParent() && childItem.getParent()!.isEnableMultiSelect() == false){
      bNodeChange = this.removeAllNode(childItem.getParent()!)
    }

    if (!this.selectNodes.has(childItem.getNode())) {
      this.selectNodes.add(childItem.getNode())
      bNodeChange = true
    }
    if (bNodeChange) {
      this.updateComposerNodesCallback?.(this.selectNodes)
      this.updateComposerNodesIntensityCallback?.(this.selectNodes)
    }

    if (childItem.getMaterial().desc.length > 0) {
      promptAction.showToast({
        message: childItem.getMaterial().desc
      })
    }
  }

  filterSelect(filterItem: FilterButtonItem) {
    filterItem.mController?.updatePointOn()
    this.curChildItem = filterItem

    this.vSliderStart = 0
    this.vSliderEnd = 100

    this.curFilterItem = filterItem
    this.vSliderValue = this.vSliderStart + filterItem.getIntensityArray()[0] * (this.vSliderEnd - this.vSliderStart)
    this.vSliderVisible = filterItem.getNode().keyArray.length > 0

    let bNodeChange = false
    if (filterItem.getParent() && filterItem.getParent()!.isEnableMultiSelect() == false){
      bNodeChange = this.removeAllNode(filterItem.getParent()!)
    }

    if (!this.selectNodes.has(filterItem.getNode())) {
      this.selectNodes.add(filterItem.getNode())
      bNodeChange = true
    }
    if (bNodeChange) {
      this.updateComposerNodesCallback?.(this.selectNodes)
      this.updateComposerNodesIntensityCallback?.(this.selectNodes)
    }
  }

  closeFilter(closeItem: FilterButtonItem) {
    this.closeItem(closeItem)
  }

  closeItem(closeItem: EffectButtonItem) {
    this.curChildItem = null
    closeItem.getParent()?.mController?.closeAllIntensity()
    this.vSliderValue = 0
    if (closeItem.getParent()) {
      if (this.removeAllNode(closeItem.getParent()!)) {
        this.updateComposerNodesCallback?.(this.selectNodes)
        this.updateComposerNodesIntensityCallback?.(this.selectNodes)
      }
    }

  }

  sliderValueChange(value: number, mode: SliderChangeMode) {
    let curIntensity = (value - this.vSliderStart) / (this.vSliderEnd - this.vSliderStart)
    if (this.curChildItem instanceof FilterButtonItem) {//滤镜
      this.curChildItem.setIntensityArray([curIntensity])
    } else {
      if (this.curChildItem && this.curChildItem.getNode()) {
        let intensityArray : number[] = [];
        for (let i = 0; i < this.curChildItem.getNode().keyArray.length; i++) {
          intensityArray.push(curIntensity)
        }
        this.curChildItem.setIntensityArray(intensityArray)
      }
    }
    if (this.curChildItem && this.curChildItem.getNode() && this.curChildItem.hasIntensity() && !this.selectNodes.has(this.curChildItem.getNode())) {
      this.selectNodes.add(this.curChildItem.getNode())
    }
    this.vSliderValue = value
    this.updateComposerNodesIntensityCallback?.(this.selectNodes)
  }
}

@Builder
function buildColorCircle(params: ColorBarCreaterParams) {
  ColorBar({controller: new ColorBarController(params.groupItem, params.colorItemChangeCallBack)})
    .width(params.groupItem.getColorItems().length > 3 ? '80%' : '50%')
}

@Component
export struct BaseEffectTabs {
  @ObjectLink mController: EffectTabsController
  @Link showMenu:boolean
  onButtonClick:((name: string) => void) | undefined
  onButtonPress:(() => void) | undefined
  onButtonPressFinish:(() => void) | undefined

  scroller: Scroller = new Scroller()
  vCurTabIndex: number = 0
  public tabsItems: TabItem[] = [];
  public tabHeight: number = 210
  private sliderHeight: number = 30

  onClickEffectButton(item: EffectButtonItem) {
    if (item.hasChildren()) {
      this.mController.intoChildTabs(item, this.getUIContext())
    } else {
      if (item?.getId() != EffectManagerData.TYPE_CLOSE) {
        if (item instanceof FilterButtonItem) {
          this.mController.filterSelect(item)
        } else {
          this.mController.childItemSelect(item)
        }
      } else {
        if (item instanceof FilterButtonItem) {
          this.mController.closeFilter(item)
        }else {
          this.mController.closeItem(item)
        }
      }
    }
  }

  @Builder
  tabsBuilderGroup() {
      Tabs({ barPosition: BarPosition.Start}) {
        ForEach(this.mController.vCurTabItems, (item: TabItem) => {
          this.tabContentBuilder(item)
        }, (item: TabItem) => item.title)
      }.vertical(false).barMode(BarMode.Scrollable).barHeight('25%').scrollable(false).margin({ bottom: 40 })
  }

  @Builder
  tabsBuilderRoot() {
    Tabs({ barPosition: BarPosition.Start, index: this.vCurTabIndex}) {
        ForEach(this.tabsItems, (item: TabItem) => {
          this.tabContentBuilder(item)
        },  (item: TabItem) => item.title)
    }
    .vertical(false).barMode(BarMode.Scrollable).barHeight('25%').scrollable(false).margin({ bottom: 40 })
    .onTabBarClick((index: number) => {
      this.vCurTabIndex = index
    })
  }

  @Builder
  tabContentBuilder(tabItem: TabItem) {
    TabContent() {
        //根据子节点个数进行不同的布局策略
        if (tabItem.groupItem.getChildren().length > 5) {
          List({initialIndex: this.mController.getScrollIndex(tabItem.groupItem)}){
            ForEach(tabItem.groupItem.getChildren(), (item: EffectButtonItem) => {
              ListItem() {
                BaseEffectButton({
                  controller: item.mController, onClickEffectButton: (item: EffectButtonItem) => {
                    this.onClickEffectButton(item)
                  }
                })
              }
            }, (item: EffectButtonItem) => item.getMaterial().title)
          }
          .alignListItem(ListItemAlign.Center)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        } else {
          Scroll(this.scroller) {
            Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              ForEach(tabItem.groupItem.getChildren(), (item: EffectButtonItem) => {
                BaseEffectButton({
                  controller: item.mController, onClickEffectButton: (item: EffectButtonItem) => {
                    this.onClickEffectButton(item)
                  }
                })
              }, (item: EffectButtonItem) => item.getMaterial().title)
            }.width('90%')
          }
          .enablePaging(true)
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .edgeEffect(EdgeEffect.Spring)
      }
    }
    .tabBar(SubTabBarStyle.of(this.mController.colorTabBar != null ? this.mController.colorTabBar : tabItem.title)
      .labelStyle({
        selectedColor: 'rgb(255, 255, 255)', unselectedColor: 'rgb(200, 200, 200)',
        heightAdaptivePolicy: TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST,
        minFontSize: 13, maxFontSize: 13
      })
      .padding({ top: 5, right: 15, left: 15, bottom: 1 })
      .indicator({ color: this.mController.colorTabBar != null ? Color.Transparent : 'rgb(255, 255, 255)', })
      .selectedMode(SelectedMode.INDICATOR)
    ).height('75%')
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (this.mController.curChildItem != null && this.mController.vSliderVisible) {
        Slider({ min: this.mController.vSliderStart, max: this.mController.vSliderEnd, direction: Axis.Horizontal, value: this.mController.vSliderValue })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.mController.sliderValueChange(value, mode)
          })
          .padding({ left: 10, right: 30, bottom: 5 }).height(this.sliderHeight).margin({ bottom: this.tabHeight - this.sliderHeight })
          .visibility(this.showMenu ? Visibility.Visible : Visibility.Hidden).showTips(true, this.mController.vSliderValue.toFixed())
      }

      Flex({direction: FlexDirection.Column}) {
        if (this.mController.vShowRootTabs)
          this.tabsBuilderRoot()
        else
          this.tabsBuilderGroup()
      }
      .height(this.tabHeight - this.sliderHeight)
      .borderRadius(10)
      .backgroundColor('rgba(20, 20, 20, 0.8)')
      .margin({bottom: 0})
      .visibility(this.showMenu ? Visibility.Visible : Visibility.Hidden)

      if (!this.mController.vShowRootTabs) {
        Button() { Image($r('app.media.ic_arrow_left')).width(25).height(25) }.backgroundColor(Color.Transparent).margin({ left: 15, bottom: this.tabHeight - this.sliderHeight - 36 })
        .onClick(() => {
          this.mController.goBack()
        })
        .visibility(this.showMenu ? Visibility.Visible : Visibility.Hidden)
      }

      BaseEffectBar({
        barHeight: 40,
        isDown: this.showMenu,
        onButtonClick: this.onButtonClick,
        onButtonPress: this.onButtonPress,
        onButtonPressFinish: this.onButtonPressFinish
      })
    }
    .height(this.tabHeight)
    .margin({bottom: 0})
  }
}