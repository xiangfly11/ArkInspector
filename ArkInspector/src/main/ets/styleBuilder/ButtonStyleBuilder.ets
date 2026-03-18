/**
 * Date: 2026/3/18
 * File Name: ButtonStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class ButtonStyleBuilder extends BaseStyleBuilder<ButtonStyleBuilder> {
  protected getSelf(): ButtonStyleBuilder {
    return this;
  }

  // 按钮类型（胶囊、圆形、普通等）
  type(value: ButtonType | number): ButtonStyleBuilder {
    this.styleObj['type'] = value as number as JsonValue;
    return this;
  }

  // 是否开启点击按压态效果
  stateEffect(value: boolean): ButtonStyleBuilder {
    this.styleObj['stateEffect'] = value as JsonValue;
    return this;
  }

  fontColor(value: ResourceColor): ButtonStyleBuilder {
    this.styleObj['fontColor'] = value as JsonValue;
    return this;
  }

  fontSize(value: number | string): ButtonStyleBuilder {
    this.styleObj['fontSize'] = value as JsonValue;
    return this;
  }

  fontWeight(value: FontWeight | string | number): ButtonStyleBuilder {
    this.styleObj['fontWeight'] = value as JsonValue;
    return this;
  }
}