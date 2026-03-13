/**
 * Date: 2026/3/13
 * File Name: NewsItemModel.ets
 * Author: Jason
 **/

// ==========================================
// 1. 补充的 Mock 依赖 (确保你的类不会报错)
// ==========================================
export enum NewsPostionType { channelList, searchPubList }

export enum NewsItemLabel { zhuanti = 1 }

export enum NewsItemFlag { zhuanti = 1, fenLeiZhuanti = 2, video = 3 }

export class TimeUtil {
  // static TimeFormatterType = { searchPublish: 1 };
  static formatTime(time: number, type: number): string {
    return "刚刚";
  }
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
    if (this.label == NewsItemLabel.zhuanti || this.flag == NewsItemFlag.zhuanti ||
      this.flag == NewsItemFlag.fenLeiZhuanti) {
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
