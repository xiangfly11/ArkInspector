/**
 * Date: 2026/3/12
 * File Name: DebugManager.ets
 * Author: Jason
 * Description: 全局调试对象注册表 (ArkTS 严格模式版)
 **/

export type UpdateCallback = (newVal: ESObject) => void;

export class DebugEntry {
  data: ESObject;
  updater: UpdateCallback;
  constructor(data: ESObject, updater: UpdateCallback) {
    this.data = data;
    this.updater = updater;
  }
}

export class DebugManager {
  private static registry: Map<string, DebugEntry> = new Map();

  static register(name: string, data: ESObject, updater: UpdateCallback) {
    DebugManager.registry.set(name, new DebugEntry(data, updater));
  }

  static unregister(name: string) {
    DebugManager.registry.delete(name);
  }

  static getBinding(name: string): DebugEntry | undefined {
    return DebugManager.registry.get(name);
  }

  static getAvailableKeys(): string[] {
    let keys: string[] = [];
    for (let key of DebugManager.registry.keys()) {
      keys.push(key);
    }
    return keys;
  }

  // 全局主动通知方法，用于跨组件派发数据（比如分发盒模型坐标）
  static notify(name: string, newVal: ESObject) {
    let entry = DebugManager.registry.get(name);
    if (entry && entry.updater) {
      entry.updater(newVal);
    }
  }
}