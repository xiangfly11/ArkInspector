/**
 * Date: 2026/3/5
 * File Name: SDUIEventDispatcher.ets
 * Author: Jason
 **/


import { EventConfig } from './DynamicNode';
import { SDUIState } from './SDUIState';
import { SDUIActionHandler, UpdateStateAction, ShowToastAction, HttpRequestAction,
  ToggleStateAction } from './SDUIActions';

// 【核心】：动作注册表，扩展新动作只需在这里加一行
const ActionRegistry: Record<string, SDUIActionHandler> = {
  'updateState': new UpdateStateAction(),
  'toast': new ShowToastAction(),
  'httpRequest': new HttpRequestAction(),
  'toggleState': new ToggleStateAction()
};

export class SDUIEventDispatcher {
  // 静态分发方法
  static async dispatch(eventConfig: EventConfig | undefined, stateContext: SDUIState) {
    if (!eventConfig || !eventConfig.actionType) return;

    let handler = ActionRegistry[eventConfig.actionType];
    if (handler) {
      try {
        let params = eventConfig.params ?? {};
        await handler.execute(params, stateContext);
      } catch (error) {
        console.error(`[SDUI Event] Action执行异常: ${eventConfig.actionType}`, error);
      }
    } else {
      console.warn(`[SDUI Event] 暂不支持的 Action 类型: ${eventConfig.actionType}`);
    }
  }
}