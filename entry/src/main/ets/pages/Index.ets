// import { DynamicFactory } from "./DynamicComponents";
// import { DynamicNode } from "./DynamicNode";
// import { SDUIState } from "./SDUIState";
//
// // @Entry
// // @ComponentV2
// // struct MediaArticlePage {
// //   @Local rootNode: DynamicNode = new DynamicNode('Column', {});
// //   // 注入初始状态字典：包含了关注、点赞、展开全文的所有初始变量
// //   @Local pageState: SDUIState = new SDUIState({
// //     // 1. 关注状态 (ToggleState)
// //     "is_followed": false,
// //     "follow_text": "+ 关注",
// //     "follow_bg": "#FF0000",
// //     "follow_color": "#FFFFFF",
// //
// //     // 2. 展开全文状态 (UpdateState)
// //     "article_max_lines": 2,
// //     "expand_btn_display": "Flex", // 用于控制展开按钮的显示隐藏 (暂用文字占位表示)
// //     "expand_text": "展开全文",
// //
// //     // 3. 点赞状态 (HttpRequest)
// //     "like_count_str": "👍 点赞 (128)",
// //     "like_btn_color": "#F4F5F7",
// //     "like_text_color": "#007DFF",
// //     "is_like_enabled": true,
// //     "like_opacity": 1.0
// //   });
// //
// //   aboutToAppear() {
// //     // 包含 4 种 Action 的超级 Mock JSON
// //     let mockServerResponse = `
// //     {
// //   "type": "Column",
// //   "props": {
// //     "space": 16,
// //     "width": "92%",
// //     "padding": 16,
// //     "backgroundColor": "#FFFFFF",
// //     "borderRadius": 16
// //   },
// //   "children": [
// //     {
// //       "type": "Row",
// //       "props": {
// //         "width": "100%",
// //         "justifyContent": "SpaceBetween",
// //         "alignItems": "Center"
// //       },
// //       "children": [
// //         {
// //           "type": "Row",
// //           "props": { "space": 8, "alignItems": "Center" },
// //           "children": [
// //             {
// //               "type": "Image",
// //               "props": {
// //                 "src": "https://fuss10.elemecdn.com/a/3f/3302e58f9a181d2509f3dc0fa68b0jpeg.jpeg",
// //                 "width": 36,
// //                 "height": 36,
// //                 "borderRadius": 18,
// //                 "objectFit": "cover"
// //               }
// //             },
// //             {
// //               "type": "Text",
// //               "props": {
// //                 "text": "光影漫步",
// //                 "fontSize": 15,
// //                 "fontWeight": "bold",
// //                 "fontColor": "#333333"
// //               }
// //             }
// //           ]
// //         },
// //         {
// //           "type": "Row",
// //           "props": {
// //             "padding": { "top": 6, "bottom": 6, "left": 14, "right": 14 },
// //             "backgroundColor": "\${follow_bg}",
// //             "borderRadius": 16
// //           },
// //           "events": {
// //             "onClick": {
// //               "actionType": "toggleState",
// //               "params": {
// //                 "boolStateKey": "is_followed",
// //                 "trueMutations": [
// //                   { "stateKey": "follow_text", "value": "已关注" },
// //                   { "stateKey": "follow_bg", "value": "#F0F0F0" },
// //                   { "stateKey": "follow_color", "value": "#999999" }
// //                 ],
// //                 "falseMutations": [
// //                   { "stateKey": "follow_text", "value": "+ 关注" },
// //                   { "stateKey": "follow_bg", "value": "#FF0000" },
// //                   { "stateKey": "follow_color", "value": "#FFFFFF" }
// //                 ]
// //               }
// //             }
// //           },
// //           "children": [
// //             {
// //               "type": "Text",
// //               "props": {
// //                 "text": "\${follow_text}",
// //                 "fontSize": 13,
// //                 "fontColor": "\${follow_color}"
// //               }
// //             }
// //           ]
// //         }
// //       ]
// //     },
// //     {
// //       "type": "Column",
// //       "props": {
// //         "space": 8,
// //         "alignItems": "Start",
// //         "width": "100%"
// //       },
// //       "children": [
// //         {
// //           "type": "Text",
// //           "props": {
// //             "text": "带着富士 X-T5 搭配 16-80mm F4.0 镜头，重走成都古蜀道。不仅是历史的厚重，更是光影的魅力。在这条千年的古道上，高感光的纯净度和细腻的暗部过渡让人惊喜，完全不用担心噪点破坏画面的美感。即使在茂密的翠云廊深处，直出色彩依然令人惊艳。",
// //             "fontSize": 15,
// //             "fontColor": "#333333",
// //             "lineHeight": 22,
// //             "maxLines": "\${article_max_lines}",
// //             "textOverflow": "ellipsis"
// //           }
// //         },
// //         {
// //           "type": "Text",
// //           "props": {
// //             "text": "\${expand_text}",
// //             "fontSize": 15,
// //             "fontColor": "#007DFF"
// //           },
// //           "events": {
// //             "onClick": {
// //               "actionType": "updateState",
// //               "params": {
// //                 "mutations": [
// //                   { "stateKey": "article_max_lines", "value": 999 },
// //                   { "stateKey": "expand_text", "value": "" }
// //                 ]
// //               }
// //             }
// //           }
// //         }
// //       ]
// //     },
// //     {
// //       "type": "Row",
// //       "props": {
// //         "width": "100%",
// //         "justifyContent": "SpaceBetween",
// //         "alignItems": "Center",
// //         "padding": { "top": 10 }
// //       },
// //       "children": [
// //         {
// //           "type": "Row",
// //           "props": {
// //             "padding": { "top": 8, "bottom": 8, "left": 20, "right": 20 },
// //             "backgroundColor": "\${like_btn_color}",
// //             "borderRadius": 20,
// //             "enabled": "\${is_like_enabled}",
// //             "opacity": "\${like_opacity}"
// //           },
// //           "events": {
// //             "onClick": {
// //               "actionType": "httpRequest",
// //               "params": {
// //                 "url": "/api/v1/article/like",
// //                 "method": "POST",
// //                 "onStartMutations": [
// //                   { "stateKey": "is_like_enabled", "value": false },
// //                   { "stateKey": "like_opacity", "value": 0.5 },
// //                   { "stateKey": "like_count_str", "value": "提交中..." }
// //                 ],
// //                 "onSuccessMutations": [
// //                   { "stateKey": "like_count_str", "value": "👍 已赞 (129)" },
// //                   { "stateKey": "like_btn_color", "value": "#FFE5E5" },
// //                   { "stateKey": "like_text_color", "value": "#FF0000" }
// //                 ],
// //                 "onCompleteMutations": [
// //                   { "stateKey": "is_like_enabled", "value": true },
// //                   { "stateKey": "like_opacity", "value": 1.0 }
// //                 ]
// //               }
// //             }
// //           },
// //           "children": [
// //             {
// //               "type": "Text",
// //               "props": {
// //                 "text": "\${like_count_str}",
// //                 "fontSize": 14,
// //                 "fontWeight": "medium",
// //                 "fontColor": "\${like_text_color}"
// //               }
// //             }
// //           ]
// //         },
// //         {
// //           "type": "Row",
// //           "props": {
// //             "padding": { "top": 8, "bottom": 8, "left": 20, "right": 20 },
// //             "backgroundColor": "#F4F5F7",
// //             "borderRadius": 20
// //           },
// //           "events": {
// //             "onClick": {
// //               "actionType": "toast",
// //               "params": {
// //                 "message": "🔗 游记链接已复制，快去分享吧！"
// //               }
// //             }
// //           },
// //           "children": [
// //             {
// //               "type": "Text",
// //               "props": {
// //                 "text": "分享",
// //                 "fontSize": 14,
// //                 "fontColor": "#666666"
// //               }
// //             }
// //           ]
// //         }
// //       ]
// //     }
// //   ]
// // }`;
// //
// //     //     let mockServerResponse = `{
// //     //   "type": "Column",
// //     //   "props": {
// //     //     "width": "100%",
// //     //     "padding": 16,
// //     //     "backgroundColor": "#F5F6F8"
// //     //   },
// //     //   "children": [
// //     //     {
// //     //       "type": "Column",
// //     //       "props": {
// //     //         "width": "100%",
// //     //         "backgroundColor": "#BDE0FF",
// //     //         "borderRadius": 12,
// //     //         "padding": 20,
// //     //         "space": 24
// //     //       },
// //     //       "children": [
// //     //         {
// //     //           "type": "Row",
// //     //           "props": {
// //     //             "alignItems": "Center",
// //     //             "space": 8
// //     //           },
// //     //           "children": [
// //     //             {
// //     //               "type": "Text",
// //     //               "props": {
// //     //                 "text": "会员有效期至",
// //     //                 "fontSize": 16,
// //     //                 "fontColor": "#333333",
// //     //                 "fontWeight": "bold"
// //     //               }
// //     //             },
// //     //             {
// //     //               "type": "Text",
// //     //               "props": {
// //     //                 "text": "\${vip_expire_date}",
// //     //                 "fontSize": 16,
// //     //                 "fontColor": "#3E75D8",
// //     //                 "fontWeight": "bold"
// //     //               }
// //     //             }
// //     //           ]
// //     //         },
// //     //         {
// //     //           "type": "Row",
// //     //           "props": {
// //     //             "backgroundColor": "#FFFFFF",
// //     //             "borderRadius": 20,
// //     //             "padding": { "top": 6, "bottom": 6, "left": 16, "right": 16 },
// //     //             "alignItems": "Center",
// //     //             "space": 6
// //     //           },
// //     //           "events": {
// //     //             "onClick": {
// //     //               "actionType": "toast",
// //     //               "params": {
// //     //                 "message": "正在拉起收银台..."
// //     //               }
// //     //             }
// //     //           },
// //     //           "children": [
// //     //             {
// //     //               "type": "Image",
// //     //               "props": {
// //     //                 "src": "https://dummyimage.com/16x16/3E75D8/ffffff.png&text=+",
// //     //                 "width": 16,
// //     //                 "height": 16,
// //     //                 "borderRadius": 8
// //     //               }
// //     //             },
// //     //             {
// //     //               "type": "Text",
// //     //               "props": {
// //     //                 "text": "立即续费",
// //     //                 "fontSize": 14,
// //     //                 "fontColor": "#333333",
// //     //                 "fontWeight": "bold"
// //     //               }
// //     //             }
// //     //           ]
// //     //         }
// //     //       ]
// //     //     },
// //     //     {
// //     //       "type": "Row",
// //     //       "props": {
// //     //         "width": "100%",
// //     //         "margin": { "top": 30, "bottom": 16 }
// //     //       },
// //     //       "children": [
// //     //         {
// //     //           "type": "Text",
// //     //           "props": {
// //     //             "text": "历史订单",
// //     //             "fontSize": 16,
// //     //             "fontColor": "#1A1A1A",
// //     //             "fontWeight": "bold"
// //     //           }
// //     //         }
// //     //       ]
// //     //     },
// //     //     {
// //     //       "type": "Column",
// //     //       "props": {
// //     //         "width": "100%",
// //     //         "backgroundColor": "#FFFFFF",
// //     //         "borderRadius": 12,
// //     //         "padding": 16,
// //     //         "space": 12,
// //     //         "margin": { "bottom": 16 }
// //     //       },
// //     //       "children": [
// //     //         {
// //     //           "type": "Row",
// //     //           "props": {
// //     //             "width": "100%",
// //     //             "justifyContent": "SpaceBetween",
// //     //             "alignItems": "Center"
// //     //           },
// //     //           "children": [
// //     //             {
// //     //               "type": "Text",
// //     //               "props": {
// //     //                 "text": "单位名称：\${order1_name}",
// //     //                 "fontSize": 15,
// //     //                 "fontColor": "#333333"
// //     //               }
// //     //             },
// //     //             {
// //     //               "type": "Row",
// //     //               "props": {
// //     //                 "backgroundColor": "#6A99E9",
// //     //                 "borderRadius": 4,
// //     //                 "padding": { "top": 4, "bottom": 4, "left": 8, "right": 8 }
// //     //               },
// //     //               "children": [
// //     //                 {
// //     //                   "type": "Text",
// //     //                   "props": {
// //     //                     "text": "\${order1_type_text}",
// //     //                     "fontSize": 12,
// //     //                     "fontColor": "#FFFFFF"
// //     //                   }
// //     //                 }
// //     //               ]
// //     //             }
// //     //           ]
// //     //         },
// //     //         {
// //     //           "type": "Text",
// //     //           "props": {
// //     //             "text": "开通时间：\${order1_start_time}",
// //     //             "fontSize": 14,
// //     //             "fontColor": "#666666"
// //     //           }
// //     //         },
// //     //         {
// //     //           "type": "Text",
// //     //           "props": {
// //     //             "text": "有效期：\${order1_end_time}",
// //     //             "fontSize": 14,
// //     //             "fontColor": "#666666"
// //     //           }
// //     //         }
// //     //       ]
// //     //     },
// //     //     {
// //     //       "type": "Column",
// //     //       "props": {
// //     //         "width": "100%",
// //     //         "backgroundColor": "#FFFFFF",
// //     //         "borderRadius": 12,
// //     //         "padding": 16,
// //     //         "space": 12
// //     //       },
// //     //       "children": [
// //     //         {
// //     //           "type": "Row",
// //     //           "props": {
// //     //             "width": "100%",
// //     //             "justifyContent": "SpaceBetween",
// //     //             "alignItems": "Center"
// //     //           },
// //     //           "children": [
// //     //             {
// //     //               "type": "Text",
// //     //               "props": {
// //     //                 "text": "兑换码：\${order2_code}",
// //     //                 "fontSize": 15,
// //     //                 "fontColor": "#333333"
// //     //               }
// //     //             },
// //     //             {
// //     //               "type": "Row",
// //     //               "props": {
// //     //                 "backgroundColor": "#64C795",
// //     //                 "borderRadius": 4,
// //     //                 "padding": { "top": 4, "bottom": 4, "left": 8, "right": 8 }
// //     //               },
// //     //               "children": [
// //     //                 {
// //     //                   "type": "Text",
// //     //                   "props": {
// //     //                     "text": "\${order2_type_text}",
// //     //                     "fontSize": 12,
// //     //                     "fontColor": "#FFFFFF"
// //     //                   }
// //     //                 }
// //     //               ]
// //     //             }
// //     //           ]
// //     //         },
// //     //         {
// //     //           "type": "Text",
// //     //           "props": {
// //     //             "text": "兑换时间：\${order2_start_time}",
// //     //             "fontSize": 14,
// //     //             "fontColor": "#666666"
// //     //           }
// //     //         },
// //     //         {
// //     //           "type": "Text",
// //     //           "props": {
// //     //             "text": "有效期：\${order2_end_time}",
// //     //             "fontSize": 14,
// //     //             "fontColor": "#666666"
// //     //           }
// //     //         }
// //     //       ]
// //     //     }
// //     //   ]
// //     // }`
// //
// //     // 模拟网络延迟下发
// //     setTimeout(() => {
// //       this.rootNode = JSON.parse(mockServerResponse) as DynamicNode;
// //     }, 150);
// //   }
// //
// //   build() {
// //     Scroll() {
// //       DynamicFactory({ nodeData: this.rootNode, stateContext: this.pageState })
// //     }
// //     .width('100%')
// //     .height('100%')
// //     .align(Alignment.Top)
// //     .backgroundColor('#F0F0F0')
// //     .padding({ top: 40 })
// //   }
// // }
//
//
// import { JsonValue } from "./DynamicBaseModifier";
// import { VisualDebuggerPanel } from "./VisualDebuggerPanel";
//
// @Entry
// @ComponentV2
// struct MediaArticlePage {
//   // 1. 完全没有 JSON！只需定义你 App 运行时的核心状态字典
//   @Local pageState: Record<string, JsonValue> = {
//     "is_followed": false,
//     "article_info": {
//       "title": "带着富士 X-T5 重走古蜀道",
//       "like_count": 128,
//       "is_like_enabled": true
//     } as Record<string, JsonValue>, // 👈 关键点：明确声明嵌套对象的类型
//     "ui_settings": {
//       "button_color": "#FF0000",
//       "font_size": 16
//     } as Record<string, JsonValue>  // 👈 关键点
//   };
//   build() {
//     Stack({ alignContent: Alignment.Bottom }) {
//
//       // ==========================================
//       // 这里是你的 App 正常业务 UI 区
//       // ==========================================
//       Column({ space: 20 }) {
//         Text((this.pageState['article_info'] as Record<string, JsonValue>)['title'] as string)
//           .fontSize((this.pageState['ui_settings'] as Record<string, JsonValue>)['font_size'] as number)
//           .fontWeight(FontWeight.Bold)
//
//         Text(`点赞数: ${(this.pageState['article_info'] as Record<string, JsonValue>)['like_count']}`)
//           .fontSize(18)
//
//         Button(this.pageState['is_followed'] ? "已关注" : "+ 关注")
//           .backgroundColor((this.pageState['ui_settings'] as Record<string, JsonValue>)['button_color'] as string)
//           .onClick(() => {
//             // App 内正常的交互逻辑：修改状态
//             let newState: Record<string, JsonValue> = {};
//             let keys = Object.keys(this.pageState as object);
//
//             for (let i = 0; i < keys.length; i++) {
//               let key = keys[i];
//               newState[key] = this.pageState[key];
//             }
//
//             newState['is_followed'] = !newState['is_followed'];
//             this.pageState = newState;
//           })
//       }
//       .width('100%')
//       .height('100%')
//       .padding(40)
//       .alignItems(HorizontalAlign.Center)
//       .backgroundColor('#F5F6F8')
//
//       // ==========================================
//       // 这里是我们新加的可视化调试探针面板 (覆盖在最上层)
//       // ==========================================
//       VisualDebuggerPanel({
//         targetState: this.pageState,
//         onStateChange: (newState: Record<string, JsonValue>) => {
//           // 探针面板里修改了数据，自动同步回你的 pageState，App 界面瞬间重绘！
//           this.pageState = newState;
//         }
//       })
//         .margin({ bottom: 40 })
//
//     }
//     .width('100%')
//     .height('100%')
//   }
// }

