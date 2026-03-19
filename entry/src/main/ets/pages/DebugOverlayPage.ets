/**
 * Date: 2026/3/13
 * File Name: DebugOverlayPage.ets
 * Author: Jason
 **/

import { BoxModelOverlay, VisualDebuggerPanel } from 'arkinspector';

// 💥 关键修复 1：正确获取 loadContent 传进来的当前窗口专属 LocalStorage
// 使用 ?? new LocalStorage() 完美绕过 ArkTS 的非空严格检查红线
let sharedStorage = LocalStorage.getShared() ?? new LocalStorage();

// 💥 关键修复 2：必须把获取到的 sharedStorage 显式塞进 Entry 的括号里！
@Entry(sharedStorage)
@Component
struct DebugOverlayPage {

  // 这下它终于能精准读取到是 'overlay' 还是 'panel' 了！
  @LocalStorageProp('windowType') windowType: string = 'panel';

  build() {
    Stack({ alignContent: Alignment.Bottom }) {

      // 智能分发：各司其职
      if (this.windowType === 'overlay') {
        // 画板窗口：专门画高亮遮罩，不拦截任何操作
        BoxModelOverlay()
      } else {
        // 面板窗口：专门渲染控制台
        VisualDebuggerPanel()
          .height('100%')
          .width('100%')
          .shadow({ radius: 20, color: '#33000000', offsetY: -5 })
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .hitTestBehavior(HitTestMode.Transparent) // 保障事件穿透
  }
}