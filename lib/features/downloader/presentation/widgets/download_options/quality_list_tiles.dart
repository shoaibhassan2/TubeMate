import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';
import 'quality_enum.dart';

List<Widget> buildQualityTiles(
  BuildContext context,
  TikTokVideoData videoData,
  VideoQuality selectedQuality,
  ValueChanged<VideoQuality?> onChanged,
  String musicDurationText,
) {
  final theme = Theme.of(context);
  return [
    if ((videoData.play?.isNotEmpty ?? false) || (videoData.hdplay?.isNotEmpty ?? false))
      ListTile(
        onTap: () => onChanged(VideoQuality.hdNoWatermark),
        title: Text('HD Video (No Watermark)', style: theme.textTheme.bodyLarge),
        leading: Radio<VideoQuality>(
          value: VideoQuality.hdNoWatermark,
          groupValue: selectedQuality,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        trailing: Text(
          '~${((videoData.hdSize ?? videoData.size ?? 0) / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ),
    if (videoData.wmplay?.isNotEmpty ?? false)
      ListTile(
        onTap: () => onChanged(VideoQuality.hdWithWatermark),
        title: Text('HD Video (With Watermark)', style: theme.textTheme.bodyLarge),
        leading: Radio<VideoQuality>(
          value: VideoQuality.hdWithWatermark,
          groupValue: selectedQuality,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        trailing: Text(
          '~${((videoData.wmSize ?? 0) / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ),
    if (videoData.music?.isNotEmpty ?? false)
      ListTile(
        onTap: () => onChanged(VideoQuality.audioOnly),
        title: Text('Audio Only', style: theme.textTheme.bodyLarge),
        leading: Radio<VideoQuality>(
          value: VideoQuality.audioOnly,
          groupValue: selectedQuality,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        trailing: Text(
          musicDurationText,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ),
  ];
}

VideoQuality determineInitialQuality(TikTokVideoData videoData) {
  if ((videoData.hdplay?.isNotEmpty ?? false) || (videoData.play?.isNotEmpty ?? false)) {
    return VideoQuality.hdNoWatermark;
  } else if (videoData.wmplay?.isNotEmpty ?? false) {
    return VideoQuality.hdWithWatermark;
  } else if (videoData.music?.isNotEmpty ?? false) {
    return VideoQuality.audioOnly;
  } else {
    return VideoQuality.none;
  }
}

String getMusicDurationText(TikTokVideoData videoData) {
  final seconds = videoData.musicInfo?.duration ?? 0;
  return seconds > 0 ? '~${(seconds / 60).toStringAsFixed(1)} min' : '';
}
