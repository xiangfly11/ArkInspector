/**
 * Date: 2026/2/27
 * File Name: DynamicBaseModifier.ets
 * Author: Jason
 **/

// 定义全局的动态值类型
export type JsonValue = string | number | boolean | Object | undefined;

export class DynamicBaseModifier implements AttributeModifier<CommonAttribute> {
  protected props: Record<string, JsonValue>;

  constructor(props: Record<string, JsonValue>) {
    this.props = props;
  }

  // 系统底层调用的核心方法：将 JSON 属性映射为 ArkUI 基础属性
  applyNormalAttribute(instance: CommonAttribute): void {
    if (!this.props) return;

    // ==========================================
    // 1. 尺寸与布局权重 (Size & Weight)
    // ==========================================
    if (this.props['width'] !== undefined) {
      instance.width(this.props['width'] as Length);
    }
    if (this.props['height'] !== undefined) {
      instance.height(this.props['height'] as Length);
    }
    if (this.props['layoutWeight'] !== undefined) {
      instance.layoutWeight(this.props['layoutWeight'] as number);
    }

    // ==========================================
    // 2. 间距控制 (Margin & Padding)
    // ==========================================
    if (this.props['margin'] !== undefined) {
      // 调用辅助方法，智能解析单值或对象
      instance.margin(this.parseSpace(this.props['margin']) as Margin);
    }
    if (this.props['padding'] !== undefined) {
      instance.padding(this.parseSpace(this.props['padding']) as Padding);
    }

    // ==========================================
    // 3. 背景与外观 (Background & Appearance)
    // ==========================================
    if (this.props['backgroundColor'] !== undefined) {
      instance.backgroundColor(this.props['backgroundColor'] as ResourceColor);
    }
    if (this.props['opacity'] !== undefined) {
      instance.opacity(this.props['opacity'] as number);
    }
    if (this.props['borderRadius'] !== undefined) {
      // 圆角同样支持单值或四个角的独立设置
      instance.borderRadius(this.parseSpace(this.props['borderRadius']) as BorderRadiuses);
    }

    // ==========================================
    // 4. 显示控制 (Visibility)
    // ==========================================
    if (this.props['visibility'] !== undefined) {
      let visStr = this.props['visibility'] as string;
      if (visStr === 'Hidden') {
        instance.visibility(Visibility.Hidden);
      } else if (visStr === 'None') {
        instance.visibility(Visibility.None); // 不占位隐藏
      } else {
        instance.visibility(Visibility.Visible);
      }
    }

    // ==========================================
    // 5. 边框 (Border) 简单示例
    // ==========================================
    if (this.props['borderWidth'] !== undefined) {
      instance.borderWidth(this.parseSpace(this.props['borderWidth']) as EdgeWidths);
    }
    if (this.props['borderColor'] !== undefined) {
      instance.borderColor(this.props['borderColor'] as ResourceColor);
    }

    // ==========================================
    // 6. 渐变色层 (Gradient Layer)
    // ==========================================
    if (this.props['linearGradient'] !== undefined) {
      let gradientObj = this.props['linearGradient'] as Record<string, JsonValue>;

      // 1. 解析颜色断点 (Color Stops)
      let parsedColors: Array<[ResourceColor, number]> = [];
      let rawColors = gradientObj['colors'] as Array<Array<string | number>>;

      if (rawColors && Array.isArray(rawColors)) {
        for (let i = 0; i < rawColors.length; i++) {
          let colorPair = rawColors[i];
          // 确保是 [颜色字符串, 位置数字] 的元组格式
          if (Array.isArray(colorPair) && colorPair.length >= 2) {
            parsedColors.push([colorPair[0] as ResourceColor, colorPair[1] as number]);
          }
        }
      }

      // 2. 解析渐变方向 (枚举映射)
      let direction: GradientDirection | undefined = undefined;
      if (gradientObj['direction'] !== undefined) {
        let dirStr = gradientObj['direction'] as string;
        let dirMap: Record<string, GradientDirection> = {
          'Left': GradientDirection.Left,
          'Right': GradientDirection.Right,
          'Top': GradientDirection.Top,
          'Bottom': GradientDirection.Bottom,
          'LeftTop': GradientDirection.LeftTop,
          'LeftBottom': GradientDirection.LeftBottom,
          'RightTop': GradientDirection.RightTop,
          'RightBottom': GradientDirection.RightBottom,
        };
        direction = dirMap[dirStr];
      }

      // 3. 解析渐变角度 (如果传入了角度，则方向参数会失效)
      let angle: number | string | undefined = undefined;
      if (gradientObj['angle'] !== undefined) {
        angle = gradientObj['angle'] as number | string;
      }

      // 4. 应用到 ArkUI 底层实例
      if (parsedColors.length > 0) {
        instance.linearGradient({
          angle: angle,
          direction: direction,
          colors: parsedColors
        });
      }
    }

    // ==========================================
    // 7. 阴影层 (Shadow Layer)
    // ==========================================
    if (this.props['shadow'] !== undefined) {
      let shadowProp = this.props['shadow'];

      // 场景 A：使用系统预设样式的阴影 (极少用到，但兼容)
      if (typeof shadowProp === 'number') {
        // ArkUI 提供了 ShadowStyle.OUTER_DEFAULT_XS 等预设枚举
        instance.shadow(shadowProp as ShadowStyle);
      }
      // 场景 B：自定义阴影参数 (核心业务场景)
      else if (typeof shadowProp === 'object' && shadowProp !== null) {
        let shadowObj = shadowProp as Record<string, JsonValue>;

        // ArkUI 的 shadow 要求 radius 是必填项，其他是可选项
        let radiusValue = shadowObj['radius'] as number;

        if (radiusValue !== undefined) {
          let shadowOptions: ShadowOptions = {
            radius: radiusValue,
            // 映射颜色，如果没传则默认给个极淡的黑色
            color: (shadowObj['color'] as string) ?? '#1A000000',
            // 映射 X 轴偏移
            offsetX: (shadowObj['offsetX'] as number) ?? 0,
            // 映射 Y 轴偏移
            offsetY: (shadowObj['offsetY'] as number) ?? 0,
            // 默认类型为纯色模糊阴影
            type: ShadowType.COLOR
          };

          instance.shadow(shadowOptions);
        }
      }
    }
  }

  // ==========================================
  // 核心辅助方法：智能解析混合类型的数值
  // 完美处理 JSON 中的: 10, "100%", 或者 {"top": 10, "left": 5}
  // ==========================================
  protected parseSpace(value: JsonValue): Length | Padding | Margin | EdgeWidths | BorderRadiusType {
    // 场景 A：纯数字或百分比字符串
    if (typeof value === 'number' || typeof value === 'string') {
      return value as Length;
    }

    // 场景 B：复杂的对象描述
    if (typeof value === 'object' && value !== null) {
      let obj = value as Record<string, JsonValue>;
      // 利用 TypeScript 的结构化类型，拼装一个包含所有可能方向的对象
      return {
        top: obj['top'] as Length,
        bottom: obj['bottom'] as Length,
        left: obj['left'] as Length,
        right: obj['right'] as Length,
        topLeft: obj['topLeft'] as Length,
        topRight: obj['topRight'] as Length,
        bottomLeft: obj['bottomLeft'] as Length,
        bottomRight: obj['bottomRight'] as Length
      };
    }
    return 0;
  }
}