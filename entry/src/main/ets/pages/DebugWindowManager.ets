/**
 * Date: 2026/3/12
 * File Name: DebugWindowManager.ets
 * Author: Jason
 * Description: 全局悬浮窗管理器
 **/

import window from '@ohos.window';

export class DebugWindowManager {
  private static subWindow: window.Window | null = null;

  // 💥 入参全部删掉，随叫随到！
  static async showDebugger() {
    if (DebugWindowManager.subWindow !== null) {
      await DebugWindowManager.subWindow.showWindow();
      return;
    }

    try {
      // 1. 从全局内存中取出 windowStage
      let windowStage = AppStorage.get<window.WindowStage>('myWindowStage');
      if (!windowStage) {
        console.error("[DebugWindow] 严重错误：未能获取到 windowStage！");
        return;
      }

      // 2. 使用 windowStage 创建子窗口（百分百不报错的官方标准姿势）
      DebugWindowManager.subWindow = await windowStage.createSubWindow("SDUIDebuggerWindow");

      // 3. 挂载我们之前写好的透明背景宿主页面
      await DebugWindowManager.subWindow.setUIContent("pages/DebugOverlayPage");

      // 4. 获取主窗口的尺寸，用来计算探针面板的宽高
      let mainWindow = await windowStage.getMainWindow();
      let properties = mainWindow.getWindowProperties();
      let screenWidth = properties.windowRect.width;
      let screenHeight = properties.windowRect.height;

      // 5. 移到屏幕下半部分并设置尺寸
      await DebugWindowManager.subWindow.moveWindowTo(0, screenHeight / 2);
      await DebugWindowManager.subWindow.resize(screenWidth, screenHeight / 2);

      // 6. 登场展示！
      await DebugWindowManager.subWindow.showWindow();

    } catch (err) {
      console.error("[DebugWindow] 创建调试窗口失败: " + JSON.stringify(err));
    }
  }

  static async hideDebugger() {
    if (DebugWindowManager.subWindow) {
      await DebugWindowManager.subWindow.destroyWindow();
      DebugWindowManager.subWindow = null;
    }
  }
}