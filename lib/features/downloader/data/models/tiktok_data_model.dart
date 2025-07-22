// Path: lib/features/downloader/data/models/tiktok_data_model.dart

import 'package:tubemate/features/downloader/data/models/tiktok_author_data.dart';
export 'package:tubemate/features/downloader/data/models/tiktok_video_data.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_video_data.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_commerce_data.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_music_data.dart';


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