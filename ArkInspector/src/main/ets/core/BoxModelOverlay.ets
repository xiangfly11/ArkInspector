/**
 * Date: 2026/3/18
 * File Name: BoxModelOverlay.ets
 * Description: 全屏透明遮罩层，绘制可视化盒模型
 * Author: Jason
 **/

import { DebugManager } from '../core/DebugManager';

// 💥定义标准的类，彻底替代报错的匿名对象 {top: 0, left: 0...}
export class EdgeSpace {
  top: number = 0;
  right: number = 0;
  bottom: number = 0;
  left: number = 0;
}

@ComponentV2
export struct BoxModelOverlay {
  // 💥 将所有需要的坐标和尺寸提前定义为 @Local 状态变量
  // 这样 build() 内部就变成了极其干净的声明式绑定
  @Local isVisible: boolean = false;
  @Local targetX: number = 0;
  @Local targetY: number = 0;
  @Local targetW: number = 0;
  @Local targetH: number = 0;
  @Local marginSpace: EdgeSpace = new EdgeSpace();
  @Local paddingSpace: EdgeSpace = new EdgeSpace();

  aboutToAppear() {
    // 注册监听 (注意：初始值传入 undefined 避免类型检查报错)
    DebugManager.register("BoxModelRect", undefined, (payload: ESObject) => {
      if (!payload) {
        this.isVisible = false;
        return;
      }

      // 💥 修复 3：在普通的业务方法里，集中处理所有复杂的类型断言和逻辑运算
      let dataObj = payload as Record<string, Object>;
      let area = dataObj['area'] as Area;
      let style = dataObj['style'] as Record<string, Object>;

      if (!area || !area.globalPosition) {
        this.isVisible = false;
        return;
      }

      // 💥 修复 4：严谨处理 ArkUI Area 类型的可空属性
      let gX = area.globalPosition.x;
      let gY = area.globalPosition.y;
      this.targetX = typeof gX === 'number' ? gX : 0;
      this.targetY = typeof gY === 'number' ? gY : 0;

      this.targetW = typeof area.width === 'number' ? area.width : 0;
      this.targetH = typeof area.height === 'number' ? area.height : 0;

      // 解析内外边距
      this.marginSpace = this.parseEdgeObj(style['margin']);
      this.paddingSpace = this.parseEdgeObj(style['padding']);

      // 数据计算完毕，触发 UI 重绘
      this.isVisible = true;
    });
  }

  // 💥 修复 5：使用明确的联合类型替换 ESObject，保障类型安全
  private getSpace(val: Object | undefined | null): number {
    if (typeof val === 'number') {
      return val;
    }
    if (typeof val === 'string') {
      let num = Number(val.replace('px', '').replace('vp', ''));
      return Number.isNaN(num) ? 0 : num;
    }
    return 0;
  }

  private parseEdgeObj(spaceProp: Object | undefined | null): EdgeSpace {
    let res = new EdgeSpace();
    if (spaceProp === undefined || spaceProp === null) {
      return res;
    }

    if (typeof spaceProp === 'number' || typeof spaceProp === 'string') {
      let val = this.getSpace(spaceProp);
      res.top = val;
      res.right = val;
      res.bottom = val;
      res.left = val;
    } else if (typeof spaceProp === 'object') {
      let record = spaceProp as Record<string, Object>;
      res.top = this.getSpace(record['top']);
      res.bottom = this.getSpace(record['bottom']);
      res.left = this.getSpace(record['left']);
      res.right = this.getSpace(record['right']);
    }
    return res;
  }

  build() {
    Stack() {
      // 💥 修复 6：build() 内部只剩下纯粹的 UI 声明，完全符合 ArkUI 引擎规范
      if (this.isVisible) {

        // 第 1 层：Margin 区域 (半透明橙色)
        Rect()
          .width(this.targetW + this.marginSpace.left + this.marginSpace.right)
          .height(this.targetH + this.marginSpace.top + this.marginSpace.bottom)
          .position({
            x: this.targetX - this.marginSpace.left,
            y: this.targetY - this.marginSpace.top
          })
          .fill('#88FF9800')

        // 第 2 层：Padding/Border 区域 (半透明绿色)
        Rect()
          .width(this.targetW)
          .height(this.targetH)
          .position({ x: this.targetX, y: this.targetY })
          .fill('#884CAF50')

        // 第 3 层：Content 内容区域 (半透明蓝色)
        Rect()
          .width(this.targetW - this.paddingSpace.left - this.paddingSpace.right)
          .height(this.targetH - this.paddingSpace.top - this.paddingSpace.bottom)
          .position({
            x: this.targetX + this.paddingSpace.left,
            y: this.targetY + this.paddingSpace.top
          })
          .fill('#882196F3')
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent) // 事件穿透
  }
}