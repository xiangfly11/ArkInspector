/**
 * Date: 2026/3/17
 * File Name: ColumnStyleBuilder.ets
 * Author: Jason
 **/
import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class ColumnStyleBuilder extends BaseStyleBuilder<ColumnStyleBuilder> {

  // 💥 同样实现 getSelf
  protected getSelf(): ColumnStyleBuilder {
    return this;
  }

  justifyContent(value: FlexAlign | number): ColumnStyleBuilder {
    this.styleObj['justifyContent'] = value as number as JsonValue;
    return this;
  }

  alignItems(value: HorizontalAlign | number): ColumnStyleBuilder {
    this.styleObj['alignItems'] = value as number as JsonValue;
    return this;
  }
}