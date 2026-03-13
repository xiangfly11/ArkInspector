/**
 * Date: 2026/3/13
 * File Name: UIInspector.ets
 * Author: Jason
 * Description: 原生 UI 审查模式挂载工具
 **/

import { DebugManager } from './DebugManager';

// 💥 1. 新增：专门定义一个缓存节点类，完美绕过 ArkTS 泛型不能用 ESObject 的限制
class InspectCacheNode {
  updater: (newStyle: ESObject) => void;
  style: ESObject;

  constructor(updater: (newStyle: ESObject) => void, style: ESObject) {
    this.updater = updater;
    this.style = style;
  }
}

export class UIInspector {
  static isInspectMode: boolean = false;
  static selectedId: string = '';
  static onComponentSelected: () => void = () => {};

  // 💥 2. 泛型替换为我们刚定义的 InspectCacheNode
  private static activeNodes: Map<string, InspectCacheNode> = new Map();

  static toggleMode() {
    UIInspector.isInspectMode = !UIInspector.isInspectMode;
    if (!UIInspector.isInspectMode) {
      UIInspector.selectedId = '';
      DebugManager.unregister("selectedUI");

      // 退出/关闭面板时：强制唤醒所有摸过的控件洗掉红框
      UIInspector.activeNodes.forEach((node: InspectCacheNode) => {
        if (node.updater && node.style) {
          let clonedStyle: Record<string, Object> = {};
          let keys = Object.keys(node.style as object);
          for (let i = 0; i < keys.length; i++) {
            clonedStyle[keys[i]] = node.style[keys[i]];
          }
          node.updater(clonedStyle);
        }
      });

      UIInspector.activeNodes.clear();
    }
  }

  static withInspect(
    id: string,
    styleDict: ESObject,
    updater: (newStyle: ESObject) => void,
    originalClick?: () => void
  ): (e: ClickEvent) => void {

    return (e: ClickEvent) => {
      if (UIInspector.isInspectMode) {
        let safeEvent: ESObject = e;
        if (safeEvent && safeEvent.stopPropagation) {
          safeEvent.stopPropagation();
        }

        let oldSelectedId = UIInspector.selectedId;
        UIInspector.selectedId = id;

        // 💥 3. 立即清除上一个控件的红框（单选排他）
        if (oldSelectedId && oldSelectedId !== id) {
          let oldNode = UIInspector.activeNodes.get(oldSelectedId);
          if (oldNode && oldNode.updater && oldNode.style) {
            let clonedOldStyle: Record<string, Object> = {};
            let oldKeys = Object.keys(oldNode.style as object);
            for (let i = 0; i < oldKeys.length; i++) {
              clonedOldStyle[oldKeys[i]] = oldNode.style[oldKeys[i]];
            }
            oldNode.updater(clonedOldStyle);
          }
        }

        // 💥 4. 使用 new 实例化我们定义的类存入 Map
        UIInspector.activeNodes.set(id, new InspectCacheNode(updater, styleDict));

        let clonedStyle: Record<string, Object> = {};
        let keys = Object.keys(styleDict as object);
        for (let i = 0; i < keys.length; i++) {
          clonedStyle[keys[i]] = styleDict[keys[i]];
        }
        updater(clonedStyle);

        DebugManager.register("selectedUI", clonedStyle, (newProps: ESObject) => {
          let currentNode = UIInspector.activeNodes.get(id);
          if (currentNode) {
            currentNode.style = newProps;
          }
          updater(newProps);
        });

        UIInspector.onComponentSelected();

      } else {
        if (originalClick) {
          originalClick();
        }
      }
    }
  }
}