/**
 * Date: 2026/2/27
 * File Name: DynamicBaseModifier.ets
 * Author: Jason
 * Description: ArkUI 动态属性修饰器基类 (包含可视化盒模型坐标抓取引擎)
 **/

import { DebugManager } from '../core/DebugManager';
import { UIInspector } from '../core/UIInspector';

// 定义 JSON 支持的通用数据类型，供其他控制器使用
export type JsonValue = string | number | boolean | object | null | undefined;

export class DynamicBaseModifier implements AttributeModifier<CommonAttribute> {
  public props: Record<string, Object>;
  public dynamicId: string;

  // 💥 核心新增：坐标缓存器
  // 用于在 ArkUI 没有触发尺寸变更，但组件发生了 state 重绘时，依然能向画板上报自己的位置
  private currentArea: Area | null = null;

  constructor(props: Record<string, Object>, dynamicId: string = '') {
    this.props = props;
    this.dynamicId = dynamicId;
  }

  // 辅助方法：将字典里的 margin/padding 安全地转为 ArkUI 认识的格式
  protected parseSpace(val: Object | undefined): number | string | Padding | Margin {
    if (typeof val === 'number' || typeof val === 'string') {
      return val;
    }
    if (typeof val === 'object' && val !== null) {
      return val as Record<string, string | number>;
    }
    return 0;
  }

  // 核心拦截渲染方法
  applyNormalAttribute(instance: CommonAttribute): void {
    // 1. 获取组件的唯一标识
    let inspectId = this.dynamicId ? this.dynamicId : (this.props['inspectId'] as string);

    // ==========================================
    // 🎨 基础样式解析区 (从字典提取属性应用到组件)
    // ==========================================
    if (this.props['width'] !== undefined) {
      instance.width(this.props['width'] as Length);
    }
    if (this.props['height'] !== undefined) {
      instance.height(this.props['height'] as Length);
    }
    if (this.props['backgroundColor'] !== undefined) {
      instance.backgroundColor(this.props['backgroundColor'] as ResourceColor);
    }
    if (this.props['margin'] !== undefined) {
      instance.margin(this.parseSpace(this.props['margin']) as Margin);
    }
    if (this.props['padding'] !== undefined) {
      instance.padding(this.parseSpace(this.props['padding']) as Padding);
    }
    if (this.props['borderRadius'] !== undefined) {
      instance.borderRadius(this.parseSpace(this.props['borderRadius']) as Length | BorderRadiuses);
    }
    if (this.props['opacity'] !== undefined) {
      instance.opacity(this.props['opacity'] as number);
    }

    // 你可以在这里继续补充你需要的解析（比如 alignment, layoutWeight 等）
    if (this.props['layoutWeight'] !== undefined) {
      instance.layoutWeight(this.props['layoutWeight'] as number);
    }

    // ==========================================
    // 💥 审查模式：红框高亮与主动上报 (核心逻辑)
    // ==========================================
    if (UIInspector.isInspectMode && inspectId && UIInspector.selectedId === inspectId) {
      // 1. 绘制红框
      instance.border({ width: 2, color: '#FF0000', style: BorderStyle.Dashed });

      // 2. 主动上报：组件一旦重绘，立刻把“最新缓存的坐标”和“最新修改的边距”推给全屏画板
      if (this.currentArea) {
        DebugManager.notify("BoxModelRect", {
          area: this.currentArea,
          style: this.props
        });
      }
    } else {
      // 如果没有被选中，恢复为正常边框
      // 为了严谨，这里读取业务原本是否配置了 border，如果没有则置零
      let defaultBorderWidth = this.props['borderWidth'] !== undefined ? this.props['borderWidth'] : 0;
      let defaultBorderColor = this.props['borderColor'] !== undefined ? this.props['borderColor'] : Color.Transparent;
      let defaultBorderStyle = this.props['borderStyle'] !== undefined ? this.props['borderStyle'] : BorderStyle.Solid;

      instance.border({
        width: defaultBorderWidth as Length,
        color: defaultBorderColor as ResourceColor,
        style: defaultBorderStyle as BorderStyle
      });
    }

    // ==========================================
    // 💥 尺寸抓取引擎：监听物理像素变化
    // ==========================================
    instance.onAreaChange((oldValue: Area, newValue: Area) => {
      // 只要发生排版变化，立刻更新缓存
      this.currentArea = newValue;

      // 如果自己恰好正在被审查，立刻把最新坐标推给全屏画板，让绿橙蓝遮罩“紧跟”自己
      if (UIInspector.isInspectMode && inspectId && UIInspector.selectedId === inspectId) {
        DebugManager.notify("BoxModelRect", {
          area: newValue,
          style: this.props
        });
      }
    });
  }
}