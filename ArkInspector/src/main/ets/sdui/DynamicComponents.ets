/**
 * Date: 2026/3/13
 * File Name: DynamicComponents.ets
 * Author: Jason
 * Description: 纯净版动态组件工厂（基于 JSON 渲染）
 **/

import { DynamicColumnModifier } from "../modifiers/DynamicColumnModifier";
import { DynamicImageModifier } from "../modifiers/DynamicImageModifier";
import { DynamicNode, JsonValue } from "./DynamicNode";
import { DynamicRowModifier } from "../modifiers/DynamicRowModifier";
import { DynamicTextModifier } from "../modifiers/DynamicTextModifier";
import { SDUIState } from "./SDUIState";
import { SDUIEventDispatcher } from "./SDUIEventDispatcher";

// ==========================================
// 实时解析器：当遇到 ${xxx} 时，从全局状态中取值
// ==========================================
function resolveProps(props: Record<string, JsonValue>, stateContext: SDUIState): Record<string, JsonValue> {
  let resolvedProps: Record<string, JsonValue> = {};
  let keys = Object.keys(props);

  for (let i = 0; i < keys.length; i++) {
    let key = keys[i];
    let val = props[key];

    if (typeof val === 'string' && val.startsWith('${') && val.endsWith('}')) {
      let stateKey = val.substring(2, val.length - 1);
      // 从 SDUI 状态上下文中获取真实值
      resolvedProps[key] = stateContext.getItem(stateKey).value;
    } else {
      resolvedProps[key] = val; // 静态属性原样保留
    }
  }
  return resolvedProps;
}

@ComponentV2
export struct DynamicFactory {
  @Param nodeData: DynamicNode = new DynamicNode('', {});
  @Param stateContext: SDUIState = new SDUIState({});

  // 使用计算属性获取解析后的真实 Props
  get resolvedProps(): Record<string, JsonValue> {
    return resolveProps(this.nodeData.props, this.stateContext);
  }

  // 纯净的 SDUI 点击事件分发
  handleNodeClick() {
    if (this.nodeData.events && this.nodeData.events['onClick']) {
      SDUIEventDispatcher.dispatch(this.nodeData.events['onClick'], this.stateContext);
    }
  }

  build() {
    if (this.nodeData.type === 'Column') {
      Column({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
        if (this.nodeData.children) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`)
        }
      }
      .attributeModifier(new DynamicColumnModifier(this.resolvedProps))
      .onClick(() => this.handleNodeClick())

    } else if (this.nodeData.type === 'Row') {
      Row({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
        if (this.nodeData.children) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`)
        }
      }
      .attributeModifier(new DynamicRowModifier(this.resolvedProps))
      .onClick(() => this.handleNodeClick())

    } else if (this.nodeData.type === 'Text') {
      Text((this.resolvedProps['text'] as string) ?? '')
        .attributeModifier(new DynamicTextModifier(this.resolvedProps))
        .onClick(() => this.handleNodeClick())

    } else if (this.nodeData.type === 'Image') {
      Image((this.resolvedProps['src'] as string) ?? '')
        .attributeModifier(new DynamicImageModifier(this.resolvedProps))
        .onClick(() => this.handleNodeClick())
    }
  }
}