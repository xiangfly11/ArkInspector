/**
 * Date: 2026/2/27
 * File Name: DynamicRowModifier.ets
 * Author: Jason
 **/
import { DynamicBaseModifier } from "./DynamicBaseModifier";

export class DynamicRowModifier extends DynamicBaseModifier implements AttributeModifier<RowAttribute> {

  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: RowAttribute): void {
    // 1. 继承基类：瞬间获得宽高、边距、背景、阴影、圆角等所有通用能力
    super.applyNormalAttribute(instance);

    // ==========================================
    // 2. 主轴对齐方式 (水平方向的排版分布)
    // 对应 ArkUI 的 justifyContent -> FlexAlign 枚举
    // ==========================================
    if (this.props['justifyContent'] !== undefined) {
      let justifyStr = String(this.props['justifyContent']);

      let justifyMap: Record<string, FlexAlign> = {
        'Start': FlexAlign.Start,               // 靠左对齐 (默认)
        'Center': FlexAlign.Center,             // 居中对齐
        'End': FlexAlign.End,                   // 靠右对齐
        'SpaceBetween': FlexAlign.SpaceBetween, // 两端对齐，中间留白
        'SpaceAround': FlexAlign.SpaceAround,   // 每个元素两侧留白相同
        'SpaceEvenly': FlexAlign.SpaceEvenly    // 元素之间及边缘留白完全相同
      };

      if (justifyMap[justifyStr] !== undefined) {
        instance.justifyContent(justifyMap[justifyStr]);
      } else {
        instance.justifyContent(FlexAlign.Start);
      }
    }

    // ==========================================
    // 3. 交叉轴对齐方式 (垂直方向的对齐)
    // 对应 ArkUI 的 alignItems -> VerticalAlign 枚举
    // ==========================================
    if (this.props['alignItems'] !== undefined) {
      let alignStr = String(this.props['alignItems']);

      // 注意：Row 的交叉轴是垂直方向，使用的是 VerticalAlign！
      let alignMap: Record<string, VerticalAlign> = {
        'Top': VerticalAlign.Top,       // 顶部对齐
        'Center': VerticalAlign.Center, // 垂直居中 (默认)
        'Bottom': VerticalAlign.Bottom  // 底部对齐
      };

      // 容错处理：如果习惯性地写成了 Start/End，引擎自动纠正为 Top/Bottom
      if (alignStr === 'Start') alignStr = 'Top';
      if (alignStr === 'End') alignStr = 'Bottom';

      if (alignMap[alignStr] !== undefined) {
        instance.alignItems(alignMap[alignStr]);
      } else {
        instance.alignItems(VerticalAlign.Center);
      }
    }
  }
}