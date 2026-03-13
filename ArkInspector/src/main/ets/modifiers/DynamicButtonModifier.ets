/**
 * Date: 2026/3/13
 * File Name: DynamicButtonModifier.ets
 * Author: Jason
 **/

import { DynamicBaseModifier } from './DynamicBaseModifier';

export class DynamicButtonModifier extends DynamicBaseModifier implements AttributeModifier<ButtonAttribute> {
  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    // 1. 先调用父类，应用基础属性和审查模式的红色虚线框
    super.applyNormalAttribute(instance);

    if (!this.props) return;

    // 2. 解析 Button 专属属性
    if (this.props['type'] !== undefined) {
      instance.type(this.props['type'] as ButtonType);
    }
    if (this.props['stateEffect'] !== undefined) {
      instance.stateEffect(this.props['stateEffect'] as boolean);
    }
    if (this.props['fontColor'] !== undefined) {
      instance.fontColor(this.props['fontColor'] as ResourceColor);
    }
    if (this.props['fontSize'] !== undefined) {
      instance.fontSize(this.props['fontSize'] as number | string | Resource);
    }
    if (this.props['fontWeight'] !== undefined) {
      instance.fontWeight(this.props['fontWeight'] as number | FontWeight | string);
    }
  }
}