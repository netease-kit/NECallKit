import { ArrayList, Decimal } from '@kit.ArkTS'
import {ComposerNode} from '../modeldatas/ComposerNode'

export class ColorItem {
  title : string = ""
  r : number = 0.0
  g : number = 0.0
  b : number = 0.0
  a : number = 1.0
  constructor(title : string, r : number, g: number, b: number, a?: number) {
    this.title = title
    this.r = r
    this.g = g
    this.b = b
    if (a != undefined)
      this.a = a
  }

  getRgbaColor(): string {
    let rgba = 'rgba('
    rgba += Number(this.r * 255).toFixed()
    rgba += ", " + Number(this.g * 255).toFixed()
    rgba += ", " + Number(this.b * 255).toFixed()
    rgba += ", " + Number(this.a).toFixed(2)
    rgba += ")"
    return rgba
  }

}

export class Material {
  public title : string = ""
  public tips : string = ""
  public desc : string = ""
  public icon: string = ""
  public url: String = ""
  public md5: String = ""
  public fileName: String = ""
  constructor(icon : string, title : string, desc?: string) {
    this.icon = icon
    this.title = title
    this.desc = desc ? desc : ""
  }
}

@Observed
export class ButtonShowController {
  isHighLight: boolean = false
  isPointOn: boolean = false
  buttonItem: EffectButtonItem
  parentItem: EffectButtonItem | null

  constructor(buttonItem: EffectButtonItem) {
    this.buttonItem = buttonItem
    this.buttonItem.mController = this
    this.parentItem = this.buttonItem.getParent()
  }

  isStickerOrComposer(): boolean
  {
    if (this.buttonItem instanceof FilterButtonItem || this.buttonItem instanceof StickerButtonItem)
      return true

    return false
  }

  closeAllIntensity(): void {
    this.buttonItem.setSelectColorIndex(0)
    this.buttonItem.setIntensityArray(this.buttonItem.getEnableNegative() ? [0.5] : [0])
    this.buttonItem.mController.isHighLight = false
    this.buttonItem.setSelected(false)
    for (let item of this.buttonItem.getChildren()) {
      item.mController?.closeAllIntensity()
    }
  }

  updateHighLight(): void {
    if (this.parentItem) {
        for (let item of this.parentItem.getChildren()) {
          item.mController!.isHighLight = item.getMaterial().title == this.parentItem.getSelectChild()?.getMaterial().title
        }
    }
  }

  updatePointOn(): void {
    this.isPointOn = this.isShouldPointOn()
    if (this.parentItem) {
      this.parentItem.mController?.updatePointOn()
    }
  }

  getParentController(): ButtonShowController | null {
    return this.parentItem? this.parentItem.mController : null
  }

  isShouldPointOn(): boolean {
    if (this.buttonItem?.hasChildren()) {
      let status = false;
      for (let item of this.buttonItem?.getChildren()) {
        if (item.mController == null)
          continue

        status = status || item.mController?.isShouldPointOn();
      }

      return status || this.buttonItem.isSelected() && this.buttonItem.hasIntensity()

    } else {
      return this.parentItem == null ? false : this.parentItem!.isEnableMultiSelect() && this.buttonItem.isSelected() && this.buttonItem.hasIntensity();
    }
  }
}

@Observed
export class EffectButtonItem {
  private id : number = 0
  private parent : EffectButtonItem | null
  private enableNegative : boolean = false
  private children : EffectButtonItem[] = []
  private selectChild : EffectButtonItem | null
  private colorItems : ArrayList<ColorItem>
  public selectColorIndex : number = 0
  private enableMultiSelect : boolean = true
  private reuseChildrenIntensity : boolean = true
  private selected : boolean = false
  private material : Material
  private node : ComposerNode
  public mController: ButtonShowController

  constructor(id : number, material : Material, node?: ComposerNode, enableMultiSelect?: boolean, enableNegative?: boolean, colorItems?: ArrayList<ColorItem>) {
    this.id = id
    this.material = material
    this.parent = null
    this.selectChild = null
    this.node = node ? node : new ComposerNode("")

    if (colorItems) {
      this.colorItems = colorItems
      if (!this.colorItems.isEmpty()) {
        this.setSelectColorIndex(0)
      }
    } else {
      this.colorItems = new ArrayList<ColorItem>()
    }

    if (enableMultiSelect != undefined)
      this.enableMultiSelect = enableMultiSelect

    if (enableNegative != undefined)
      this.enableNegative = enableNegative

    this.mController = new ButtonShowController(this)
  }

  getId(): number {
    return this.id
  }

  isSelected() : boolean {
    let childSelected = false;
    for (let child of this.getChildren()) {
      if (child.isSelected()) {
        childSelected = true;
      }
    }

    return this.selected || childSelected;
  }

  getChildren() : EffectButtonItem[] {
    return this.children;
  }

  setChildren(children: EffectButtonItem[]) : EffectButtonItem {
    this.children = children;
    this.updateChildren()
    return this
  }

  setMaterial(inMaterial : Material) : void {
    this.material = inMaterial
  }

