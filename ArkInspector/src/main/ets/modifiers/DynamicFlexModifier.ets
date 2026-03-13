/**
 * Date: 2026/3/13
 * File Name: DynamicFlexModifier.ets
 * Author: Jason
 **/

import { DynamicBaseModifier } from './DynamicBaseModifier';

export class DynamicFlexModifier extends DynamicBaseModifier implements AttributeModifier<FlexAttribute> {
  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: FlexAttribute): void {
    // Flex 的链式调用属性大部分都是通用属性（宽高、边距、背景色等）
    // 所以直接交由父类处理即可完美生效，同时获得红色高亮框能力
    super.applyNormalAttribute(instance);

    // 如果后续鸿蒙 SDK 为 FlexAttribute 增加了专属扩展方法，可以在这里补充
  }
}