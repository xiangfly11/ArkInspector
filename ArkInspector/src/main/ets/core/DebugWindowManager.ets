/**
 * Date: 2026/3/12
 * File Name: DebugWindowManager.ets
 * Author: Jason
 * Description: 全局悬浮窗管理器- 支持面板自由拖拽
 **/

import { window, display } from '@kit.ArkUI';

export class DebugWindowManager {
  private static windowStage: window.WindowStage | null = null;
  private static overlayPageUrl: string = '';

  private static panelWindow: window.Window | null = null;
  private static overlayWindow: window.Window | null = null;

  // 💥 新增：记录悬浮窗当前的物理坐标和尺寸
  private static panelX: number = 0;
  private static panelY: number = 0;
  private static screenW: number = 0;
  private static screenH: number = 0;
  private static panelW: number = 0;
  private static panelH: number = 0;

  static init(stage: window.WindowStage, overlayPageUrl: string) {
    DebugWindowManager.windowStage = stage;
    DebugWindowManager.overlayPageUrl = overlayPageUrl;
  }

  static showDebugger() {
    if (!DebugWindowManager.windowStage) return;

    try {
      let displayInfo = display.getDefaultDisplaySync();
      DebugWindowManager.screenW = displayInfo.width;
      DebugWindowManager.screenH = displayInfo.height;

      // ==========================================
      // 💥 智能计算悬浮窗的最佳尺寸与初始位置
      // ==========================================
      if (DebugWindowManager.screenW > 1600) {
        // 折叠屏展开/平板：面板占屏幕宽度的 50%
        DebugWindowManager.panelW = Math.floor(DebugWindowManager.screenW * 0.5);
        DebugWindowManager.panelH = Math.floor(DebugWindowManager.screenH * 0.6);
      } else {
        // 普通手机窄屏：面板占屏幕宽度的 92%
        DebugWindowManager.panelW = Math.floor(DebugWindowManager.screenW * 0.92);
        DebugWindowManager.panelH = Math.floor(DebugWindowManager.screenH * 0.55);
      }

      // 初始位置：水平居中，垂直靠下（留出一点边距，不贴底）
      DebugWindowManager.panelX = Math.floor((DebugWindowManager.screenW - DebugWindowManager.panelW) / 2);
      DebugWindowManager.panelY = DebugWindowManager.screenH - DebugWindowManager.panelH - 100;

      // 🪟 窗口 1：全屏画板窗口 (保持不变，专职画遮罩)
      if (!DebugWindowManager.overlayWindow) {
        DebugWindowManager.windowStage.createSubWindow("ArkInspectorOverlay", (err, win) => {
          if (err && err.code) return;
          DebugWindowManager.overlayWindow = win;

          win.resize(DebugWindowManager.screenW, DebugWindowManager.screenH);
          win.moveWindowTo(0, 0);

          win.setTouchable(false);
          win.setFocusable(false);

          let storage = new LocalStorage();
          storage.setOrCreate('windowType', 'overlay');

          win.loadContent(DebugWindowManager.overlayPageUrl, storage, (err) => {
            if (err && err.code) return;
            try { win.setWindowBackgroundColor('#00000000'); } catch (e) {}
            win.showWindow();
          });
        });
      }

      // 🪟 窗口 2：面板窗口 (现在变成了真正的自由悬浮窗！)
      if (!DebugWindowManager.panelWindow) {
        DebugWindowManager.windowStage.createSubWindow("ArkInspectorPanel", (err, win) => {
          if (err && err.code) return;
          DebugWindowManager.panelWindow = win;

          // 💥 尺寸变小，位置变灵活
          win.resize(DebugWindowManager.panelW, DebugWindowManager.panelH);
          win.moveWindowTo(DebugWindowManager.panelX, DebugWindowManager.panelY);

          let storage = new LocalStorage();
          storage.setOrCreate('windowType', 'panel');

          win.loadContent(DebugWindowManager.overlayPageUrl, storage, (err) => {
            if (err && err.code) return;
            try { win.setWindowBackgroundColor('#00000000'); } catch (e) {}
            win.showWindow();
          });
        });
      }

    } catch (exception) {
      console.error("ArkInspector", "窗口创建失败", exception);
    }
  }

  // ==========================================
  // 💥 新增：供 UI 调用的全局窗口拖拽引擎
  // ==========================================
  static movePanel(offsetX: number, offsetY: number, isEnd: boolean) {
    if (!DebugWindowManager.panelWindow) return;

    // 计算手指拖拽后的目标坐标
    let targetX = DebugWindowManager.panelX + offsetX;
    let targetY = DebugWindowManager.panelY + offsetY;

    try {
      // 实时移动真实的底层 Window
      DebugWindowManager.panelWindow.moveWindowTo(targetX, targetY);
    } catch (e) {}

    // 如果手指松开，固化当前的新坐标，作为下次拖拽的起点
    if (isEnd) {
      DebugWindowManager.panelX = targetX;
      DebugWindowManager.panelY = targetY;
    }
  }

  static hideDebugger() {
    if (DebugWindowManager.panelWindow) {
      DebugWindowManager.panelWindow.destroyWindow();
      DebugWindowManager.panelWindow = null;
    }
    if (DebugWindowManager.overlayWindow) {
      DebugWindowManager.overlayWindow.destroyWindow();
      DebugWindowManager.overlayWindow = null;
    }
  }
}