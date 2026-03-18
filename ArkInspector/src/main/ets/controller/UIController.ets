/**
 * Date: 2026/3/18
 * File Name: UIController.ets
 * Author: Jason
 **/
/**
 * Date: 2026/3/18
 * File Name: UIController.ets
 * Author: Jason
 **/
import { JsonValue } from "../modifiers/DynamicBaseModifier";
import { UIInspector } from "../core/UIInspector"

@ObservedV2
export class UIController {

  @Trace public style: Record<string, Object>;

  constructor(initialStyle: Record<string, Object>) {
    this.style = initialStyle;
  }

  update(key: string, value: JsonValue) {
    let newStyle: Record<string, Object> = {};
    let keys = Object.keys(this.style);
    for (let i = 0; i < keys.length; i++) {
      newStyle[keys[i]] = this.style[keys[i]];
    }
    newStyle[key] = value as Object;
    this.style = newStyle;
  }

  // 透传 originalClick，把判断交还给底层的 withInspect 在“点击瞬间”去执行！
  bindInspector(id: string, originalClick?: () => void): (e: ClickEvent) => void {
    return UIInspector.withInspect(
      id,
      this.style,
      (newStyle: ESObject) => {
        // 探针传回数据，内部消化并触发刷新
        this.style = newStyle as Record<string, Object>;
      },
      originalClick // 💥 将业务的原始点击逻辑透传到底层
    );
  }
}