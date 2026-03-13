/**
 * Date: 2026/3/13
 * File Name: UIInspector.ets
 * Author: Jason
 * Description: 原生 UI 审查模式挂载工具
 **/

import { DebugManager } from './DebugManager';

export class UIInspector {
  // 当前是否处于“审查模式”
  static isInspectMode: boolean = false;

  // 当前选中的控件 ID (用于给对应控件画红色虚线框)
  static selectedId: string = '';

  // 💥 核心通信机制：信号发射器，通知悬浮窗面板“有新控件被选中了，快拉取数据”
  static onComponentSelected: () => void = () => {};

  // 开启/关闭审查模式
  static toggleMode() {
    UIInspector.isInspectMode = !UIInspector.isInspectMode;
    if (!UIInspector.isInspectMode) {
      // 退出审查模式时，清空选中状态并注销数据
      UIInspector.selectedId = '';
      DebugManager.unregister("selectedUI");
    }
  }

  /**
   * 核心魔法钩子：包裹在原生组件的 onClick 中
   * @param id 控件的唯一标识 (需与 Modifier 传入的 ID 保持一致)
   * @param styleDict 控件绑定的 @Local 样式字典
   * @param updater 触发当前页面局部刷新的回调
   * @param originalClick 控件原本的业务点击事件（可选）
   */
  static withInspect(
    id: string,
    styleDict: ESObject,
    updater: (newStyle: ESObject) => void,
    originalClick?: () => void
  ): (e: ClickEvent) => void {

    return (e: ClickEvent) => {
      if (UIInspector.isInspectMode) {
        // 1. 拦截点击事件冒泡，防止点到里层却选中了外层父容器
        let safeEvent: ESObject = e;
        if (safeEvent && safeEvent.stopPropagation) {
          safeEvent.stopPropagation();
        }

        // 2. 标记当前组件为“被选中”
        UIInspector.selectedId = id;

        // 3. 克隆一份样式字典，触发原生组件刷新（为了让红色虚线框瞬间显示出来）
        let clonedStyle: Record<string, Object> = {};
        let keys = Object.keys(styleDict as object);
        for (let i = 0; i < keys.length; i++) {
          clonedStyle[keys[i]] = styleDict[keys[i]];
        }
        updater(clonedStyle);

        // 4. 将这个组件的样式字典，推送到全局数据注册表！
        DebugManager.register("selectedUI", clonedStyle, (newProps: ESObject) => {
          // 当你在悬浮窗面板里修改了 fontSize 等属性时，会回调到这里
          // 将新属性传给外层页面，触发原生 UI 重绘
          updater(newProps);
        });

        // 5. 💥 致命一击：发射信号！通知面板立刻去拿数据并渲染出修改输入框！
        UIInspector.onComponentSelected();

      } else {
        // 正常运行模式下，直接执行原本的业务点击逻辑
        if (originalClick) {
          originalClick();
        }
      }
    }
  }
}