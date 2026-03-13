/**
 * Date: 2026/2/27
 * File Name: DynamicColumnModifier.ets
 * Author: Jason
 **/
import { DynamicBaseModifier } from "./DynamicBaseModifier";

export class DynamicColumnModifier extends DynamicBaseModifier implements AttributeModifier<ColumnAttribute> {

  constructor(props: Record<string, Object>, dynamicId?: string) {
    super(props, dynamicId);
  }

  applyNormalAttribute(instance: ColumnAttribute): void {
    // 1. 极其关键：调用基类，继承所有宽高、边距、背景、阴影等通用基础能力
    super.applyNormalAttribute(instance);

    // ==========================================
    // 2. 主轴对齐方式 (垂直方向的排版分布)
    // 对应 ArkUI 的 justifyContent -> FlexAlign 枚举
    // ==========================================
    if (this.props['justifyContent'] !== undefined) {
      let justifyStr = String(this.props['justifyContent']);

      // 构建字符串到系统枚举的强类型映射字典
      let justifyMap: Record<string, FlexAlign> = {
        'Start': FlexAlign.Start,               // 顶部对齐 (默认)
        'Center': FlexAlign.Center,             // 居中对齐
        'End': FlexAlign.End,                   // 底部对齐
        'SpaceBetween': FlexAlign.SpaceBetween, // 两端对齐，中间留白
        'SpaceAround': FlexAlign.SpaceAround,   // 每个元素两侧留白相同
        'SpaceEvenly': FlexAlign.SpaceEvenly    // 元素之间及边缘留白完全相同
      };

      if (justifyMap[justifyStr] !== undefined) {
        instance.justifyContent(justifyMap[justifyStr]);
      } else {
        // 容错机制：如果后端下发了拼写错误的对齐方式，默认置顶
        instance.justifyContent(FlexAlign.Start);
      }
    }

    // ==========================================
    // 3. 交叉轴对齐方式 (水平方向的对齐)
    // 对应 ArkUI 的 alignItems -> HorizontalAlign 枚举
    // ==========================================
    if (this.props['alignItems'] !== undefined) {
      let alignStr = String(this.props['alignItems']);

      let alignMap: Record<string, HorizontalAlign> = {
        'Start': HorizontalAlign.Start,   // 左对齐
        'Center': HorizontalAlign.Center, // 水平居中 (默认)
        'End': HorizontalAlign.End        // 右对齐
      };

      if (alignMap[alignStr] !== undefined) {
        instance.alignItems(alignMap[alignStr]);
      } else {
        instance.alignItems(HorizontalAlign.Center);
      }
    }
  }
}