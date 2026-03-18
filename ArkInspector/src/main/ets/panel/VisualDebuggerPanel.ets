/**
 * Date: 2026/3/12
 * File Name: VisualDebuggerPanel.ets
 * Author: Jason
 * Description:探针主面板容器 - 支持变量绑定与 UI 元素审查
 **/

import { StateVisualizerNode, AnyValue } from './StateVisualizerNode';
import { DebugManager } from '../core/DebugManager';
import { UIInspector } from '../core/UIInspector';
import { DebugWindowManager } from '../core/DebugWindowManager';
import { promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';

@ComponentV2
export struct VisualDebuggerPanel {
  @Local inputKey: string = '';
  @Local currentBoundData: ESObject = undefined;
  @Local currentUpdater: ((newVal: ESObject) => void) | undefined = undefined;
  @Local inspectMode: boolean = false;
  @Local searchText: string = ''; // 💥 用来存搜索关键词
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

  // 💥 将当前的字典数据，转换为 ArkTS 链式语法代码
  private generateArkTSCode(): string {
    if (!this.currentBoundData || typeof this.currentBoundData !== 'object') {
      return '';
    }

    let code = '';
    let keys = Object.keys(this.currentBoundData as object);

    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      let value = (this.currentBoundData as Record<string, Object>)[key];

      // 1. 忽略空值
      if (value === undefined || value === null) {
        continue;
      }

      // 2. 字符串类型：需要加引号 (如 .fontColor('#FF0000') )
      if (typeof value === 'string') {
        code += `\n  .${key}('${value}')`;
      }
      // 3. 数字或布尔类型：直接拼接 (如 .fontSize(18) 或 .enabled(true) )
      else if (typeof value === 'number' || typeof value === 'boolean') {
        code += `\n  .${key}(${value})`;
      }
      // 4. 对象类型 (如 padding: {top: 10})：转成带大括号的 JS 对象格式
      else if (typeof value === 'object') {
        // 使用 JSON.stringify，并通过正则去掉 key 的双引号，让代码更像原生 ArkTS
        let objStr = JSON.stringify(value).replace(/"([^"]+)":/g, '$1: ');
        code += `\n  .${key}(${objStr})`;
      }
    }

    return code;
  }

  build() {
    Column() {
      // ==========================================
      // 顶部控制栏：审查开关、变量绑定与关闭按钮
      // ==========================================
      Row({ space: 8 }) {
        // 🔍 UI 审查模式切换按钮
        if (this.currentBoundData !== undefined) {
          Button("📋 导出代码")
            .height(32)
            .fontSize(13)
            .backgroundColor('#10C060') // 骚气的微信绿，代表操作成功率高
            .onClick(() => {
              // 1. 生成链式代码
              let codeString = this.generateArkTSCode();

              if (!codeString) {
                promptAction.showToast({ message: "数据为空，无法导出" });
                return;
              }

              // 2. 创建剪贴板数据
              let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, codeString);
              let systemPasteboard = pasteboard.getSystemPasteboard();

              // 3. 写入系统剪贴板并提示
              systemPasteboard.setData(pasteData).then(() => {
                promptAction.showToast({ message: "✨ ArkTS 样式代码已复制到剪贴板！" });
                // 可选：在控制台也打印一份，方便在 PC 端的 Log 里直接复制
                console.info("ArkInspector", "====== 导出的样式代码 ======");
                console.info("ArkInspector", codeString);
                console.info("ArkInspector", "=========================");
              }).catch((err: Error) => {
                promptAction.showToast({ message: "复制失败: " + err.message });
              });
            })
        }
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
      // 搜索框
      // ==========================================
      TextInput({ placeholder: '🔍 搜索属性 (例如: font)', text: this.searchText })
        .height(36)
        .margin({ left: 12, right: 12, top: 10, bottom: 4 })
        .fontSize(13)
        .backgroundColor('#F5F6F8')
        .onChange((val) => {
          this.searchText = val; // 输入时，实时更新搜索词
        })

      // ==========================================
      // 核心渲染区：递归展示 JSON 树结构
      // ==========================================
      if (this.currentBoundData !== undefined) {
        Scroll() {
          Column() {
            ForEach(
              // 1. 获取所有的 key
              Object.keys(this.currentBoundData as object)
              // 2. 过滤掉不符合搜索词的 key (如果搜索词为空，则全部保留)
                .filter((key: string) =>
                this.searchText === '' || key.toLowerCase().includes(this.searchText.toLowerCase())
                ),

              // 3. 渲染符合条件的节点
              (key: string) => {
                StateVisualizerNode({
                  keyName: key,
                  value: (this.currentBoundData as ESObject)[key],
                  onValueChange: (k: string, v: AnyValue) => {
                    // 克隆当前数据字典
                    let oldDynamic: ESObject = this.currentBoundData;
                    let newData: ESObject = Array.isArray(oldDynamic) ? [] : {};
                    let keys = Object.keys(oldDynamic as object);

                    for (let i = 0; i < keys.length; i++) {
                      newData[keys[i]] = oldDynamic[keys[i]];
                    }

                    // 更新修改的值
                    newData[k] = v;
                    this.currentBoundData = newData;

                    // 向上层（比如业务页面）通知数据变动，触发 UI 重绘
                    if (this.currentUpdater) {
                      this.currentUpdater(newData);
                    }
                  }
                })
              },
              // 4. 键值生成器
              (key: string) => key
            )
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