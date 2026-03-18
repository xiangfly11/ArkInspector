/**
 * Date: 2026/3/17
 * File Name: TextStyleBuilder.ets
 * Author: Jason
 **/
import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";


// ==========================================
// 文本专属 Builder：继承基类
// ==========================================
export class TextStyleBuilder extends BaseStyleBuilder<TextStyleBuilder> {

  // 💥 实现父类的抽象方法，仅需这一行，将 this 暴露出去
  protected getSelf(): TextStyleBuilder {
    return this;
  }

  // --- Text 专属属性 ---
  fontSize(value: number | string): TextStyleBuilder {
    this.styleObj['fontSize'] = value as JsonValue;
    return this;
  }

  fontColor(value: ResourceColor): TextStyleBuilder {
    this.styleObj['fontColor'] = value as JsonValue;
    return this;
  }

  fontWeight(value: FontWeight | string): TextStyleBuilder {
    this.styleObj['fontWeight'] = value as JsonValue;
    return this;
  }

  textAlign(value: TextAlign | string): TextStyleBuilder {
    this.styleObj['textAlign'] = value as JsonValue;
    return this;
  }

  maxLines(value: number): TextStyleBuilder {
    this.styleObj['maxLines'] = value as JsonValue;
    return this;
  }
}