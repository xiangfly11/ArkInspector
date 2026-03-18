/**
 * Date: 2026/3/18
 * File Name: RowStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class RowStyleBuilder extends BaseStyleBuilder<RowStyleBuilder> {
  protected getSelf(): RowStyleBuilder {
    return this;
  }

  // Row 的主轴对齐方式
  justifyContent(value: FlexAlign | number): RowStyleBuilder {
    this.styleObj['justifyContent'] = value as number as JsonValue;
    return this;
  }

  // Row 的交叉轴对齐方式（注意与 Column 不同，这里是 VerticalAlign）
  alignItems(value: VerticalAlign | number): RowStyleBuilder {
    this.styleObj['alignItems'] = value as number as JsonValue;
    return this;
  }
}