// Path: lib/features/downloader/data/models/tiktok_data_model.dart

// Make sure all nested classes are defined within this same file
// or imported if they are in separate files (not the case here, usually).

class TikTokDataModel {
  int? code;
  String? msg;
  double? processedTime;
  TikTokVideoData? data;

  TikTokDataModel({this.code, this.msg, this.processedTime, this.data});

  TikTokDataModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    processedTime = json['processed_time'];
    data = json['data'] != null ? TikTokVideoData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    data['processed_time'] = processedTime;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

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

// --- RESTORED CLASSES BELOW ---

class MusicInfo {
  String? id;
  String? title;
  String? play;
  String? cover;
  String? author;
  bool? original;
  int? duration;
  String? album;

  MusicInfo(
      {this.id,
      this.title,
      this.play,
      this.cover,
      this.author,
      this.original,
      this.duration,
      this.album});

  MusicInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    play = json['play'];
    cover = json['cover'];
    author = json['author'];
    original = json['original'];
    duration = json['duration'];
    album = json['album'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['play'] = play;
    data['cover'] = cover;
    data['author'] = author;
    data['original'] = original;
    data['duration'] = duration;
    data['album'] = album;
    return data;
  }
}

class CommerceInfo {
  bool? advPromotable;
  bool? auctionAdInvited;
  int? brandedContentType;
  bool? withCommentFilterWords;

  CommerceInfo(
      {this.advPromotable,
      this.auctionAdInvited,
      this.brandedContentType,
      this.withCommentFilterWords});

  CommerceInfo.fromJson(Map<String, dynamic> json) {
    advPromotable = json['adv_promotable'];
    auctionAdInvited = json['auction_ad_invited'];
    brandedContentType = json['branded_content_type'];
    withCommentFilterWords = json['with_comment_filter_words'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adv_promotable'] = advPromotable;
    data['auction_ad_invited'] = auctionAdInvited;
    data['branded_content_type'] = brandedContentType;
    data['with_comment_filter_words'] = withCommentFilterWords;
    return data;
  }
}

class Author {
  String? id;
  String? uniqueId;
  String? nickname;
  String? avatar;

  Author({this.id, this.uniqueId, this.nickname, this.avatar});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unique_id'] = uniqueId;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    return data;
  }
}