/**
 * Date: 2026/3/18
 * File Name: FlexStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class FlexStyleBuilder extends BaseStyleBuilder<FlexStyleBuilder> {
  protected getSelf(): FlexStyleBuilder {
    return this;
  }

  direction(value: FlexDirection | number): FlexStyleBuilder {
    this.styleObj['direction'] = value as number as JsonValue;
    return this;
  }

  wrap(value: FlexWrap | number): FlexStyleBuilder {
    this.styleObj['wrap'] = value as number as JsonValue;
    return this;
  }

  justifyContent(value: FlexAlign | number): FlexStyleBuilder {
    this.styleObj['justifyContent'] = value as number as JsonValue;
    return this;
  }

  alignItems(value: ItemAlign | number): FlexStyleBuilder {
    this.styleObj['alignItems'] = value as number as JsonValue;
    return this;
  }

  alignContent(value: FlexAlign | number): FlexStyleBuilder {
    this.styleObj['alignContent'] = value as number as JsonValue;
    return this;
  }
}