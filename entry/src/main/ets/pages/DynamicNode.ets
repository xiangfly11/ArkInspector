/**
 * Date: 2026/2/26
 * File Name: DynamicNode.ets
 * Author: Jason
 **/

export type JsonValue = string | number | boolean | Object | undefined;
export class DynamicNode {
  type: string;
  props: Record<string, JsonValue>;
  children?: DynamicNode[];

  constructor(type: string, props: Record<string, JsonValue>, children?: DynamicNode[]) {
    this.type = type;
    this.props = props;
    this.children = children;
  }
}