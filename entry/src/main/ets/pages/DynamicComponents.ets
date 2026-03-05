/**
 * Date: 2026/2/26
 * File Name: DynamicComponents.ets
 * Author: Jason
 **/

import { DynamicColumnModifier } from "./DynamicColumnModifier";
import { DynamicImageModifier } from "./DynamicImageModifier";
import { DynamicNode, EventConfig } from "./DynamicNode";
import { DynamicRowModifier } from "./DynamicRowModifier";
import { DynamicTextModifier } from "./DynamicTextModifier";
import { SDUIEventDispatcher } from "./SDUIEventDispatcher";


// ==========================================
// 提取公共的事件处理逻辑
// ==========================================
function handleNodeEvents(events?: Record<string, EventConfig>) {
  if (!events) return;

  // 拦截点击事件
  let clickConfig = events['onClick'];
  if (clickConfig) {
    SDUIEventDispatcher.dispatch(clickConfig);
  }

  // 如果未来需要长按事件，可以直接扩充：
  // let longPressConfig = events['onLongPress'];
}

@Builder
export function buildText(node: DynamicNode) {
  // 直接在参数中进行 as 断言和默认值赋予
  Text((node.props['text'] as string) ?? '')
    .attributeModifier(new DynamicTextModifier(node.props))
    .onClick(() => {
        handleNodeEvents(node.events);
    })
}

@Builder
export function buildImage(node: DynamicNode) {
  Image((node.props['src'] as string) ?? '')
    .attributeModifier(new DynamicImageModifier(node.props))
    .onClick(() => {
        handleNodeEvents(node.events);
    })
}

// 严格声明 Registry 的结构
const ComponentRegistry: Record<string, WrappedBuilder<[DynamicNode]>> = {
  'Text': wrapBuilder(buildText),
  'Image': wrapBuilder(buildImage)
};

@Component
export struct DynamicFactory {
  @Prop nodeData: DynamicNode;

  build() {
    // ==========================================
    // 场景 A：处理【容器组件】(必须包裹 children)
    // ==========================================
    if (this.nodeData.type === 'Column') {
      // 1. 实例化真正的 Column，提取构造参数 space
      Column({ space: (this.nodeData.props['space'] as number | string) ?? 0 }) {

        // 2. 将子节点真正放入 Column 的大括号内部！
        if (this.nodeData.children && this.nodeData.children.length > 0) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            // 递归调用
            DynamicFactory({ nodeData: childNode })
          }, (childNode: DynamicNode, index: number) => {
            // 尽量使用后端下发的唯一 id，如果没有再降级拼接
            return childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`;
          })
        }

      }
      // 3. 将所有样式（阴影、圆角、对齐等）打在这个包含了子节点的真实容器上
      .attributeModifier(new DynamicColumnModifier(this.nodeData.props))
      .onClick(() => {
        handleNodeEvents(this.nodeData.events);
      })
    }
    // ==========================================
    // 容器组件 B：Row (水平线性布局)
    // ==========================================
    else if (this.nodeData.type === 'Row') {
      // 1. 实例化真正的 Row，并提取 space 间距参数
      Row({ space: (this.nodeData.props['space'] as number | string) ?? 0 }) {
        // 2. 递归渲染子节点放入 Row 内部
        if (this.nodeData.children && this.nodeData.children.length > 0) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            DynamicFactory({ nodeData: childNode })
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) :
            `${childNode.type}_${index}`)
        }
      }
      // 3. 将我们刚写好的 DynamicRowModifier 挂载上去
      .attributeModifier(new DynamicRowModifier(this.nodeData.props))
      .onClick(() => {
        handleNodeEvents(this.nodeData.events);
      })
    }
    // ==========================================
    // 场景 B：处理【原子组件】(无 children)
    // ==========================================
    else if (ComponentRegistry[this.nodeData.type]) {
      // 从字典中取出 Text、Image 等组件并渲染
      ComponentRegistry[this.nodeData.type].builder(this.nodeData)
    }
    // ==========================================
    // 场景 C：容错降级
    // ==========================================
    else {
      Text(`[未识别的组件类型: ${this.nodeData.type}]`)
        .fontColor(Color.Red)
        .padding(16)
        .backgroundColor('#FFF0F0')
    }
  }
}