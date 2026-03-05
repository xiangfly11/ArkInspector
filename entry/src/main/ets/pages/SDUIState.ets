/**
 * Date: 2026/3/5
 * File Name: SDUIState.ets
 * Author: Jason
 **/


import { JsonValue } from './DynamicNode';

// 1. 【V2魔法】：将每一个独立的数据包装成可深度追踪的对象
@ObservedV2
export class SDUIStateItem {
  @Trace value: JsonValue; // 任何对 value 的修改，都会被 ArkUI 引擎精准捕获

  constructor(val: JsonValue) {
    this.value = val;
  }
}

export class SDUIState {
  // 状态大字典
  private items: Record<string, SDUIStateItem> = {};

  constructor(initialData: Record<string, JsonValue>) {
    let keys = Object.keys(initialData);
    for (let i = 0; i < keys.length; i++) {
      let k = keys[i];
      this.items[k] = new SDUIStateItem(initialData[k]);
    }
  }

  // 获取状态对象（支持动态新增兜底）
  getItem(key: string): SDUIStateItem {
    if (!this.items[key]) {
      this.items[key] = new SDUIStateItem('');
    }
    return this.items[key];
  }

  // 修改单个状态
  updateState(key: string, value: JsonValue) {
    this.getItem(key).value = value; // 赋值瞬间，精准触发 UI 局部重绘！
  }

  // 批量修改状态（常用于网络请求成功后）
  updateMutations(mutations: Array<Record<string, JsonValue>>) {
    for (let i = 0; i < mutations.length; i++) {
      let m = mutations[i];
      let key = m['stateKey'] as string;
      let val = m['value'];
      if (key !== undefined && val !== undefined) {
        this.updateState(key, val);
      }
    }
  }
}