import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

class DownloadExecutor {
  static Future<void> executeDownload({
    required Dio dio,
    required DownloadItemModel downloadItem,
    required void Function(String id, {
      DownloadStatus? status,
      double? progress,
      String? tempLocalFilePath,
      String? publicGalleryPath,
      String? errorMessage,
    }) updateDownloadItem,
    required List<DownloadItemModel> Function() getDownloadsList,
  }) async {
    String tempLocalFilePath;
    if (downloadItem.tempLocalFilePath == null) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = Directory('${tempDir.path}/TubeMate_Temp_Downloads');
      if (!await tempPath.exists()) {
        await tempPath.create(recursive: true);
      }
      tempLocalFilePath = '${tempPath.path}/${downloadItem.fileName}';
      updateDownloadItem(downloadItem.id, tempLocalFilePath: tempLocalFilePath);
    } else {
      tempLocalFilePath = downloadItem.tempLocalFilePath!;
    }

    try {
      debugPrint('DownloadExecutor: Starting download of ${downloadItem.fileName} to $tempLocalFilePath');
      updateDownloadItem(downloadItem.id, status: DownloadStatus.downloading);

      await dio.download(
        downloadItem.downloadUrl,
        tempLocalFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final double progress = received / total;
            updateDownloadItem(downloadItem.id, progress: progress);
          }
        },
        options: Options(
          headers: downloadItem.tempLocalFilePath != null ? {'Range': 'bytes=${await File(tempLocalFilePath).length()}-'} : null,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
        cancelToken: downloadItem.cancelToken,
      );

      updateDownloadItem(downloadItem.id, status: DownloadStatus.pending, progress: 0.0);

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) throw Exception('Unable to access Downloads directory.');

      final targetDir = Directory('${downloadsDir.path}/TubeMate');
      if (!await targetDir.exists()) await targetDir.create(recursive: true);

      final File destFile = File('${targetDir.path}/${downloadItem.fileName}');
      String finalPath;
      if (await destFile.exists()) {
        final base = downloadItem.fileName.substring(0, downloadItem.fileName.lastIndexOf('.'));
        final ext = downloadItem.fileName.substring(downloadItem.fileName.lastIndexOf('.'));
        finalPath = '${targetDir.path}/$base-${DateTime.now().millisecondsSinceEpoch}$ext';
      } else {
        finalPath = destFile.path;
      }

      await File(tempLocalFilePath).copy(finalPath);
      updateDownloadItem(downloadItem.id, status: DownloadStatus.completed, publicGalleryPath: finalPath, tempLocalFilePath: tempLocalFilePath);

    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) {
        String error = 'Network error: ${e.type.name}';
        if (e.response != null) {
          error += ' (HTTP ${e.response?.statusCode})';
        } else if (e.message != null) {
          error += ' - ${e.message}';
        }
        updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: error);
      }
    } catch (e, st) {
      updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: e.toString());
      debugPrint('DownloadExecutor: Unexpected error: $e\n$st');
    } finally {
      final item = getDownloadsList().firstWhere((e) => e.id == downloadItem.id);
      if ([DownloadStatus.completed, DownloadStatus.failed, DownloadStatus.cancelled].contains(item.status)) {
        final f = File(tempLocalFilePath);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    }
  }
}
