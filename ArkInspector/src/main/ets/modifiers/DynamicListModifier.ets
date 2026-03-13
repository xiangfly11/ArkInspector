/**
 * Date: 2026/3/13
 * File Name: DynamicListModifier.ets
 * Author: Jason
 **/

import { DynamicBaseModifier } from './DynamicBaseModifier';

export class DynamicListModifier extends DynamicBaseModifier implements AttributeModifier<ListAttribute> {
  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: ListAttribute): void {
    super.applyNormalAttribute(instance);

    if (!this.props) return;

    // 解析 List 专属属性
    if (this.props['listDirection'] !== undefined) {
      instance.listDirection(this.props['listDirection'] as Axis);
    }
    if (this.props['scrollBar'] !== undefined) {
      instance.scrollBar(this.props['scrollBar'] as BarState);
    }
    if (this.props['cachedCount'] !== undefined) {
      instance.cachedCount(this.props['cachedCount'] as number);
    }
    if (this.props['alignListItem'] !== undefined) {
      instance.alignListItem(this.props['alignListItem'] as ListItemAlign);
    }
    if (this.props['divider'] !== undefined) {
      if (this.props['divider'] === null) {
        // 如果明确传入 null，则取消分割线
        instance.divider(null);
      } else {
        // 💥 完美绕过方案：先断言为字典，再逐个属性安全提取
        let d = this.props['divider'] as Record<string, ESObject>;

        instance.divider({
          strokeWidth: d['strokeWidth'] as Length,
          color: d['color'] as ResourceColor,
          startMargin: d['startMargin'] as Length,
          endMargin: d['endMargin'] as Length
        });
      }
    }
  }
}