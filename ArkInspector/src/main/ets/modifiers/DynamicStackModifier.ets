/**
 * Date: 2026/3/13
 * File Name: DynamicStackModifier.ets
 * Author: Jason
 **/

import { DynamicBaseModifier } from './DynamicBaseModifier';

export class DynamicStackModifier extends DynamicBaseModifier implements AttributeModifier<StackAttribute> {
  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: StackAttribute): void {
    super.applyNormalAttribute(instance);

    if (!this.props) return;

    // 解析 Stack 专属属性
    if (this.props['alignContent'] !== undefined) {
      instance.alignContent(this.props['alignContent'] as Alignment);
    }
  }
}