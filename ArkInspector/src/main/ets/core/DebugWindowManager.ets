/**
 * Date: 2026/3/12
 * File Name: DebugWindowManager.ets
 * Author: Jason
 * Description: 全局悬浮窗管理器
 **/

import { window, display } from '@kit.ArkUI';

export class DebugWindowManager {
  private static windowStage: window.WindowStage | null = null;
  private static overlayPageUrl: string = '';
  private static subWindow: window.Window | null = null;

  static init(stage: window.WindowStage, overlayPageUrl: string) {
    DebugWindowManager.windowStage = stage;
    DebugWindowManager.overlayPageUrl = overlayPageUrl;
  }

  static showDebugger() {
    if (!DebugWindowManager.windowStage) {
      console.error("ArkInspector", "未初始化 WindowStage");
      return;
    }

    if (DebugWindowManager.subWindow) {
      DebugWindowManager.subWindow.showWindow();
      return;
    }

    DebugWindowManager.windowStage.createSubWindow("ArkInspectorWindow", (err, win) => {
      if (err && err.code) return;
      DebugWindowManager.subWindow = win;

      // 💥 核心修复：获取屏幕真实物理分辨率，并裁剪/移动窗口
      try {
        let displayInfo = display.getDefaultDisplaySync();
        let screenWidth = displayInfo.width;
        let screenHeight = displayInfo.height;

        // 设定悬浮窗高度为屏幕的 40%
        let panelHeight = Math.floor(screenHeight * 0.4);

        // 1. 缩放窗口
        win.resize(screenWidth, panelHeight);
        // 2. 移动窗口到屏幕最底部 (Y轴 = 总高度 - 面板高度)
        win.moveWindowTo(0, screenHeight - panelHeight);
        // 3. 把窗口背景设为全透明，防止出现黑边
        win.setWindowBackgroundColor('#00000000');

      } catch (exception) {
        console.error("ArkInspector", "窗口尺寸重置失败", exception);
      }

      win.setUIContent(DebugWindowManager.overlayPageUrl, (err) => {
        if (err && err.code) {
          win.destroyWindow();
          DebugWindowManager.subWindow = null;
          return;
        }
        win.showWindow();
      });
    });
  }

  static hideDebugger() {
    if (DebugWindowManager.subWindow) {
      DebugWindowManager.subWindow.destroyWindow();
      DebugWindowManager.subWindow = null;
    }
  }
}