/**
 * Date: 2026/3/5
 * File Name: SDUIActions.ets
 * Author: Jason
 **/

import { promptAction } from '@kit.ArkUI';
import { JsonValue } from './DynamicNode';
import { SDUIState } from './SDUIState';

// 统一的动作处理器接口
export interface SDUIActionHandler {
  execute(params: Record<string, JsonValue>, stateContext: SDUIState): Promise<void>;
}

// 动作 1：纯本地状态突变
export class UpdateStateAction implements SDUIActionHandler {
  async execute(params: Record<string, JsonValue>, stateContext: SDUIState): Promise<void> {
    let mutations = params['mutations'] as Array<Record<string, JsonValue>>;
    if (mutations) stateContext.updateMutations(mutations);
  }
}

// 动作 2：轻提示弹窗
export class ShowToastAction implements SDUIActionHandler {
  async execute(params: Record<string, JsonValue>, stateContext: SDUIState): Promise<void> {
    let msg = params['message'] as string;
    if (msg) promptAction.showToast({ message: msg });
  }
}

// 动作 3：通用网络请求驱动
export class HttpRequestAction implements SDUIActionHandler {
  async execute(params: Record<string, JsonValue>, stateContext: SDUIState): Promise<void> {
    let url = params['url'] as string;
    let method = (params['method'] as string) ?? 'GET';

    //  1. 请求开始前：触发锁定状态（如：按钮变灰、文字变“请求中”）
    let startMutations = params['onStartMutations'] as Array<Record<string, JsonValue>>;
    if (startMutations) stateContext.updateMutations(startMutations);

    try {
      console.info(`[SDUI Action] 正在发起网络请求 -> ${method} ${url}`);
      //TODO: 真实网络请求
      // 模拟真实的 Promise 网络延迟 (比如拉长到 1.5 秒方便观察)
      await new Promise<void>(resolve => setTimeout(resolve, 1500));

      // 2. 请求成功：修改核心业务状态（如：点赞数 +1）
      let successMutations = params['onSuccessMutations'] as Array<Record<string, JsonValue>>;
      if (successMutations) stateContext.updateMutations(successMutations);

    } catch (error) {
      // 处理失败逻辑...
    } finally {
      // 3. 请求结束：无论成功还是失败，解除锁定状态
      let completeMutations = params['onCompleteMutations'] as Array<Record<string, JsonValue>>;
      if (completeMutations) stateContext.updateMutations(completeMutations);
    }
  }
}

// 动作 4：纯本地的布尔状态切换 (适用于关注、收藏、展开收起等)
export class ToggleStateAction implements SDUIActionHandler {
  async execute(params: Record<string, JsonValue>, stateContext: SDUIState): Promise<void> {
    // 1. 获取需要翻转的标识 key
    let boolKey = params['boolStateKey'] as string;

    // 2. 从全局状态池读取当前状态（默认当作 false）
    let currentState = (stateContext.getItem(boolKey).value as boolean) ?? false;

    // 3. 状态取反，并立刻存回状态池
    let newState = !currentState;
    stateContext.updateState(boolKey, newState);

    // 4. 根据新状态，选择对应的 UI 突变指令
    let mutationsToApply = newState ? params['trueMutations'] : params['falseMutations'];

    if (mutationsToApply) {
      // 瞬间触发本地 UI 批量重绘，0 延迟！
      stateContext.updateMutations(mutationsToApply as Array<Record<string, JsonValue>>);
    }
  }
}