import { DynamicFactory } from "./DynamicComponents";
import { DynamicNode } from "./DynamicNode";
import { SDUIState } from "./SDUIState";

@Entry
@ComponentV2
struct MediaArticlePage {
  @Local rootNode: DynamicNode = new DynamicNode('Column', {});

  // 注入初始状态字典：包含了关注、点赞、展开全文的所有初始变量
  @Local pageState: SDUIState = new SDUIState({
    // 1. 关注状态 (ToggleState)
    "is_followed": false,
    "follow_text": "+ 关注",
    "follow_bg": "#FF0000",
    "follow_color": "#FFFFFF",

    // 2. 展开全文状态 (UpdateState)
    "article_max_lines": 2,
    "expand_btn_display": "Flex", // 用于控制展开按钮的显示隐藏 (暂用文字占位表示)
    "expand_text": "展开全文",

    // 3. 点赞状态 (HttpRequest)
    "like_count_str": "👍 点赞 (128)",
    "like_btn_color": "#F4F5F7",
    "like_text_color": "#007DFF",
    "is_like_enabled": true,
    "like_opacity": 1.0
  });

  aboutToAppear() {
    // 包含 4 种 Action 的超级 Mock JSON
    let mockServerResponse = `
    {
  "type": "Column",
  "props": {
    "space": 16,
    "width": "92%",
    "padding": 16,
    "backgroundColor": "#FFFFFF",
    "borderRadius": 16
  },
  "children": [
    {
      "type": "Row",
      "props": {
        "width": "100%",
        "justifyContent": "SpaceBetween",
        "alignItems": "Center"
      },
      "children": [
        {
          "type": "Row",
          "props": { "space": 8, "alignItems": "Center" },
          "children": [
            {
              "type": "Image",
              "props": {
                "src": "https://fuss10.elemecdn.com/a/3f/3302e58f9a181d2509f3dc0fa68b0jpeg.jpeg",
                "width": 36,
                "height": 36,
                "borderRadius": 18,
                "objectFit": "cover"
              }
            },
            {
              "type": "Text",
              "props": {
                "text": "光影漫步",
                "fontSize": 15,
                "fontWeight": "bold",
                "fontColor": "#333333"
              }
            }
          ]
        },
        {
          "type": "Row",
          "props": {
            "padding": { "top": 6, "bottom": 6, "left": 14, "right": 14 },
            "backgroundColor": "\${follow_bg}",
            "borderRadius": 16
          },
          "events": {
            "onClick": {
              "actionType": "toggleState",
              "params": {
                "boolStateKey": "is_followed",
                "trueMutations": [
                  { "stateKey": "follow_text", "value": "已关注" },
                  { "stateKey": "follow_bg", "value": "#F0F0F0" },
                  { "stateKey": "follow_color", "value": "#999999" }
                ],
                "falseMutations": [
                  { "stateKey": "follow_text", "value": "+ 关注" },
                  { "stateKey": "follow_bg", "value": "#FF0000" },
                  { "stateKey": "follow_color", "value": "#FFFFFF" }
                ]
              }
            }
          },
          "children": [
            {
              "type": "Text",
              "props": {
                "text": "\${follow_text}",
                "fontSize": 13,
                "fontColor": "\${follow_color}"
              }
            }
          ]
        }
      ]
    },
    {
      "type": "Column",
      "props": {
        "space": 8,
        "alignItems": "Start",
        "width": "100%"
      },
      "children": [
        {
          "type": "Text",
          "props": {
            "text": "带着富士 X-T5 搭配 16-80mm F4.0 镜头，重走成都古蜀道。不仅是历史的厚重，更是光影的魅力。在这条千年的古道上，高感光的纯净度和细腻的暗部过渡让人惊喜，完全不用担心噪点破坏画面的美感。即使在茂密的翠云廊深处，直出色彩依然令人惊艳。",
            "fontSize": 15,
            "fontColor": "#333333",
            "lineHeight": 22,
            "maxLines": "\${article_max_lines}",
            "textOverflow": "ellipsis"
          }
        },
        {
          "type": "Text",
          "props": {
            "text": "\${expand_text}",
            "fontSize": 15,
            "fontColor": "#007DFF"
          },
          "events": {
            "onClick": {
              "actionType": "updateState",
              "params": {
                "mutations": [
                  { "stateKey": "article_max_lines", "value": 999 },
                  { "stateKey": "expand_text", "value": "" }
                ]
              }
            }
          }
        }
      ]
    },
    {
      "type": "Row",
      "props": {
        "width": "100%",
        "justifyContent": "SpaceBetween",
        "alignItems": "Center",
        "padding": { "top": 10 }
      },
      "children": [
        {
          "type": "Row",
          "props": {
            "padding": { "top": 8, "bottom": 8, "left": 20, "right": 20 },
            "backgroundColor": "\${like_btn_color}",
            "borderRadius": 20,
            "enabled": "\${is_like_enabled}",
            "opacity": "\${like_opacity}"
          },
          "events": {
            "onClick": {
              "actionType": "httpRequest",
              "params": {
                "url": "/api/v1/article/like",
                "method": "POST",
                "onStartMutations": [
                  { "stateKey": "is_like_enabled", "value": false },
                  { "stateKey": "like_opacity", "value": 0.5 },
                  { "stateKey": "like_count_str", "value": "提交中..." }
                ],
                "onSuccessMutations": [
                  { "stateKey": "like_count_str", "value": "👍 已赞 (129)" },
                  { "stateKey": "like_btn_color", "value": "#FFE5E5" },
                  { "stateKey": "like_text_color", "value": "#FF0000" }
                ],
                "onCompleteMutations": [
                  { "stateKey": "is_like_enabled", "value": true },
                  { "stateKey": "like_opacity", "value": 1.0 }
                ]
              }
            }
          },
          "children": [
            {
              "type": "Text",
              "props": {
                "text": "\${like_count_str}",
                "fontSize": 14,
                "fontWeight": "medium",
                "fontColor": "\${like_text_color}"
              }
            }
          ]
        },
        {
          "type": "Row",
          "props": {
            "padding": { "top": 8, "bottom": 8, "left": 20, "right": 20 },
            "backgroundColor": "#F4F5F7",
            "borderRadius": 20
          },
          "events": {
            "onClick": {
              "actionType": "toast",
              "params": {
                "message": "🔗 游记链接已复制，快去分享吧！"
              }
            }
          },
          "children": [
            {
              "type": "Text",
              "props": {
                "text": "分享",
                "fontSize": 14,
                "fontColor": "#666666"
              }
            }
          ]
        }
      ]
    }
  ]
}`;

    // 模拟网络延迟下发
    setTimeout(() => {
      this.rootNode = JSON.parse(mockServerResponse) as DynamicNode;
    }, 150);
  }

  build() {
    Scroll() {
      Column() {
        DynamicFactory({ nodeData: this.rootNode, stateContext: this.pageState })
      }.width('100%').padding({ top: 40 })
    }
    .width('100%').height('100%').align(Alignment.Top).backgroundColor('#F0F0F0')
  }
}