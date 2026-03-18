/**
 * Date: 2026/3/18
 * File Name: ImageStyleBuilder.ets
 * Author: Jason
 **/

import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { BaseStyleBuilder } from "./BaseStyleBuilder";

export class ImageStyleBuilder extends BaseStyleBuilder<ImageStyleBuilder> {
  protected getSelf(): ImageStyleBuilder {
    return this;
  }

  objectFit(value: ImageFit | number): ImageStyleBuilder {
    this.styleObj['objectFit'] = value as number as JsonValue;
    return this;
  }

  objectRepeat(value: ImageRepeat | number): ImageStyleBuilder {
    this.styleObj['objectRepeat'] = value as number as JsonValue;
    return this;
  }

  fillColor(value: ResourceColor): ImageStyleBuilder {
    this.styleObj['fillColor'] = value as JsonValue;
    return this;
  }

  interpolation(value: ImageInterpolation | number): ImageStyleBuilder {
    this.styleObj['interpolation'] = value as number as JsonValue;
    return this;
  }
}