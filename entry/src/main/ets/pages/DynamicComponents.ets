/**
 * Date: 2026/2/26
 * File Name: DynamicComponents.ets
 * Author: Jason
 **/

import { DynamicColumnModifier } from "./DynamicColumnModifier";
import { DynamicImageModifier } from "./DynamicImageModifier";
import { JsonValue, DynamicNode } from "./DynamicNode";
import { DynamicRowModifier } from "./DynamicRowModifier";
import { DynamicTextModifier } from "./DynamicTextModifier";


@Builder
export function buildText(props: Record<string, JsonValue>) {
  // 直接在参数中进行 as 断言和默认值赋予
  Text((props['text'] as string) ?? '')
    .attributeModifier(new DynamicTextModifier(props))
}

@Builder
export function buildMediaWebContainer(props: Record<string, JsonValue>) {
  Column() {
    Text(`[Web容器占位] 加载H5地址: ${(props['url'] as string) ?? ''}`)
      .fontColor(Color.White)
  }
  .width('100%')
  .height((props['height'] as number) ?? 250)
  .backgroundColor('#2C3E50')
  .justifyContent(FlexAlign.Center)
}

@Builder
export function buildColumn(props: Record<string, JsonValue>) {
  Column({ space: props['space'] as string ?? 0 })
    .attributeModifier(new DynamicColumnModifier(props))
}

@Builder
export function buildImage(props: Record<string, JsonValue>)  {
  Image((props['src'] as string) ?? '')
    .attributeModifier(new DynamicImageModifier(props))
}

// 严格声明 Registry 的结构
const ComponentRegistry: Record<string, WrappedBuilder<[Record<string, JsonValue>]>> = {
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
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`)
        }
      }
      // 3. 将我们刚写好的 DynamicRowModifier 挂载上去
      .attributeModifier(new DynamicRowModifier(this.nodeData.props))
    }
    // ==========================================
    // 场景 B：处理【原子组件】(无 children)
    // ==========================================
    else if (ComponentRegistry[this.nodeData.type]) {
      // 从字典中取出 Text、Image 等组件并渲染
      ComponentRegistry[this.nodeData.type].builder(this.nodeData.props)
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