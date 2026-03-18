/**
 * Date: 2026/3/17
 * File Name: BaseStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from '../modifiers/DynamicBaseModifier';

// ==========================================
// 基类 Builder：使用泛型 T，并声明抽象 getSelf 方法
// ==========================================
export abstract class BaseStyleBuilder<T> {
  protected styleObj: Record<string, JsonValue> = {};

  // 💥 核心魔法：定义一个抽象方法，强制子类把自己的实例“喂”给父类
  protected abstract getSelf(): T;

  constructor(initialStyle?: Record<string, Object>) {
    if (initialStyle) {
      let keys = Object.keys(initialStyle);
      for (let i = 0; i < keys.length; i++) {
        let key = keys[i];
        // 逐个赋值，将 Object 安全地断言为 JsonValue
        this.styleObj[key] = initialStyle[key] as JsonValue;
      }
    }
  }

  /**
   * 快速克隆旧样式，并更新/新增【单个】属性（触发状态刷新的利器）
   */
  static updateProp(oldStyle: Record<string, Object>, key: string, value: JsonValue): Record<string, Object> {
    let newStyle: Record<string, Object> = {};
    if (oldStyle) {
      let keys = Object.keys(oldStyle);
      for (let i = 0; i < keys.length; i++) {
        newStyle[keys[i]] = oldStyle[keys[i]];
      }
    }
    // 覆盖新属性
    newStyle[key] = value as Object;
    return newStyle;
  }

  // --- 所有通用属性，只需在这里写一遍！ ---
  width(value: Length): T {
    this.styleObj['width'] = value as JsonValue;
    return this.getSelf(); // 不再强转，直接调用 getSelf() 返回子类实例！
  }

  height(value: Length): T {
    this.styleObj['height'] = value as JsonValue;
    return this.getSelf();
  }

  layoutWeight(value: number): T {
    this.styleObj['layoutWeight'] = value as JsonValue;
    return this.getSelf();
  }

  padding(value: Padding | Length): T {
    this.styleObj['padding'] = value as JsonValue;
    return this.getSelf();
  }

  margin(value: Margin | Length): T {
    this.styleObj['margin'] = value as JsonValue;
    return this.getSelf();
  }

  backgroundColor(value: ResourceColor): T {
    this.styleObj['backgroundColor'] = value as JsonValue;
    return this.getSelf();
  }

  borderRadius(value: BorderRadiuses | Length): T {
    this.styleObj['borderRadius'] = value as JsonValue;
    return this.getSelf();
  }

  // 💥 最终输出
  build(): Record<string, Object> {
    return this.styleObj as Record<string, Object>;
  }
}