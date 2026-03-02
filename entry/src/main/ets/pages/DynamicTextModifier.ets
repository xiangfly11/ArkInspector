/**
 * Date: 2026/2/27
 * File Name: DynamicTextModifier.ets
 * Author: Jason
 **/
import { DynamicBaseModifier } from "./DynamicBaseModifier";

export class DynamicTextModifier extends DynamicBaseModifier implements AttributeModifier<TextAttribute> {

  applyNormalAttribute(instance: TextAttribute): void {
    // 1. 继承基类：获得宽高、边距、背景、阴影等通用能力
    super.applyNormalAttribute(instance);

    if (!this.props) return;

    // ==========================================
    // 1. 基础字体设置 (Font & Typography)
    // ==========================================
    if (this.props['fontSize'] !== undefined) {
      instance.fontSize(this.props['fontSize'] as number | string);
    }
    if (this.props['fontColor'] !== undefined) {
      instance.fontColor(this.props['fontColor'] as ResourceColor);
    }
    if (this.props['fontWeight'] !== undefined) {
      let weightStr = String(this.props['fontWeight']).toLowerCase();
      if (weightStr === 'bolder') {
        instance.fontWeight(FontWeight.Bolder);
      } else if (weightStr === 'bold') {
        instance.fontWeight(FontWeight.Bold);
      } else if (weightStr === 'medium') {
        instance.fontWeight(FontWeight.Medium);
      } else if (weightStr === 'regular') {
        instance.fontWeight(FontWeight.Regular);
      } else if (weightStr === 'normal') {
        instance.fontWeight(FontWeight.Normal)
      } else if (weightStr === 'lighter') {
        instance.fontWeight(FontWeight.Lighter);
      }
    }
    if (this.props['fontStyle'] !== undefined) {
      let styleStr = String(this.props['fontStyle']).toLowerCase();
      instance.fontStyle(styleStr === 'italic' ? FontStyle.Italic : FontStyle.Normal);
    }
    if (this.props['fontFamily'] !== undefined) {
      instance.fontFamily(this.props['fontFamily'] as string);
    }
    if (this.props['letterSpacing'] !== undefined) {
      instance.letterSpacing(this.props['letterSpacing'] as number | string);
    }

    // ==========================================
    // 2. 段落与排版控制 (Paragraph & Layout)
    // ==========================================
    if (this.props['lineHeight'] !== undefined) {
      instance.lineHeight(this.props['lineHeight'] as number | string);
    }
    if (this.props['textAlign'] !== undefined) {
      let alignStr = String(this.props['textAlign']).toLowerCase();
      let alignMap: Record<string, TextAlign> = {
        'start': TextAlign.Start,
        'center': TextAlign.Center,
        'end': TextAlign.End,
        'justify': TextAlign.JUSTIFY // 两端对齐，传媒应用正文极度推荐
      };
      instance.textAlign(alignMap[alignStr] ?? TextAlign.Start);
    }

    // ==========================================
    // 3. 截断与省略 (Truncation & Overflow)
    // ==========================================
    // 注意：在 ArkUI 中，maxLines 和 textOverflow 通常需要成对出现才能生效
    let hasMaxLines = this.props['maxLines'] !== undefined;
    if (hasMaxLines) {
      instance.maxLines(this.props['maxLines'] as number);
    }

    if (this.props['textOverflow'] !== undefined) {
      let overflowStr = String(this.props['textOverflow']).toLowerCase();
      let overflowMap: Record<string, TextOverflow> = {
        'clip': TextOverflow.Clip,         // 直接裁剪
        'ellipsis': TextOverflow.Ellipsis, // 省略号
        'none': TextOverflow.None          // 不裁剪
      };
      instance.textOverflow({ overflow: overflowMap[overflowStr] ?? TextOverflow.Clip });
    } else if (hasMaxLines) {
      // 容错：如果后端只发了 maxLines 没发 textOverflow，默认给个省略号保护
      instance.textOverflow({ overflow: TextOverflow.Ellipsis });
    }

    // ==========================================
    // 4. 装饰与交互 (Decoration & Interaction)
    // ==========================================
    if (this.props['decoration'] !== undefined) {
      let decoStr = String(this.props['decoration']).toLowerCase();
      let decoMap: Record<string, TextDecorationType> = {
        'underline': TextDecorationType.Underline,   // 下划线
        'linethrough': TextDecorationType.LineThrough, // 删除线 (如原价)
        'overline': TextDecorationType.Overline,     // 顶划线
        'none': TextDecorationType.None
      };
      instance.decoration({
        type: decoMap[decoStr] ?? TextDecorationType.None,
        color: (this.props['decorationColor'] as ResourceColor) ?? this.props['fontColor'] as ResourceColor ?? Color.Black// 装饰线颜色默认跟随字体
      });
    }

    if (this.props['copyOption'] !== undefined) {
      let copyStr = String(this.props['copyOption']).toLowerCase();
      let copyMap: Record<string, CopyOptions> = {
        'none': CopyOptions.None,             // 不可复制
        'inapp': CopyOptions.InApp,           // 仅应用内复制
        'localdevice': CopyOptions.LocalDevice, // 跨应用复制
      };
      instance.copyOption(copyMap[copyStr] ?? CopyOptions.None);
    }
  }
}