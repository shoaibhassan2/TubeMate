import 'package:tubemate/features/downloader/data/models/tiktok_commerce_data.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_music_data.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_author_data.dart';
class TikTokVideoData {
  String? id;
  String? region;
  String? title;
  String? cover;
  String? originCover;
  int? duration;
  String? play; // URL for video without watermark (often HD)
  String? wmplay; // URL for video with watermark (often HD)
  String? hdplay; // Added for potentially higher quality HD
  int? size;
  int? wmSize;
  int? hdSize; // Size for hdplay
  String? music; // URL for audio only
  MusicInfo? musicInfo;
  int? playCount;
  int? diggCount;
  int? commentCount;
  int? shareCount;
  int? downloadCount;
  int? collectCount;
  int? createTime;
  dynamic anchors; // Can be null
  String? anchorsExtras;
  bool? isAd;
  CommerceInfo? commerceInfo;
  String? commercialVideoInfo;
  Author? author;

  TikTokVideoData({
    this.id, this.region, this.title, this.cover, this.originCover, this.duration,
    this.play, this.wmplay, this.hdplay, this.size, this.wmSize, this.hdSize, this.music, this.musicInfo,
    this.playCount, this.diggCount, this.commentCount, this.shareCount,
    this.downloadCount, this.collectCount, this.createTime, this.anchors,
    this.anchorsExtras, this.isAd, this.commerceInfo, this.commercialVideoInfo, this.author,
  });

  TikTokVideoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    region = json['region'];
    title = json['title'];
    cover = json['cover'];
    originCover = json['origin_cover'];
    duration = json['duration'];
    play = json['play'];
    wmplay = json['wmplay'];
    hdplay = json['hdplay'];
    size = json['size'];
    wmSize = json['wm_size'];
    hdSize = json['hd_size'];
    music = json['music'];
    musicInfo = json['music_info'] != null
        ? MusicInfo.fromJson(json['music_info']) // <--- MusicInfo is now defined below
        : null;
    playCount = json['play_count'];
    diggCount = json['digg_count'];
    commentCount = json['comment_count'];
    shareCount = json['share_count'];
    downloadCount = json['download_count'];
    collectCount = json['collect_count'];
    createTime = json['create_time'];
    anchors = json['anchors'];
    anchorsExtras = json['anchors_extras'];
    isAd = json['is_ad'];
    commerceInfo = json['commerce_info'] != null
        ? CommerceInfo.fromJson(json['commerce_info']) // <--- CommerceInfo is now defined below
        : null;
    commercialVideoInfo = json['commercial_video_info'];
    author = json['author'] != null
        ? Author.fromJson(json['author']) // <--- Author is now defined below
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['region'] = region;
    data['title'] = title;
    data['cover'] = cover;
    data['origin_cover'] = originCover;
    data['duration'] = duration;
    data['play'] = play;
    data['wmplay'] = wmplay;
    data['hdplay'] = hdplay;
    data['size'] = size;
    data['wm_size'] = wmSize;
    data['hd_size'] = hdSize;
    data['music'] = music;
    if (musicInfo != null) {
      data['music_info'] = musicInfo!.toJson();
    }
    data['play_count'] = playCount;
    data['digg_count'] = diggCount;
    data['comment_count'] = commentCount;
    data['share_count'] = shareCount;
    data['download_count'] = downloadCount;
    data['collect_count'] = collectCount;
    data['create_time'] = createTime;
    data['anchors'] = anchors;
    data['anchors_extras'] = anchorsExtras;
    data['is_ad'] = isAd;
    if (commerceInfo != null) {
      data['commerce_info'] = commerceInfo!.toJson();
    }
    data['commercial_video_info'] = commercialVideoInfo;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    return data;
  }
}