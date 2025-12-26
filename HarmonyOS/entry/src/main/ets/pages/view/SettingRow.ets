// 正确结构示例
@Component
export struct SettingRow {
  label: string = "";

  @BuilderParam    // 关键装饰器
  content: () => void;  // 正确声明UI构建函数类型

  build() { // 必须使用build方法
    Row() {
      Text(this.label)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Start)

      this.content()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}