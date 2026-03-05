/**
 * Date: 2026/3/5
 * File Name: SDUIEventDispatcher.ets
 * Author: Jason
 **/


import { promptAction } from '@kit.ArkUI';
import { EventConfig } from './DynamicNode';

export class SDUIEventDispatcher {

  // 核心分发方法
  static dispatch(event?: EventConfig) {
    if (!event || !event.actionType) return;

    switch (event.actionType) {
      case 'toast':
        // 解析提示参数
        let msg = (event.params?.['message'] as string) ?? '默认提示';
        promptAction.showToast({ message: msg });
        break;

      case 'route':
        // 解析路由跳转
        let url = event.params?.['url'] as string;
        console.info(`[SDUI Event] 准备跳转至路由: ${url}`);
        // router.pushUrl({ url: url });
        break;

      case 'request':
        // 发起网络请求 (如点赞、收藏)
        let api = event.params?.['api'] as string;
        console.info(`[SDUI Event] 发起业务请求: ${api}, 参数: ${JSON.stringify(event.params)}`);
        break;

      default:
        console.warn(`[SDUI Event] 暂不支持的事件类型: ${event.actionType}`);
        break;
    }
  }
}