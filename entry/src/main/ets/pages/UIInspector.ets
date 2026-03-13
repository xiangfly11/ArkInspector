/**
 * Date: 2026/3/13
 * File Name: UIInspector.ets
 * Author: Jason
 * Description: 全局 UI 审查模式管理器
 **/
import { DynamicNode } from './DynamicNode';
import { DebugManager } from './DebugManager';

export class UIInspector {
  // 是否开启了“元素选中模式”
  static isInspectMode: boolean = false;

  // 当前选中的节点 ID 或引用
  static selectedNodeId: string | null = null;

  // 触发 UI 强制刷新的回调（由最外层页面注入）
  static forceUpdateCallback: () => void = () => {};

  // 选中一个组件节点
  static selectNode(node: DynamicNode) {
    // 1. 记录选中的节点，用于加上高亮边框
    // 为了可靠性，如果节点没有 nodeId，我们可以动态给它赋一个随机的
    if (!node.props['nodeId']) {
      node.props['nodeId'] = 'ins_' + Math.floor(Math.random() * 1000000);
    }
    UIInspector.selectedNodeId = String(node.props['nodeId']);

    // 2. 💥 将这个组件的 props 自动推送到我们之前的调试注册中心！
    DebugManager.register("selectedUI", node.props, (newProps: ESObject) => {
      // 当在悬浮窗里修改了 fontSize、width 等属性时...

      // 替换节点的 props
      let keys = Object.keys(newProps as object);
      for (let i = 0; i < keys.length; i++) {
        node.props[keys[i]] = newProps[keys[i]];
      }

      // 触发全局或局部的重绘，让 Modifier 重新执行！
      UIInspector.forceUpdateCallback();
    });

    // 触发一下重绘，让选中框显示出来
    UIInspector.forceUpdateCallback();
  }

  // 开启/关闭审查模式
  static toggleMode() {
    UIInspector.isInspectMode = !UIInspector.isInspectMode;
    if (!UIInspector.isInspectMode) {
      UIInspector.selectedNodeId = null;
      DebugManager.unregister("selectedUI");
    }
    UIInspector.forceUpdateCallback();
  }
}