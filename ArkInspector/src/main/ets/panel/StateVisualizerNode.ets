/**
 * Date: 2026/3/12
 * File Name: StateVisualizerNode.ets
 * Author: Jason
 * Description: 动态解析内存对象，生成可视化交互树
 **/

export type AnyValue = object | string | number | boolean | undefined;

@ComponentV2
export struct StateVisualizerNode {
  @Param keyName: string = '';
  @Param value: AnyValue = undefined;

  @Event onValueChange: (key: string, newValue: AnyValue) => void = () => {};
  @Local isExpanded: boolean = false;

  build() {
    if (typeof this.value !== 'function') {
      Column() {
        Row() {
          if (typeof this.value === 'object' && this.value !== null) {
            // 如果是数组，展示为 [数组项] 的 UI 感觉会更好；如果是对象，展示为普通展开
            Text(this.isExpanded ? "▼ " : "▶ ").fontSize(12).fontColor('#666666').width(20)
              .onClick(() => { this.isExpanded = !this.isExpanded })
          } else {
            Text("").width(20)
          }

          // 遇到数组索引时，加上中括号显得更专业 (如 [0]: )
          Text((!Number.isNaN(Number(this.keyName)) ? `[${this.keyName}]` : this.keyName) + ": ")
            .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')

          if (typeof this.value === 'string') {
            TextInput({ text: this.value as string })
              .height(28).fontSize(13).layoutWeight(1).backgroundColor('#F0F0F0')
              .onChange((val) => { this.onValueChange(this.keyName, val) })
          } else if (typeof this.value === 'number') {
            TextInput({ text: String(this.value) }).type(InputType.Number)
              .height(28).fontSize(13).layoutWeight(1).backgroundColor('#F0F0F0')
              .onChange((val) => { this.onValueChange(this.keyName, Number(val)) })
          } else if (typeof this.value === 'boolean') {
            Toggle({ type: ToggleType.Switch, isOn: this.value as boolean })
              .onChange((isOn) => { this.onValueChange(this.keyName, isOn) })
          }
        }
        .width('100%').padding({ top: 4, bottom: 4 }).alignItems(VerticalAlign.Center)

        if (typeof this.value === 'object' && this.value !== null && this.isExpanded) {
          Column() {
            ForEach(Object.keys(this.value as object), (subKey: string) => {
              StateVisualizerNode({
                keyName: subKey,
                value: (this.value as ESObject)[subKey],
                onValueChange: (k: string, v: AnyValue) => {
                  // 💥 绝杀技：原地突变！绝对不破坏数组和 Class 的原有结构！
                  let currentObj: ESObject = this.value;
                  currentObj[k] = v;

                  // 直接把修改好的当前对象继续往上冒泡
                  this.onValueChange(this.keyName, currentObj);
                }
              })
            }, (subKey: string) => subKey)
          }.padding({ left: 16 }).border({ width: { left: 1 }, color: '#E0E0E0', style: BorderStyle.Dashed }).margin({ left: 6 })
        }
      }.alignItems(HorizontalAlign.Start)
    }
  }
}