import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Selects the real (dart:io) downloader on native platforms and a throwing
// stub on web, so this file compiles for every target.
import 'apk_downloader_stub.dart'
    if (dart.library.io) 'apk_downloader_io.dart' as downloader;

/// Describes an available update, read from Firestore (`app_config/latest`).
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.build,
    required this.apkUrl,
    required this.notes,
    required this.mandatory,
  });

  final String version;
  final int build;
  final String apkUrl;
  final String notes;
  final bool mandatory;
}

/// Thrown by [UpdateService.downloadAndInstall] when the user still has to
/// grant the "install unknown apps" permission. The UI should ask the user to
/// grant it (the settings screen is opened automatically) and try again.
class InstallPermissionRequired implements Exception {
  const InstallPermissionRequired();
}

/// Self-hosted, in-app updater for directly distributed APKs.
///
/// No extra pub packages are required: the version manifest is read from the
/// Firestore document `app_config/latest`, the APK is downloaded with
/// `dart:io`, and the install is triggered through a small platform channel
/// (see MainActivity.kt). Android only.
class UpdateService {
  static const MethodChannel _channel =
      MethodChannel('persian_calendar/updater');

  /// Firestore location of the update manifest. Fields:
  ///   version   (String)  e.g. "1.0.1"
  ///   build     (int)     e.g. 2  (must match the pubspec version code)
  ///   apk_url   (String)  https URL of the APK to download
  ///   notes     (String)  release notes shown to the user
  ///   mandatory (bool)    if true the update cannot be dismissed
  static const String _collection = 'app_config';
  static const String _document = 'latest';

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Returns update info if a newer version is published, otherwise null.
  /// Never throws — returns null on any error so callers can ignore it.
  static Future<UpdateInfo?> checkForUpdate() async {
    if (!_isAndroid) return null;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_document)
          .get();
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;

      final apkUrl = (data['apk_url'] ?? '').toString();
      if (apkUrl.isEmpty) return null;

      final latestVersion = (data['version'] ?? '').toString();
      final latestBuild = _asInt(data['build']);

      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final bool isNewer = latestBuild > currentBuild ||
          _compareVersions(latestVersion, info.version) > 0;
      if (!isNewer) return null;

      return UpdateInfo(
        version: latestVersion.isEmpty ? info.version : latestVersion,
        build: latestBuild,
        apkUrl: apkUrl,
        notes: (data['notes'] ?? '').toString(),
        mandatory: data['mandatory'] == true,
      );
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate error: $e');
      return null;
    }
  }

  /// Downloads the APK (reporting [onProgress] in the 0..1 range when the
  /// server sends a content length) and launches the system installer.
  ///
  /// Throws [InstallPermissionRequired] if the "install unknown apps"
  /// permission is missing; the permission settings are opened automatically
  /// and the caller should ask the user to retry afterwards.
  static Future<void> downloadAndInstall(
    UpdateInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    if (!_isAndroid) {
      throw UnsupportedError('The in-app updater is only supported on Android.');
    }

    final dir = await _channel.invokeMethod<String>('getApkDir');
    if (dir == null || dir.isEmpty) {
      throw Exception('Could not resolve the download directory.');
    }
    final savePath = '$dir/update-${info.build}.apk';

    await downloader.downloadApk(
      info.apkUrl,
      savePath,
      onProgress: onProgress,
    );

    final canInstall = await _channel.invokeMethod<bool>('canInstall') ?? true;
    if (!canInstall) {
      await _channel.invokeMethod('requestInstallPermission');
      throw const InstallPermissionRequired();
    }

    await _channel.invokeMethod('installApk', {'path': savePath});
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  /// Returns > 0 if [a] is newer than [b], < 0 if older, 0 if equal.
  static int _compareVersions(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final length = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < length; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x - y;
    }
    return 0;
  }
}