  getMaterial() : Material {
    return this.material
  }

  getNode(): ComposerNode {
    return this.node
  }

  setNode(node: ComposerNode) {
    this.node = node
  }

  setSelected(selected : boolean) : EffectButtonItem {
    this.selected = selected;
    return this;
  }

  setParent(parent: EffectButtonItem | null) : void {
    this.parent = parent;
  }

  getParent() : EffectButtonItem | null {
    return this.parent;
  }

  setSelectChild(selectChild : EffectButtonItem | null) : void {
    if (!this.hasChildren())
      return

    if (this.enableMultiSelect == false) {
      let lastIntensity = this.selectChild?.getIntensityArray()
      this.selectChild?.mController.closeAllIntensity()
      this.selectChild?.setSelected(false)

      selectChild?.setSelected(true)
      if (lastIntensity && lastIntensity.length > 0) {
        selectChild?.setIntensityArray(lastIntensity)
      }
    }

    this.selectChild = selectChild;
    selectChild?.mController?.updateHighLight()
  }

  getSelectChild() : EffectButtonItem | null {
    return this.selectChild;
  }

  getIntensityArray(): number[] {
    if (this.hasChildren()) {
        return !this.isEnableMultiSelect() && this.selectChild? this.selectChild.getIntensityArray() : []
    }

    return this.node.intensityArray
  }

  getValidIntensity(): number[] {
    if (this.selectChild == null) {
      if (this.node.path === "") return [];
      return this.node.intensityArray;
    }
    return this.selectChild.getValidIntensity();
  }

  setIntensityArray(intensityArray: number[]): void{
    if (this.node.path === "") return;

    if (!this.colorItems.isEmpty()) {
      this.node.intensityArray = [
        intensityArray[0],
        this.colorItems[this.selectColorIndex].r,
        this.colorItems[this.selectColorIndex].g,
        this.colorItems[this.selectColorIndex].b
      ]
    } else {
      this.node.intensityArray = intensityArray
    }
    this.mController?.updatePointOn()
  }

  hasChildren(): boolean {
    return this.children != null && this.children.length > 0;
  }


  getAvailableItem(): EffectButtonItem | null {
    if (!this.hasChildren()) {
      return this.node.path === "" ? null : this;
    }
    return this.selectChild == null ? null : this.selectChild.getAvailableItem();
  }

  updateChildren(): void {
    for (let child of this.children) {
      child.parent = this;
      if (child.mController)
        child.mController.parentItem = this
    }
    this.selectChild = this.children.length > 0 ? this.children[0] : null
  }

  getColorItems(): ArrayList<ColorItem> {
    if (this.hasChildren()){
      for (let child of this.getChildren()){
        if (child.getColorItems() != undefined && child.getColorItems()!.length > 0) {
            return child.getColorItems();
        }
      }
    }
    return this.colorItems;
  }

  setColorItems(colorItems: ArrayList<ColorItem>): EffectButtonItem {
    this.colorItems = colorItems;
    return this;
  }

  equalFloat(num1: number, num2: number): boolean{
    return new Decimal(num1 - num2).abs().toNumber() < 0.01
  }

  getEnableNegative(): boolean{
    return this.enableNegative;
  }

  hasIntensity(): boolean {
    let self = false;
    if (this.getIntensityArray().length > 0) {
      let intensity = this.getIntensityArray()[0]
      if (this.enableNegative) {
        self = !this.equalFloat(intensity, 0.5)
      }else {
        self = intensity > 0;
      }
    }

    let child = false;
    for (let item of this.getChildren()) {
      // 染发没有强度，需要做下特判
      let nodeName = item.getNode().path.split("/")[0]
      if ((nodeName == "hair" || item.hasIntensity()) && item.selected) {
        child = true;
      }
    }
    return self || child;
  }

  public isEnableMultiSelect(): boolean {
    return this.enableMultiSelect
  }

  getSelectColorIndex(): number {
    return this.selectColorIndex;
  }

  setSelectColorIndex(selectColorIndex: number) {
    this.selectColorIndex = selectColorIndex;
    if (this.hasChildren()) {
      for (let item of this.getChildren()) {
        item.setSelectColorIndex(selectColorIndex)
      }
    } else {
      if (!this.colorItems.isEmpty()) {
        this.node.intensityArray = [
          this.node.intensityArray[0],
          this.colorItems[this.selectColorIndex].r,
          this.colorItems[this.selectColorIndex].g,
          this.colorItems[this.selectColorIndex].b
        ]
      }
    }
  }
}

export class FilterButtonItem extends EffectButtonItem{

  constructor(id: number, icon: string, title: string, resource?: string, intensity?: number){
    if (resource != undefined) {
      super(id, new Material(icon, title), new ComposerNode(resource, "Filter_ALL", intensity, "filter"))
    }
    else {
      super(id, new Material(icon, title))
    }
  }
}

export class StickerButtonItem extends EffectButtonItem {
  constructor(id : number, material : Material, node?: ComposerNode) {
    super(id, material, node, false, false)
  }
}