/**
 * Date: 2026/3/12
 * File Name: Index.ets
 **/
import { VisualDebuggerPanel } from './VisualDebuggerPanel';
import { AnyValue } from './StateVisualizerNode';
import { DebugManager } from './DebugManager';
import { window } from '@kit.ArkUI';
import { DebugWindowManager } from './DebugWindowManager';

// ==========================================
// 1. 补充的 Mock 依赖 (确保你的类不会报错)
// ==========================================
export enum NewsPostionType { channelList, searchPubList }
export enum NewsItemLabel { zhuanti = 1 }
export enum NewsItemFlag { zhuanti = 1, fenLeiZhuanti = 2, video = 3 }
export class TimeUtil {
  // static TimeFormatterType = { searchPublish: 1 };
  static formatTime(time: number, type: number): string { return "刚刚"; }
}

// ==========================================
// 2. 你提供的真实业务类 (原封不动)
// ==========================================
export class NewsItem {
  audio_content: string = '';
  audio_flag: boolean = false;
  author: string = '';
  can_comment: boolean = true;
  external_url: string = "";
  flag: number = 0;
  happen_time: number = 0;
  has_video: boolean = false;
  img_url?: string;
  img_169?: string;
  img_31?: string;
  is_hot: boolean = false;
  is_interact_video: boolean = false;
  is_subject: boolean = true;
  kind: number = 0;
  label: number = 0;
  news_id: number = 0;
  news_kind: number = 0;
  news_title: string = '鸿蒙原生应用开发实战：打造高效 SDUI 框架';
  news_content: string = '';
  no_likes: boolean = false;
  on_blockchain: boolean = false;
  praise_count: number = 99;
  reply_count: number = 0;
  review_count: number = 0;
  screen_shot_switch: boolean = true;
  share_gray_switch: number = 0;
  showLabelInVersion: boolean = false;
  source: string = 'ArkUI 开发者社区';
  source_id: number = 0;
  video_url: string = '';
  video_time: number = 0;
  big_img: string = '';
  is_new: number = 0;
  channel_type: number = 0;
  subject_name: string = '';
  subject_id: number = 0;
  head_img: string = '';
  is_subscribe: boolean = false;
  updateTimeStamp: number = 0;

