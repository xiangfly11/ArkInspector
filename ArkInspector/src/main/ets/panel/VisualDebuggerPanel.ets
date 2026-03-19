/**
 * Date: 2026/3/12
 * File Name: VisualDebuggerPanel.ets
 * Author: Jason
 * Description:探针主面板容器 - 支持变量绑定、UI 元素审查、DOM树联动与代码导出
 **/


import { StateVisualizerNode, AnyValue } from './StateVisualizerNode';
import { DebugManager } from '../core/DebugManager';
import { UIInspector } from '../core/UIInspector';
import { DebugWindowManager } from '../core/DebugWindowManager';
import { promptAction, mediaquery } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';

@ComponentV2
export struct VisualDebuggerPanel {
  @Local inputKey: string = '';
  @Local currentBoundData: ESObject = undefined;
  @Local currentUpdater: ((newVal: ESObject) => void) | undefined = undefined;
  @Local inspectMode: boolean = false;
  @Local searchText: string = '';
  @Local activeIds: string[] = [];

  // ==========================================
  // 💥 折叠屏自适应引擎
  // ==========================================
  @Local isNarrowScreen: boolean = true;
  private mqListener: mediaquery.MediaQueryListener | null = null;

  aboutToAppear() {
    // 必须在 aboutToAppear 中初始化，确保拿到子窗口真实的 UI Context
    this.mqListener = mediaquery.matchMediaSync('(max-width: 600vp)');

    // 监听屏幕折叠/展开事件
    this.mqListener.on('change', (res: mediaquery.MediaQueryResult) => {
      this.isNarrowScreen = res.matches; // 屏幕宽度 <= 600vp 时为 true
    });

    // 必须主动获取一次初始状态，确保打开时布局正确！
    this.isNarrowScreen = this.mqListener.matches;

    UIInspector.onComponentSelected = () => {
      if (this.inspectMode) {
        this.activeIds = UIInspector.getActiveNodeIds();
        let config = DebugManager.getBinding("selectedUI");
        if (config) {
          this.currentBoundData = config.data;
          this.currentUpdater = config.updater;
        }
      }
    }
  }

  aboutToDisappear() {
    // 组件销毁时移除监听
    if (this.mqListener) {
      this.mqListener.off('change');
    }
  }

