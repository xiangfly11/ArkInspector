/**
 * Date: 2026/2/27
 * File Name: DynamicImageModifier.ets
 * Author: Jason
 **/
import { DynamicBaseModifier } from "./DynamicBaseModifier";

export class DynamicImageModifier extends DynamicBaseModifier implements AttributeModifier<ImageAttribute> {

  applyNormalAttribute(instance: ImageAttribute): void {
    // 1. 继承基类：瞬间获得宽高、边距、阴影、以及最重要的 borderRadius（圆角裁切）能力
    super.applyNormalAttribute(instance);

    if (!this.props) return;

    // ==========================================
    // 2. 缩放与裁剪模式 (ObjectFit)
    // 对应 ArkUI 的 objectFit -> ImageFit 枚举
    // ==========================================
    if (this.props['objectFit'] !== undefined) {
      let fitStr = String(this.props['objectFit']).toLowerCase();

      let fitMap: Record<string, ImageFit> = {
        'cover': ImageFit.Cover,         // 保持宽高比缩放并裁剪 (新闻封面图最常用)
        'contain': ImageFit.Contain,     // 保持宽高比缩放，显示完整图片，可能留白
        'fill': ImageFit.Fill,           // 拉伸填满，会变形
        'scaledown': ImageFit.ScaleDown, // 保持宽高比，缩小或保持原样
        'auto': ImageFit.Auto,
        'none': ImageFit.None
      };

      // 摄影应用通常默认使用 Cover，保证排版填满且不变形
      instance.objectFit(fitMap[fitStr] ?? ImageFit.Cover);
    }

    // ==========================================
    // 3. 占位图 (Alt) - 在网络图片加载出来前显示
    // ==========================================
    if (this.props['alt'] !== undefined) {
      instance.alt(this.props['alt'] as string);
    }

    // ==========================================
    // 4. 渲染质量 (Interpolation)
    // 强制开启高画质插值，防止图片在缩放时产生锯齿和伪影噪点
    // ==========================================
    instance.interpolation(ImageInterpolation.High);
  }
}