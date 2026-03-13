/**
 * Date: 2026/3/13
 * File Name: DebugOverlayPage.ets
 * Author: Jason
 **/
import { VisualDebuggerPanel } from 'arkinspector'; // 注意看你的依赖名是不是加了下划线

@Entry
@Component
struct DebugOverlayPage {
  build() {
    Column() {
      // 面板充满整个被裁切过的子窗口
      VisualDebuggerPanel()
        .width('100%')
        .height('100%')
    }
    // 💥 增加 UI 细节：顶部圆角与阴影，打造原生面板的视觉效果
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: -4 })
  }
}