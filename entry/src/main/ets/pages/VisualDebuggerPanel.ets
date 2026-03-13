/**
 * Date: 2026/3/12
 * File Name: VisualDebuggerPanel.ets
 * Author: Jason
 * Description:探针主面板容器 - 支持变量绑定与 UI 元素审查
 **/

import { StateVisualizerNode, AnyValue } from './StateVisualizerNode';
import { DebugManager } from './DebugManager';
import { UIInspector } from './UIInspector';
import { DebugWindowManager } from './DebugWindowManager'; // 💥 新增：引入窗口管理器来关闭悬浮窗
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct VisualDebuggerPanel {
  @Local inputKey: string = '';
  @Local currentBoundData: ESObject = undefined;
  @Local currentUpdater: ((newVal: ESObject) => void) | undefined = undefined;
  @Local inspectMode: boolean = false;

  aboutToAppear() {
    // 监听：只要有控件被选中了
    UIInspector.onComponentSelected = () => {
      if (this.inspectMode) {
        let config = DebugManager.getBinding("selectedUI");
        if (config) {
          this.currentBoundData = config.data;
          this.currentUpdater = config.updater;
        }
      }
    }
  }

  build() {
    Column() {
      // ==========================================
      // 1. 顶部控制栏：审查开关、变量绑定与关闭按钮
      // ==========================================
      Row({ space: 8 }) {
        // 🔍 UI 审查模式切换按钮
        Button(this.inspectMode ? "🛑 退出审查" : "🔍 审查 UI")
          .backgroundColor(this.inspectMode ? '#FF4444' : '#3E75D8')
          .fontSize(13)
          .height(32)
          .onClick(() => {
            UIInspector.toggleMode();
            this.inspectMode = UIInspector.isInspectMode;

            if (this.inspectMode) {
              this.inputKey = "selectedUI";
              promptAction.showToast({ message: "请在上方点击你要调试的组件" });
            } else {
              this.inputKey = "";
              this.currentBoundData = undefined;
              this.currentUpdater = undefined;
            }
          })

        // 变量名称输入框
        TextInput({ placeholder: '输入变量名 (如: newsList)', text: this.inputKey })
          .layoutWeight(1) // 撑开中间，把右边的按钮挤到最右侧
          .height(32)
          .fontSize(13)
          .backgroundColor('#F0F0F0')
          .onChange((val) => { this.inputKey = val; })

        // 绑定数据按钮
        Button("绑定")
          .height(32)
          .fontSize(13)
          .backgroundColor('#333333')
          .onClick(() => {
            if (!this.inputKey) {
              promptAction.showToast({ message: "请输入变量名称" });
              return;
            }

            let config = DebugManager.getBinding(this.inputKey);
            if (config) {
              this.currentBoundData = config.data;
              this.currentUpdater = config.updater;
              promptAction.showToast({ message: `成功绑定数据: ${this.inputKey}` });
            } else {
              this.currentBoundData = undefined;
              this.currentUpdater = undefined;
              promptAction.showToast({ message: `未找到变量: ${this.inputKey}` });
            }
          })

        // 💥 新增：关闭悬浮窗按钮
        Text("关闭")
          .width(32)
          .height(32)
          .fontSize(16)
          .fontColor('#999999')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 安全起见，如果正在审查模式，先退出审查，防止红框残留
            if (this.inspectMode) {
              UIInspector.toggleMode();
              this.inspectMode = false;
            }
            // 销毁并隐藏悬浮窗
            DebugWindowManager.hideDebugger();
          })
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#FFFFFF')

      Divider().color('#E0E0E0')

      // ==========================================
      // 2. 核心渲染区：递归展示 JSON 树结构
      // ==========================================
      if (this.currentBoundData !== undefined) {
        Scroll() {
          Column() {
            ForEach(Object.keys(this.currentBoundData as object), (key: string) => {
              StateVisualizerNode({
                keyName: key,
                value: (this.currentBoundData as ESObject)[key],
                onValueChange: (k: string, v: AnyValue) => {
                  let oldDynamic: ESObject = this.currentBoundData;
                  let newData: ESObject = Array.isArray(oldDynamic) ? [] : {};
                  let keys = Object.keys(oldDynamic as object);

                  for (let i = 0; i < keys.length; i++) {
                    newData[keys[i]] = oldDynamic[keys[i]];
                  }

                  newData[k] = v;
                  this.currentBoundData = newData;

                  if (this.currentUpdater) {
                    this.currentUpdater(newData);
                  }
                }
              })
            }, (key: string) => key)
          }
          .padding(12)
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
      } else {
        Column() {
          Text("暂无数据")
            .fontColor('#999999')
            .fontSize(16)
            .margin({ top: 40 })

          Text(`当前后台托管的可用变量:\n${DebugManager.getAvailableKeys().join(' , ') || '无'}`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 20 })
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}