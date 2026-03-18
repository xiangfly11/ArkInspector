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

          // ==========================================
          // 1. 字符串类型：普通输入框
          // ==========================================
          if (typeof this.value === 'string') {
            TextInput({ text: this.value as string })
              .height(28).fontSize(13).layoutWeight(1).backgroundColor('#F0F0F0')
              .onChange((val) => { this.onValueChange(this.keyName, val) })
          }
          // ==========================================
          // 💥 2. 数字类型：Slider + 迷你输入框！
          // ==========================================
          else if (typeof this.value === 'number') {
            Row({ space: 8 }) {
              // 丝滑滑动条
              Slider({
                value: this.value as number,
                min: 0,
                // 动态计算 Max 值：默认最大 100，如果初始值超过 100，则以初始值为基准，防止滑块溢出
                max: Math.max(100, this.value as number),
                step: 1,
                style: SliderStyle.OutSet
              })
                .layoutWeight(1) // 占满剩余空间
                .onChange((val: number, mode: SliderChangeMode) => {
                  this.onValueChange(this.keyName, val);
                })

              // 右侧保留精确控制的迷你输入框
              TextInput({ text: String(this.value) })
                .type(InputType.Number)
                .width(45) // 限制得很窄，只显示数字
                .height(28)
                .fontSize(12)
                .backgroundColor('#F0F0F0')
                .onChange((val) => {
                  let num = Number(val);
                  if (!Number.isNaN(num)) {
                    this.onValueChange(this.keyName, num);
                  }
                })
            }
            .layoutWeight(1) // 让包含 Slider 和 TextInput 的 Row 撑开
          }
          // ==========================================
          // 3. 布尔类型：Switch 开关
          // ==========================================
          else if (typeof this.value === 'boolean') {
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
                  // 原地突变，不破坏原有结构
                  let currentObj: ESObject = this.value;
                  currentObj[k] = v;
                  // 继续向上冒泡
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