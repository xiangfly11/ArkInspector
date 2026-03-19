/**
 * Date: 2026/3/13
 * File Name: UIInspector.ets
 * Author: Jason
 * Description: 原生 UI 审查模式挂载工具
 **/

/**
 * Date: 2026/3/13
 * File Name: UIInspector.ets
 * Author: Jason
 **/
import { DebugManager } from './DebugManager';

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

  private static activeNodes: Map<string, InspectCacheNode> = new Map();

  static toggleMode() {
    UIInspector.isInspectMode = !UIInspector.isInspectMode;
    if (!UIInspector.isInspectMode) {
      UIInspector.selectedId = '';
      DebugManager.unregister("selectedUI");
      DebugManager.notify("BoxModelRect", null);

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
    }
  }

  static getActiveNodeIds(): string[] {
    let ids: string[] = [];
    UIInspector.activeNodes.forEach((value, key) => {
      ids.push(key);
    });
    return ids;
  }

  static selectNode(id: string) {
    if (!UIInspector.isInspectMode) return;
    let node = UIInspector.activeNodes.get(id);
    if (!node) return;

    let oldSelectedId = UIInspector.selectedId;
    UIInspector.selectedId = id;

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

    let clonedStyle: Record<string, Object> = {};
    let keys = Object.keys(node.style as object);
    for (let i = 0; i < keys.length; i++) {
      clonedStyle[keys[i]] = node.style[keys[i]];
    }
    node.updater(clonedStyle);

    DebugManager.register("selectedUI", clonedStyle, (newProps: ESObject) => {
      let currentNode = UIInspector.activeNodes.get(id);
      if (currentNode) { currentNode.style = newProps; }
      if (node) { node.updater(newProps); }
    });

    UIInspector.onComponentSelected();
  }

  static withInspect(
    id: string,
    styleDict: ESObject,
    updater: (newStyle: ESObject) => void,
    originalClick?: () => void
  ): (e: ClickEvent) => void {

    // 利用组件 build 时一定会执行 bind 的特性，立刻捕获【真实的 updater】并静默注册！
    if (!UIInspector.activeNodes.has(id)) {
      UIInspector.activeNodes.set(id, new InspectCacheNode(updater, styleDict));
    } else {
      let node = UIInspector.activeNodes.get(id);
      if (node) {
        node.updater = updater;
        node.style = styleDict;
      }
    }

    return (e: ClickEvent) => {
      if (UIInspector.isInspectMode) {
        let safeEvent: ESObject = e;
        if (safeEvent && safeEvent.stopPropagation) {
          safeEvent.stopPropagation();
        }
        UIInspector.selectNode(id);
      } else {
        if (originalClick) {
          originalClick();
        }
      }
    }
  }
}