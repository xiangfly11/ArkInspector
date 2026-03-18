import {
  DebugManager,
  DebugWindowManager,
  UIInspector,
  DynamicTextModifier,
  DynamicColumnModifier,
  TextStyleBuilder,
  ColumnStyleBuilder,
  UIController
} from 'arkinspector'; // 💥 从你的独立库中引入
import { NewsItem } from './NewsItemModel';
import { JSON } from '@kit.ArkTS';

// ==========================================
// 真实业务页面与探针的结合
// ==========================================
@Entry
@ComponentV2
struct RealWorldListPage {
  @Local newsList: NewsItem[] = [];

  @Local fontSize: number = 18;

  @Local titleCtrl: UIController = new UIController(
    new TextStyleBuilder()
      .fontSize(15)
      .fontColor('#333333')
      .padding({top: 10, bottom: 10})
      .fontWeight(FontWeight.Bold)
      .layoutWeight(1)
      .build()
  );

  @Local cardStyle: Record<string, Object> = new ColumnStyleBuilder()
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(16)
    .margin({top: 10})
    .build();

  aboutToAppear() {
    let news1 = new NewsItem();
    news1.newsTitle = "鸿蒙 SDUI 框架原理解析";
    news1.praiseCount = 100;

    let news2 = new NewsItem();
    news2.newsTitle = "富士 X-T5 摄影技巧分享";
    news2.praiseCount = 888;
    news2.isHot = true;

    this.newsList = [news1, news2];

    DebugManager.register("listData", this.newsList, (newVal: ESObject) => {
      this.newsList = newVal as NewsItem[];
    });
  }

  aboutToDisappear(): void {
    DebugManager.unregister("listData");
  }

  build() {
    Column() {
      List({ space: 16 }) {
        ForEach(this.newsList, (item: NewsItem, index: number) => {
          ListItem() {
            Column({ space: 10 }) {
              Row() {
                Text(`[${index}] `).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#3E75D8')

                // --- 标题组件 ---
                Text(item.newsTitle)
                  .attributeModifier(new DynamicTextModifier(this.titleCtrl.style, `news_title_${index}`))
                  .onClick(this.titleCtrl.bindInspector(`news_title_${index}`, () => {
                    // 这里写你原本的业务逻辑
                    console.log(`业务逻辑：用户点击了新闻 [${item.newsTitle}]，准备跳转详情页！`);
                    // router.pushUrl(...)
                  }))

                if (item.isHot) {
                  Text("🔥 热搜")
                    .fontSize(12).fontColor('#FF0000').padding(4)
                    .backgroundColor('#FFE5E5').borderRadius(4)
                }
              }.width('100%')

              Row({ space: 20 }) {
                Text(`👍 点赞: ${item.praiseCount}`).fontSize(15)
              }.width('100%')
            }
            // --- 卡片(Column)组件 ---
            .attributeModifier(new DynamicColumnModifier(this.cardStyle, `card_style_${index}`))
            .onClick(UIInspector.withInspect(`card_style_${index}`, this.cardStyle, (newStyle: ESObject) => {
              // 这里现在绑定的是卡片自己的 cardStyle
              this.cardStyle = newStyle as Record<string, Object>;
            }))
          }
        },
          // 💥 关键修复：把 inspectTick 拼接到 Key 里，这样每次属性改变，ForEach 都会乖乖重绘！
          (item: NewsItem, index: number) => JSON.stringify(item))
      }
      .width('100%').padding(16).backgroundColor('#F5F6F8').layoutWeight(1)

      Button("业务代码动态修改字体")
        .onClick(() => {
          // 💥 4. 业务逻辑依然极度优雅，通过 update 方法更新，UI 瞬间刷新！
          this.titleCtrl.update('fontSize', 50);
        })

      Button("🐞 呼出全局调试面板")
        .onClick(() => {
          DebugWindowManager.showDebugger();
        })
    }
    .height('100%')
    .width('100%')
  }
}