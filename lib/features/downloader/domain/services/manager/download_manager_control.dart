import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_executor.dart';

typedef DownloadUpdater = void Function(
  String id, {
  DownloadStatus? status,
  double? progress,
  String? tempLocalFilePath,
  String? publicGalleryPath,
  String? errorMessage,
});

class DownloadManagerControl {
  static Future<void> pauseDownload({
    required List<DownloadItemModel> downloads,
    required String id,
    required DownloadUpdater update,
  }) async {
    final int index = downloads.indexWhere((item) => item.id == id);
    if (index != -1 && downloads[index].status == DownloadStatus.downloading) {
      update(id, status: DownloadStatus.paused);
      downloads[index].cancelToken?.cancel('Download paused by user');
    }
  }

  static Future<void> resumeDownload({
    required List<DownloadItemModel> downloads,
    required String id,
    required DownloadUpdater update,
    required Dio dio,
  }) async {
    final int index = downloads.indexWhere((item) => item.id == id);
    if (index == -1 ||
        (downloads[index].status != DownloadStatus.paused &&
         downloads[index].status != DownloadStatus.failed)) {
      return;
    }

    final DownloadItemModel itemToResume = downloads[index];
    update(itemToResume.id, status: DownloadStatus.pending);

    int startBytes = 0;
    if (itemToResume.tempLocalFilePath != null) {
      final File tempFile = File(itemToResume.tempLocalFilePath!);
      if (await tempFile.exists()) {
        startBytes = await tempFile.length();
      }
    }

    final newCancelToken = CancelToken();
    downloads[index] = itemToResume.copyWith(cancelToken: newCancelToken);

    await DownloadExecutor.executeDownload(
      dio: dio,
      downloadItem: downloads[index],
      updateDownloadItem: update,
      getDownloadsList: () => downloads,
    );
  }

  static Future<void> cancelDownload({
    required List<DownloadItemModel> downloads,
    required String id,
    required DownloadUpdater update,
  }) async {
    final int index = downloads.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = downloads[index];
      update(id, status: DownloadStatus.cancelled);
      item.cancelToken?.cancel('Download cancelled by user');
    }
  }
}
