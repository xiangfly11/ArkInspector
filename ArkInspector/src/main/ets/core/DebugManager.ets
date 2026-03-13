/**
 * Date: 2026/3/12
 * File Name: DebugManager.ets
 * Author: Jason
 * Description: 全局调试对象注册表 (ArkTS 严格模式版)
 **/

// 定义回调函数的类型
export type UpdateCallback = (newVal: ESObject) => void;

// 💥 破局点 1：定义一个标准的 Class 来替代报错的匿名对象 {}
export class DebugEntry {
  data: ESObject;
  updater: UpdateCallback;

  constructor(data: ESObject, updater: UpdateCallback) {
    this.data = data;
    this.updater = updater;
  }
}

export class DebugManager {
  // 💥 破局点 2：Map 的值类型使用我们刚定义的 DebugEntry 类
  private static registry: Map<string, DebugEntry> = new Map();

  static register(name: string, data: ESObject, updater: UpdateCallback) {
    // 💥 破局点 3：静态方法中必须用类名 DebugManager 去调用静态属性
    // 并且用 new DebugEntry() 的方式去实例化，彻底消灭匿名对象
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
    // 同样替换这里的 this
    for (let key of DebugManager.registry.keys()) {
      keys.push(key);
    }
    return keys;
  }
}