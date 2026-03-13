/**
 * Date: 2026/3/12
 * File Name: VisualDebuggerPanel.ets
 * Author: Jason
 * Description: 探针主面板
 **/
import { StateVisualizerNode, AnyValue } from './StateVisualizerNode';
import { DebugManager } from './DebugManager';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct VisualDebuggerPanel {
  // 面板内部维护的当前绑定名称和数据
  @Local inputKey: string = '';
  @Local currentBoundData: ESObject = undefined;
  @Local currentUpdater: ((newVal: ESObject) => void) | undefined = undefined;

  build() {
    Column() {
      // 1. 顶部栏：输入变量名并动态绑定
      Row({ space: 10 }) {
        TextInput({ placeholder: '输入绑定的数据名称 (如: newsList)', text: this.inputKey })
          .layoutWeight(1).height(32).fontSize(14).backgroundColor('#F0F0F0')
          .onChange((val) => { this.inputKey = val; })

        Button("绑定").height(32).fontSize(14).backgroundColor('#3E75D8')
          .onClick(() => {
            let config = DebugManager.getBinding(this.inputKey);
            if (config) {
              this.currentBoundData = config.data;
              this.currentUpdater = config.updater;
              promptAction.showToast({ message: `成功绑定数据: ${this.inputKey}` });
            } else {
              this.currentBoundData = undefined;
              promptAction.showToast({ message: `未找到变量: ${this.inputKey}` });
            }
          })
      }.width('100%').padding(10).backgroundColor('#FFFFFF')

      Divider().color('#E0E0E0')

      // 2. 核心渲染区
      if (this.currentBoundData !== undefined) {
        Scroll() {
          Column() {
            ForEach(Object.keys(this.currentBoundData as object), (key: string) => {
              StateVisualizerNode({
                keyName: key,
                value: (this.currentBoundData as ESObject)[key],
                onValueChange: (k: string, v: AnyValue) => {
                  // 原地突变与数据拷贝逻辑
                  let oldDynamic: ESObject = this.currentBoundData;
                  let newData: ESObject = Array.isArray(oldDynamic) ? [] : {};
                  let keys = Object.keys(oldDynamic as object);

                  for (let i = 0; i < keys.length; i++) {
                    newData[keys[i]] = oldDynamic[keys[i]];
                  }
                  newData[k] = v;

                  // 更新面板自身的显示
                  this.currentBoundData = newData;
                  // 💥 跨空打击：触发原页面的 UI 刷新！
                  if (this.currentUpdater) {
                    this.currentUpdater(newData);
                  }
                }
              })
            }, (key: string) => key)
          }.padding(12)
        }.layoutWeight(1)
      } else {
        Column() {
          Text("暂无数据").fontColor('#999').margin({ top: 40 })
          Text(`当前可用的变量:\n${DebugManager.getAvailableKeys().join('\n')}`)
            .fontSize(12).fontColor('#666').margin({ top: 20 }).textAlign(TextAlign.Center)
        }.layoutWeight(1).width('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    // 配合系统悬浮窗，圆角和阴影可以交由 Window 处理
  }
}