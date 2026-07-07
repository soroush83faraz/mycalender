/// Web/unsupported fallback. The in-app updater is native-only, so this is
/// never actually reached (callers guard on the platform first), but it keeps
/// the code compiling for web where `dart:io` is unavailable.
Future<void> downloadApk(
  String url,
  String savePath, {
  void Function(double progress)? onProgress,
}) async {
  throw UnsupportedError('APK download is only supported on Android.');
}
