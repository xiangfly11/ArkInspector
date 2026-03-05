/**
 * Date: 2026/2/26
 * File Name: DynamicComponents.ets
 * Author: Jason
 **/
import { DynamicColumnModifier } from "./DynamicColumnModifier";
import { DynamicImageModifier } from "./DynamicImageModifier";
import { DynamicNode, JsonValue } from "./DynamicNode";
import { DynamicRowModifier } from "./DynamicRowModifier";
import { DynamicTextModifier } from "./DynamicTextModifier";
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

      // ✨ V2 核心魔法：执行 .value 时，ArkUI 会自动将当前组件与这个具体的 @Trace 属性深度绑定！
      resolvedProps[key] = stateContext.getItem(stateKey).value;
    } else {
      resolvedProps[key] = val; // 静态属性原样保留
    }
  }
  return resolvedProps;
}

// ==========================================
// 原子组件区 (WrappedBuilder 注册)
// ==========================================
@Builder
export function buildText(node: DynamicNode) {
  Text((node.props['text'] as string) ?? '')
    .attributeModifier(new DynamicTextModifier(node.props))
}

@Builder
export function buildImage(node: DynamicNode) {
  Image((node.props['src'] as string) ?? '')
    .attributeModifier(new DynamicImageModifier(node.props))
}

const ComponentRegistry: Record<string, WrappedBuilder<[DynamicNode]>> = {
  'Text': wrapBuilder(buildText),
  'Image': wrapBuilder(buildImage)
};

// ==========================================
// 容器与路由工厂 (使用 V2 语法)
// ==========================================
@ComponentV2
export struct DynamicFactory {
  // 使用 @Param 接收外部传入的不可变数据和状态上下文
  @Param nodeData: DynamicNode = new DynamicNode('Column', {});
  @Param stateContext: SDUIState = new SDUIState({});
  //组件级的局部锁，用于标记当前是否正在执行耗时操作
  @Local isProcessing: boolean = false;

  @Computed
  get resolvedProps(): Record<string, JsonValue> {
    return resolveProps(this.nodeData.props, this.stateContext);
  }

  // 如果当前节点在 JSON 中没有配置 onClick，严格返回 undefined！
  // 这样 ArkUI 就会让点击事件自动冒泡给有配置 onClick 的父组件。
  // 修改事件分发器
  getClickHandler(): ((event: ClickEvent) => void) | undefined {
    let clickConfig = this.nodeData.events?.['onClick'];

    if (clickConfig) {
      // 变更为 async 箭头函数
      return async (event: ClickEvent) => {
        // 1. 如果正在处理中，直接拦截并丢弃这次点击
        if (this.isProcessing && clickConfig) {
          console.info(`[SDUI] 拦截重复点击: ${clickConfig.actionType} 正在执行中`);
          return;
        }

        // 2. 上锁
        this.isProcessing = true;

        try {
          // 3. 核心：等待 Action 完全执行完毕（比如等待网络请求 resolve）
          await SDUIEventDispatcher.dispatch(clickConfig, this.stateContext);
        } finally {
          // 4. 无论成功还是失败（报错），务必在 finally 中解锁
          this.isProcessing = false;
        }
      };
    }

    return undefined;
  }

  build() {
    // 【性能极致】：直接在 build 中解析。由于只读取了绑定的那个具体的 item.value，
    // 如果其他组件的变量变了，这里连进都不会进来！

    if (this.nodeData.type === 'Column') {
      Column({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
        if (this.nodeData.children) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) :
            `${childNode.type}_${index}`)
        }
      }
      .attributeModifier(new DynamicColumnModifier(this.resolvedProps))
      // 挂载通用的点击事件
      .onClick(this.getClickHandler())

    } else if (this.nodeData.type === 'Row') {
      Row({ space: (this.resolvedProps['space'] as number | string) ?? 0 }) {
        if (this.nodeData.children) {
          ForEach(this.nodeData.children, (childNode: DynamicNode) => {
            DynamicFactory({ nodeData: childNode, stateContext: this.stateContext })
          }, (childNode: DynamicNode, index: number) => childNode.props['nodeId'] ? String(childNode.props['nodeId']) :
            `${childNode.type}_${index}`)
        }
      }
      .attributeModifier(new DynamicRowModifier(this.resolvedProps))
      .onClick(this.getClickHandler())

    } else if (this.nodeData.type === 'Text') {
      Text((this.resolvedProps['text'] as string) ?? '')
        .attributeModifier(new DynamicTextModifier(this.resolvedProps))
        .onClick(this.getClickHandler())

    }
    else if (this.nodeData.type === 'Image') {
      Image((this.resolvedProps['src'] as string) ?? '')
        .attributeModifier(new DynamicImageModifier(this.resolvedProps))
        .onClick(this.getClickHandler())

    }
    else {
      Text(`[未识别: ${this.nodeData.type}]`).fontColor(Color.Red).padding(10)
    }
  }
}