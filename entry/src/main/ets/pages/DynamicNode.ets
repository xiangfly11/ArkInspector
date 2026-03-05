/**
 * Date: 2026/2/26
 * File Name: DynamicNode.ets
 * Author: Jason
 **/

export type JsonValue = string | number | boolean | Object | undefined;

export interface EventConfig {
  actionType: string; // 比如 "toast", "route", "request"
  params?: Record<string, JsonValue>; // 事件透传的参数
}

export class DynamicNode {
  type: string;
  props: Record<string, JsonValue>;
  events?: Record<string, EventConfig>;
  children?: DynamicNode[];

  constructor(type: string, props: Record<string, JsonValue>, events?: Record<string, EventConfig>,
    children?: DynamicNode[]) {
    this.type = type;
    this.props = props;
    this.events = events;
    this.children = children;
  }
}