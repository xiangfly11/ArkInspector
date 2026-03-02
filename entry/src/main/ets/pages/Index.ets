import { DynamicFactory } from "./DynamicComponents";
import { DynamicNode } from "./DynamicNode"

@Entry
@Component
struct MediaArticlePage {
  // 合规写法 1：使用构造函数初始化一个安全的“空壳”或骨架屏节点
  @State articleData: DynamicNode = new DynamicNode('Column', {});

  aboutToAppear() {
    // 模拟从服务端拉取到的真实下发协议（纯 JSON 字符串）
    let mockServerResponse = `
  {
  "type": "Column",
  "props": {
    "space": 16,
    "width": "92%",
    "padding": 16,
    "backgroundColor": "#FFFFFF",
    "borderRadius": 16,
    "shadow": { "radius": 15, "color": "#1A000000", "offsetY": 8 }
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
          "props": { "space": 10, "alignItems": "Center" },
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
              "props": { "text": "行摄志", "fontSize": 15, "fontWeight": "bold", "fontColor": "#333333" }
            }
          ]
        },
        {
          "type": "Text",
          "props": { "text": "10 mins ago", "fontSize": 12, "fontColor": "#999999" }
        }
      ]
    },
    {
      "type": "Image",
      "props": {
        "src": "https://fuss10.elemecdn.com/e/5d/4a731a90594a4af544c0c25941171jpeg.jpeg",
        "width": "100%",
        "height": 220,
        "borderRadius": 8,
        "objectFit": "cover",
        "alt": "加载中..."
      }
    },
    {
      "type": "Text",
      "props": {
        "text": "京都初雪：古都的静谧时刻",
        "fontSize": 18,
        "fontWeight": "bold",
        "fontColor": "#111111",
        "maxLines": 1,
        "textOverflow": "ellipsis"
      }
    },
    {
      "type": "Text",
      "props": {
        "text": "使用富士 X-T5 搭配 16-80mm f/4.0 镜头，在清晨的二年坂捕捉到了这份难得的宁静。得益于优秀的控噪能力，画面在低光环境下依然保持了极高的纯净度和细腻的暗部过渡。",
        "fontSize": 14,
        "fontColor": "#666666",
        "lineHeight": 22,
        "textAlign": "justify"
      }
    }
  ]
}`;

    // 合规写法 2：将 JSON 字符串解析为 Object 后，进行类型断言
    // 在真实生产环境中，由于使用了 @State，方舟引擎会自动为这个新赋予的对象建立代理
    // 模拟接口返回延时
    setTimeout(() => {
    this.articleData = JSON.parse(mockServerResponse) as DynamicNode;
    }, 2000)
  }

  build() {
    Scroll() {
      // 将合规的数据源喂给解析引擎
      DynamicFactory({ nodeData: this.articleData })
    }
    .width('100%')
    .height('100%')
  }
}