import { DebugManager } from './DebugManager';
import { DebugWindowManager } from './DebugWindowManager';
import { DynamicTextModifier } from './DynamicTextModifier';
import { DynamicColumnModifier } from './DynamicColumnModifier';
import { UIInspector } from './UIInspector';
import { NewsItem } from './NewsItemModel';
import { JSON } from '@kit.ArkTS';

// ==========================================
// 3. 真实业务页面与探针的结合
// ==========================================
@Entry
@ComponentV2
struct RealWorldListPage {
  @Local newsList: NewsItem[] = [];

  @Local titleStyle: Record<string, Object> = {
    'fontSize': 18,
    'fontColor': '#333333',
    'fontWeight': 'bold',
    'padding': { 'top': 10, 'bottom': 10 } as Record<string, number>,
    'layoutWeight': 1
  };

  @Local cardStyle: Record<string, Object> = {
    'width': '100%',
    'backgroundColor': '#FFFFFF',
    'borderRadius': 12,
    'padding': 16,
    'margin': { 'top': 10 } as Record<string, number>
  };

  // 💥 关键新增：专门用来打破 ForEach 渲染缓存的触发器
  // @Local inspectTick: number = 0;

  aboutToAppear() {
    let news1 = new NewsItem();
    news1.news_title = "鸿蒙 SDUI 框架原理解析";
    news1.praise_count = 100;

    let news2 = new NewsItem();
    news2.news_title = "富士 X-T5 摄影技巧分享";
    news2.praise_count = 888;
    news2.is_hot = true;

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
                Text(item.news_title)
                  .attributeModifier(new DynamicTextModifier(this.titleStyle, `news_title_${index}`))
                  .onClick(UIInspector.withInspect(`news_title_${index}`, this.titleStyle, (newStyle: ESObject) => {
                    this.titleStyle = newStyle as Record<string, Object>;
                    // this.inspectTick++; // 💥 强制触发页面重绘
                  }))

                if (item.is_hot) {
                  Text("🔥 热搜")
                    .fontSize(12).fontColor('#FF0000').padding(4)
                    .backgroundColor('#FFE5E5').borderRadius(4)
                }
              }.width('100%')

              Row({ space: 20 }) {
                Text(`👍 点赞: ${item.praise_count}`).fontSize(15)
                Text(`方法调用: ${item.getTagImg()}`).fontSize(12).fontColor('#AAAAAA')
              }.width('100%')
            }
            // --- 卡片(Column)组件 ---
            .attributeModifier(new DynamicColumnModifier(this.cardStyle, `card_style_${index}`))
            .onClick(UIInspector.withInspect(`card_style_${index}`, this.cardStyle, (newStyle: ESObject) => {
              // 💥 修复：这里现在绑定的是卡片自己的 cardStyle
              this.cardStyle = newStyle as Record<string, Object>;
              // this.inspectTick++; // 💥 强制触发页面重绘
            }))
          }
        },
          // 💥 关键修复：把 inspectTick 拼接到 Key 里，这样每次属性改变，ForEach 都会乖乖重绘！
          (item: NewsItem, index: number) => JSON.stringify(item))
      }
      .width('100%').padding(16).backgroundColor('#F5F6F8').layoutWeight(1)

      Button("🐞 呼出全局调试面板")
        .onClick(() => {
          DebugWindowManager.showDebugger();
        })
    }
    .height('100%')
    .width('100%')
  }
}