  showPositionType: NewsPostionType = NewsPostionType.channelList;
  channelId: number = 0;
  channelType: number = 0;

  getTagImg(): ResourceStr {
    if (this.label == NewsItemLabel.zhuanti || this.flag == NewsItemFlag.zhuanti || this.flag == NewsItemFlag.fenLeiZhuanti) {
      return $r('sys.media.ohos_ic_public_play'); // 用系统图标代替你的本地图标防报错
    }
    return '无标签图';
  }

  getMediaTag(): ResourceStr {
    if (this.flag == NewsItemFlag.video || this.news_kind == 4) {
      return $r('sys.media.ohos_ic_public_video');
    }
    return '';
  }

  getTimeText(): string {
    return "今天 15:30"; // 简化的 Mock 数据
  }
}

// ==========================================
// 3. 真实业务页面与探针的结合
// ==========================================
@Entry
@ComponentV2
struct RealWorldListPage {
  // 1. 真实业务场景：这是一个新闻列表数组
  @Local newsList: NewsItem[] = [];

  aboutToAppear() {
    // 模拟网络请求返回了两条数据
    let news1 = new NewsItem();
    news1.news_title = "鸿蒙 SDUI 框架原理解析";
    news1.praise_count = 100;

    let news2 = new NewsItem();
    news2.news_title = "富士 X-T5 摄影技巧分享";
    news2.praise_count = 888;
    news2.is_hot = true;

    this.newsList = [news1, news2];

    // 💥 极简接入：向全局注册表报备你想调试的变量
    DebugManager.register("listData", this.newsList, (newVal: ESObject) => {
      // 当面板中修改了数据，这里会被触发，重新赋值引发当前页面的 @Local 刷新！
      this.newsList = newVal as NewsItem[];
    });
  }