  private generateArkTSCode(): string {
    if (!this.currentBoundData || typeof this.currentBoundData !== 'object') return '';
    let code = '';
    let keys = Object.keys(this.currentBoundData as object);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      let value = (this.currentBoundData as Record<string, Object>)[key];
      if (value === undefined || value === null) continue;

      if (typeof value === 'string') {
        code += `\n  .${key}('${value}')`;
      } else if (typeof value === 'number' || typeof value === 'boolean') {
        code += `\n  .${key}(${value})`;
      } else if (typeof value === 'object') {
        let objStr = JSON.stringify(value).replace(/"([^"]+)":/g, '$1: ');
        code += `\n  .${key}(${objStr})`;
      }
    }
    return code;
  }

  // ==========================================
  // 🧩 抽离 UI 组件块：让代码如诗般优雅
  // ==========================================

  @Builder HeaderActions() {
    Button(this.inspectMode ? "🛑 退出审查" : "🔍 审查 UI")
      .backgroundColor(this.inspectMode ? '#FF4444' : '#3E75D8')
      .fontSize(13).height(32)
      .onClick(() => {
        UIInspector.toggleMode();
        this.inspectMode = UIInspector.isInspectMode;
        if (this.inspectMode) {
          this.inputKey = "selectedUI";
          this.activeIds = UIInspector.getActiveNodeIds();
          promptAction.showToast({ message: "请在上方点击控件，或在 DOM 树中选择" });
        } else {
          this.inputKey = "";
          this.currentBoundData = undefined;
          this.currentUpdater = undefined;
          this.activeIds = [];
        }
      })

    if (this.currentBoundData !== undefined) {
      Button("📋 导出")
        .backgroundColor('#10C060').fontSize(13).height(32)
        .onClick(() => {
          let codeString = this.generateArkTSCode();
          if (!codeString) return;
          let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, codeString);
          pasteboard.getSystemPasteboard().setData(pasteData).then(() => {
            promptAction.showToast({ message: "✨ 代码已复制！" });
          })
        })
    }
  }

  @Builder HeaderBinding() {
    TextInput({ placeholder: '输入变量名绑定...', text: this.inputKey })
      .layoutWeight(1).height(32).fontSize(13).backgroundColor('#F0F0F0')
      .onChange((val) => { this.inputKey = val; })

    Button("绑定").backgroundColor('#333333').fontSize(13).height(32)
      .onClick(() => {
        if (!this.inputKey) return;
        let config = DebugManager.getBinding(this.inputKey);
        if (config) {
          this.currentBoundData = config.data;
          this.currentUpdater = config.updater;
          promptAction.showToast({ message: "绑定成功" });
        } else {
          promptAction.showToast({ message: "未找到变量" });
        }
      })
  }

  @Builder PropertyPanel() {
    Column() {
      if (this.currentBoundData !== undefined) {
        TextInput({ placeholder: '🔍 搜索属性 (例如: font)', text: this.searchText })
          .height(36).margin({ left: 12, right: 12, top: 10, bottom: 4 })
          .fontSize(13).backgroundColor('#F5F6F8')
          .onChange((val) => { this.searchText = val; })

        Scroll() {
          Column() {
            ForEach(
              Object.keys(this.currentBoundData as object)
                .filter((key: string) => this.searchText === '' || key.toLowerCase().includes(this.searchText.toLowerCase())),
              (key: string) => {
                StateVisualizerNode({
                  keyName: key,
                  value: (this.currentBoundData as Record<string, Object>)[key],
                  onValueChange: (k: string, v: AnyValue) => {
                    let oldDynamic: ESObject = this.currentBoundData;
                    let newData: ESObject = Array.isArray(oldDynamic as object) ? [] : {};
                    let keys = Object.keys(oldDynamic as object);
                    for (let i = 0; i < keys.length; i++) newData[keys[i]] = oldDynamic[keys[i]];
                    newData[k] = v;
                    this.currentBoundData = newData;
                    if (this.currentUpdater) this.currentUpdater(newData);
                  }
                })
              },
              (key: string) => key
            )
          }.padding(12)
        }.layoutWeight(1).align(Alignment.TopStart)
      } else {
        Column() {
          Text("暂无数据").fontColor('#999999').fontSize(16).margin({ top: 40 })
          Text(`可用变量:\n${DebugManager.getAvailableKeys().join(' , ') || '无'}`)
            .fontSize(13).fontColor('#666666').margin({ top: 20 }).textAlign(TextAlign.Center).padding(20)
        }.layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%')
  }

  @Builder DomTreePanel() {
    List() {
      ForEach(this.activeIds, (id: string) => {
        ListItem() {
          Row() {
            Text("🌳 " + id)
              .fontSize(14)
              .fontColor(UIInspector.selectedId === id ? '#3E75D8' : '#333333')
              .fontWeight(UIInspector.selectedId === id ? FontWeight.Bold : FontWeight.Normal)
          }
          .width('100%').padding(14)
          .backgroundColor(UIInspector.selectedId === id ? '#F0F5FF' : Color.Transparent)
          .onClick(() => { UIInspector.selectNode(id); })
        }
      }, (id: string) => id)
    }.width('100%').height('100%')
  }

  // ==========================================
  // 💥 核心魔法：悬浮拖拽把手
  // ==========================================
  @Builder DragHandle() {
    Row() {
      // 中间的灰色小药丸，暗示此处可拖拽
      Row().width(40).height(5).backgroundColor('#D0D0D0').borderRadius(2.5)
    }
    .width('100%')
    .height(32)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF') // 必须有底色，否则无法有效拦截并抓取手势
    // 绑定位移手势
    // 绑定位移手势
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent) => {
          // 💥使用 vp2px 将手势的虚拟像素 (vp) 转换为底层窗口认识的物理像素 (px)！
          DebugWindowManager.movePanel(vp2px(event.offsetX), vp2px(event.offsetY), false);
        })
        .onActionEnd((event: GestureEvent) => {
          // 手指松开，固化坐标时也必须转换！
          DebugWindowManager.movePanel(vp2px(event.offsetX), vp2px(event.offsetY), true);
        })
    )
  }

  build() {
    Column() {
      // 💥 顶部加入了可响应手势的拖拽把手
      this.DragHandle()

      // ==========================================
      // 响应式顶部控制栏
      // ==========================================
      if (this.isNarrowScreen) {
        // 📱 窄屏模式：两行布局，彻底解决挤压
        Column({ space: 10 }) {
          Row({ space: 8 }) {
            this.HeaderActions()
            Blank() // 自动推开剩余空间
            Text("✕ 关闭").fontSize(14).fontColor('#999').padding(4)
              .onClick(() => { DebugWindowManager.hideDebugger(); })
          }.width('100%')

          Row({ space: 8 }) {
            this.HeaderBinding()
          }.width('100%')
        }.padding({ left: 12, right: 12, bottom: 10, top: 0 })
      } else {
        // 📖 宽屏模式：单行布局
        Row({ space: 12 }) {
          this.HeaderActions()
          Divider().vertical(true).height(20).color('#E0E0E0')
          this.HeaderBinding()
          Blank()
          Text("✕ 关闭").fontSize(14).fontColor('#999').padding(4)
            .onClick(() => { DebugWindowManager.hideDebugger(); })
        }.width('100%').padding({ left: 16, right: 16, bottom: 10, top: 0 })
      }

      Divider().color('#E0E0E0')

      // ==========================================
      // 响应式内容区
      // ==========================================
      if (this.isNarrowScreen) {
        // 📱 窄屏模式：Tabs 切换
        Tabs({ barPosition: BarPosition.Start }) {
          TabContent() { this.PropertyPanel() }.tabBar("🎨 属性检查")
          TabContent() { this.DomTreePanel() }.tabBar("🌳 DOM 树")
        }.layoutWeight(1).width('100%')
      } else {
        // 📖 宽屏模式：左右双分栏视图
        Row() {
          Column() {
            Text("🌳 DOM 树").fontSize(14).fontWeight(FontWeight.Bold).margin(12).fontColor('#333')
            this.DomTreePanel()
          }.layoutWeight(1).height('100%').backgroundColor('#FAFAFA')

          Divider().vertical(true).width(1).color('#E0E0E0')

          Column() {
            Text("🎨 属性检查").fontSize(14).fontWeight(FontWeight.Bold).margin(12).fontColor('#333')
            this.PropertyPanel()
          }.layoutWeight(2).height('100%') // 属性栏更宽一些
        }.layoutWeight(1).width('100%')
      }

    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    // 💥 外观优化：四周统一变为大圆角，增加边框，使其真正具备“悬浮浮窗”的质感
    .borderRadius(16)
    .border({ width: 1, color: '#E5E5E5' })
    .clip(true)
  }
}