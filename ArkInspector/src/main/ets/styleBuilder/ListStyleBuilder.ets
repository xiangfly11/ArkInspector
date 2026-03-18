/**
 * Date: 2026/3/18
 * File Name: ListStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export interface ListDividerOptions {
  strokeWidth: Length;
  color?: ResourceColor;
  startMargin?: Length;
  endMargin?: Length;
}

export class ListStyleBuilder extends BaseStyleBuilder<ListStyleBuilder> {
  protected getSelf(): ListStyleBuilder {
    return this;
  }

  listDirection(value: Axis | number): ListStyleBuilder {
    this.styleObj['listDirection'] = value as number as JsonValue;
    return this;
  }

  space(value: number | string): ListStyleBuilder {
    this.styleObj['space'] = value as JsonValue;
    return this;
  }

  scrollBar(value: BarState | number): ListStyleBuilder {
    this.styleObj['scrollBar'] = value as number as JsonValue;
    return this;
  }

  divider(value: ListDividerOptions): ListStyleBuilder {
    let dividerObj: Record<string, Object> = {};

    dividerObj['strokeWidth'] = value.strokeWidth as Object;

    if (value.color !== undefined) {
      dividerObj['color'] = value.color as Object;
    }
    if (value.startMargin !== undefined) {
      dividerObj['startMargin'] = value.startMargin as Object;
    }
    if (value.endMargin !== undefined) {
      dividerObj['endMargin'] = value.endMargin as Object;
    }

    this.styleObj['divider'] = dividerObj;

    return this;
  }
}