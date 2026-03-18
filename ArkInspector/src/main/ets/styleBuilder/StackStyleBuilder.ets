/**
 * Date: 2026/3/18
 * File Name: StackStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class StackStyleBuilder extends BaseStyleBuilder<StackStyleBuilder> {
  protected getSelf(): StackStyleBuilder {
    return this;
  }

  // Stack 内部元素的对齐方式
  alignContent(value: Alignment | number): StackStyleBuilder {
    this.styleObj['alignContent'] = value as number as JsonValue;
    return this;
  }
}