  aboutToDisappear(): void {
    // 💥 页面退出时务必注销，防止内存泄漏
    DebugManager.unregister("listData");
  }

  build() {
    // Stack({ alignContent: Alignment.Bottom }) {

      // ----------------------------------------
      // 上半部分：真实的列表渲染 UI
      // ----------------------------------------
    Column() {
      List({ space: 16 }) {
        ForEach(this.newsList, (item: NewsItem, index: number) => {
          ListItem() {
            Column({ space: 10 }) {
              Row() {
                Text(`[${index}] `).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#3E75D8')
                Text(item.news_title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
                if (item.is_hot) {
                  Text("🔥 热搜").fontSize(12).fontColor('#FF0000').padding(4).backgroundColor('#FFE5E5').borderRadius(4)
                }
              }.width('100%')

              Row({ space: 20 }) {
                Text(`👍 点赞: ${item.praise_count}`).fontSize(15)
                Text(`方法调用: ${item.getTagImg()}`).fontSize(12).fontColor('#AAAAAA')
              }.width('100%')
            }
            .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(12)
          }
        }, (item: NewsItem, index: number) => index.toString() + item.praise_count)
        // 👆 注意：ArkUI V2 列表渲染强依赖 Key 值的变化。为了让数据修改后立刻刷新，可以把点赞数或时间戳拼接到 Key 里
      }
      .width('100%').height('100%').padding(16).backgroundColor('#F5F6F8')

      Button("🐞 呼出全局调试面板")
        .onClick(() => {
          // 真正的一键呼唤，不再需要获取乱七八糟的 context
          DebugWindowManager.showDebugger();
        })
    }
    .height('100%')
    .width('100%')
  }
}