/**
 * Date: 2026/3/12
 * File Name: DebugOverlayPage.ets
 * Author: Jason
 **/
import { VisualDebuggerPanel } from './VisualDebuggerPanel'

@Entry
@ComponentV2
struct DebugOverlayPage {

  build() {
    // 使用 Stack 撑满整个子窗口的空间
    Stack({ alignContent: Alignment.Bottom }) {

      // 直接渲染你的探针面板
      VisualDebuggerPanel()
        .width('100%')
        .height('100%')

    }
    .width('100%')
    .height('100%')
    // 💥 关键点：将页面的根节点背景设为透明！
    // 这样在子窗口中，除了面板本身，其他区域都是透明的，可以透出背后的 App 界面
    .backgroundColor(Color.Transparent)
  }
}