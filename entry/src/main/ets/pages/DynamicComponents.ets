/**
 * Date: 2026/3/13
 * File Name: DynamicComponents.ets
 * Description: 动态组件工厂，融合了 UI 审查模式与实时属性修改
 **/
import { DynamicColumnModifier } from "./DynamicColumnModifier";
import { DynamicImageModifier } from "./DynamicImageModifier";
import { DynamicNode, JsonValue } from "./DynamicNode";
import { DynamicRowModifier } from "./DynamicRowModifier";
import { DynamicTextModifier } from "./DynamicTextModifier";
import { SDUIState } from "./SDUIState";
import { SDUIEventDispatcher } from "./SDUIEventDispatcher";
import { UIInspector } from "./UIInspector"; // 引入我们新写的审查管理器

// ==========================================\n// 实时解析器：当遇到 ${xxx} 时，从全局状态中取值\n// ==========================================
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

  // 💥 魔法变量：用于接收 Inspector 的强制刷新信号
  @Local renderTick: number = 0;

  // 使用计算属性获取解析后的真实 Props
  get resolvedProps(): Record<string, JsonValue> {
    return resolveProps(this.nodeData.props, this.stateContext);
  }

  aboutToAppear() {
    // 把刷新能力“借”给 Inspector，只要那边修改了属性，这里就会自动重绘
    UIInspector.forceUpdateCallback = () => {
      this.renderTick++;
    }
  }

  // 统一的点击事件分发与审查拦截器
  handleNodeClick(event: ClickEvent) {
    if (UIInspector.isInspectMode) {
      // 💥 审查模式下：拦截事件冒泡
      // 利用 ESObject 绕过 ArkTS 编译器的严格类型检查
      let safeEvent: ESObject = event;
      if (safeEvent && safeEvent.stopPropagation) {
        safeEvent.stopPropagation(); // 阻止事件向上层组件传递，防止点一个子元素选中了一堆父元素
      }

      UIInspector.selectNode(this.nodeData);
    } else {
      // 正常模式下：执行你原本写好的 SDUI 业务点击逻辑
      if (this.nodeData.events && this.nodeData.events['onClick']) {
        SDUIEventDispatcher.dispatch(this.nodeData.events['onClick'], this.stateContext);
      }
    }
  }

  build() {
    // 外层包裹一个没有多余样式的 Stack，方便我们隐藏式绑定 renderTick
    Stack() {
      // 隐藏的刷新探针
      Text(`${this.renderTick}`).width(0).height(0).opacity(0)

      if (this.nodeData.type === 'Column') {
        Column({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
          if (this.nodeData.children) {
            ForEach(this.nodeData.children, (childNode: DynamicNode) => {
              DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
            }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`)
          }
        }
        .attributeModifier(new DynamicColumnModifier(this.resolvedProps))
        .onClick((e) => this.handleNodeClick(e))
        // 💥 审查高亮边框逻辑
        .borderWidth(UIInspector.selectedNodeId === String(this.nodeData.props['nodeId']) ? 2 : 0)
        .borderColor(Color.Red)
        .borderStyle(BorderStyle.Dashed)

      } else if (this.nodeData.type === 'Row') {
        Row({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
          if (this.nodeData.children) {
            ForEach(this.nodeData.children, (childNode: DynamicNode) => {
              DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
            }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) : `${childNode.type}_${index}`)
          }
        }
        .attributeModifier(new DynamicRowModifier(this.resolvedProps))
        .onClick((e) => this.handleNodeClick(e))
        .borderWidth(UIInspector.selectedNodeId === String(this.nodeData.props['nodeId']) ? 2 : 0)
        .borderColor(Color.Red)
        .borderStyle(BorderStyle.Dashed)

      } else if (this.nodeData.type === 'Text') {
        Text((this.resolvedProps['text'] as string) ?? '')
          .attributeModifier(new DynamicTextModifier(this.resolvedProps))
          .onClick((e) => this.handleNodeClick(e))
          .borderWidth(UIInspector.selectedNodeId === String(this.nodeData.props['nodeId']) ? 2 : 0)
          .borderColor(Color.Red)
          .borderStyle(BorderStyle.Dashed)

      } else if (this.nodeData.type === 'Image') {
        Image((this.resolvedProps['src'] as string) ?? '')
          .attributeModifier(new DynamicImageModifier(this.resolvedProps))
          .onClick((e) => this.handleNodeClick(e))
          .borderWidth(UIInspector.selectedNodeId === String(this.nodeData.props['nodeId']) ? 2 : 0)
          .borderColor(Color.Red)
          .borderStyle(BorderStyle.Dashed)
      }
    }
  }
}