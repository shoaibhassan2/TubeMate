import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

void handleTap(BuildContext context, DownloadItemModel item) async {
  if (item.status == DownloadStatus.completed && item.publicGalleryPath != null) {
    final result = await OpenFile.open(item.publicGalleryPath!);
    if (result.type != ResultType.done) {
      showSnack(context, 'Could not open file: ${result.message}', Colors.red);
    }
  } else if (item.status == DownloadStatus.failed) {
    showSnack(context, 'Download failed: ${item.errorMessage}');
  } else {
    showSnack(context, 'File not yet available for opening.');
  }
}

Widget buildThumbnail(DownloadItemModel item, ThemeData theme) {
  if (item.thumbnailUrl.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        item.thumbnailUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.image_not_supported, size: 40, color: theme.iconTheme.color),
      ),
    );
  } else {
    return Icon(item.isVideo ? Icons.movie : Icons.audiotrack, size: 40, color: theme.iconTheme.color);
  }
}

void showSnack(BuildContext context, String text, [Color? background]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), backgroundColor: background),
  );
}
