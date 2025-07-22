import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart'; 
import 'package:tubemate/features/downloader/domain/enums/download_status.dart'; 
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart'; 
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_notification.dart';
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_executor.dart';
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_persistence.dart';
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_cleanup.dart';
import 'package:tubemate/features/downloader/domain/services/manager/download_manager_control.dart';

import 'package:tubemate/core/notifications/notification_initializer.dart'
    show flutterLocalNotificationsPlugin, channel;

class DownloadManagerService extends ValueNotifier<UnmodifiableListView<DownloadItemModel>> {
  final List<DownloadItemModel> _downloadsInternal = [];
  final Dio _dio = Dio();

  DownloadManagerService._internal() : super(UnmodifiableListView([])) {
    _loadDownloads();
  }
  
  static final DownloadManagerService _instance = DownloadManagerService._internal();

  static DownloadManagerService get instance => _instance;
  Future<void> clearFinishedDownloads() async {
    await DownloadManagerCleanup.clearFinishedDownloads(_downloadsInternal);
    _updateAndNotify();
  }

  Future<void> clearAllDownloads() async {
    await DownloadManagerCleanup.clearAllDownloads(_downloadsInternal);
    _updateAndNotify();
  }

  Future<void> deleteDownload(String id) async {
    await DownloadManagerCleanup.deleteDownloadById(_downloadsInternal, id);
    _updateAndNotify();
  }
  void _updateAndNotify() {
    value = UnmodifiableListView(_downloadsInternal);
    _saveDownloads();
  }
  Future<void> _loadDownloads() async {
    final loaded = await DownloadManagerPersistence.loadDownloads();
    _downloadsInternal.clear();
    _downloadsInternal.addAll(loaded);
    _updateAndNotify();
  }
  Future<void> _saveDownloads() async {
    await DownloadManagerPersistence.saveDownloads(_downloadsInternal);
  }
  Future<void> pauseDownload(String id) async {
    await DownloadManagerControl.pauseDownload(
      downloads: _downloadsInternal,
      id: id,
      update: _updateDownloadItem,
    );
  }
  Future<void> resumeDownload(String id) async {
    await DownloadManagerControl.resumeDownload(
      downloads: _downloadsInternal,
      id: id,
      dio: _dio,
      update: _updateDownloadItem,
    );
  }
  Future<void> cancelDownload(String id) async {
    await DownloadManagerControl.cancelDownload(
      downloads: _downloadsInternal,
      id: id,
      update: _updateDownloadItem,
    );
  }
  Future<void> startDownload({
    required String downloadUrl,
    required String fileName,
    required String thumbnailUrl,
    required bool isVideo,
  }) async {
    if (downloadUrl.isEmpty) return;

    final String id = DownloadItemModel.generateId(downloadUrl, isVideo);
    final CancelToken cancelToken = CancelToken();

    final DownloadItemModel downloadItem = DownloadItemModel(
      id: id,
      fileName: fileName,
      downloadUrl: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      isVideo: isVideo,
      status: DownloadStatus.pending,
      cancelToken: cancelToken,
    );

    final int existingItemIndex = _downloadsInternal.indexWhere((item) => item.id == id);
    if (existingItemIndex != -1) {
      _downloadsInternal[existingItemIndex].cancelToken?.cancel('New download instance started for same ID.');
      _downloadsInternal[existingItemIndex] = downloadItem;
    } else {
      _downloadsInternal.add(downloadItem);
    }

    _updateAndNotify();

    await DownloadExecutor.executeDownload(
      dio: _dio,
      downloadItem: downloadItem,
      updateDownloadItem: _updateDownloadItem,
      getDownloadsList: () => _downloadsInternal,
    );
  }

  void _updateDownloadItem(
    String id, {
    DownloadStatus? status,
    double? progress,
    String? tempLocalFilePath,
    String? publicGalleryPath,
    String? errorMessage,
  }) {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    if (index != -1) {
      final DownloadItemModel currentItem = _downloadsInternal[index];

      final bool wasOngoing = currentItem.status == DownloadStatus.downloading ||
          currentItem.status == DownloadStatus.pending ||
          currentItem.status == DownloadStatus.paused;

      _downloadsInternal[index] = currentItem.copyWith(
        status: status,
        progress: progress,
        tempLocalFilePath: tempLocalFilePath,
        publicGalleryPath: publicGalleryPath,
        errorMessage: errorMessage,
      );
      _updateAndNotify();

      if (wasOngoing && (status == DownloadStatus.completed || status == DownloadStatus.failed || status == DownloadStatus.cancelled)) {
        flutterLocalNotificationsPlugin.cancel(currentItem.id.hashCode);
      }
      const DownloadNotificationService().showDownloadNotification(_downloadsInternal[index]);
    }
  }
}
