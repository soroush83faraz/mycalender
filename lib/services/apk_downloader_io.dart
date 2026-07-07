import 'dart:io';

/// Downloads [url] to [savePath], reporting [onProgress] in the 0..1 range when
/// the server provides a content length. Uses only `dart:io` (no extra pub
/// packages). This implementation is selected on native platforms.
Future<void> downloadApk(
  String url,
  String savePath, {
  void Function(double progress)? onProgress,
}) async {
  final file = File(savePath);
  if (await file.exists()) {
    await file.delete();
  }

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }
    final total = response.contentLength;
    var received = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  } finally {
    client.close();
  }
}
