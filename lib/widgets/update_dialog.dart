import 'package:flutter/material.dart';

import '../services/update_service.dart';

/// Checks for an update and, if one is available, shows the update dialog.
///
/// When [silent] is true (e.g. the automatic check on startup) nothing is shown
/// if the app is already up to date or the check fails. When false (the manual
/// "Check for updates" button) a short confirmation is shown instead.
Future<void> checkForUpdateAndPrompt(
  BuildContext context, {
  bool silent = false,
}) async {
  final info = await UpdateService.checkForUpdate();
  if (!context.mounted) return;

  final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
  if (info == null) {
    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'You are using the latest version.'
              : 'شما از آخرین نسخه استفاده می‌کنید.'),
        ),
      );
    }
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: !info.mandatory,
    builder: (_) => UpdateDialog(info: info),
  );
}

/// Update dialog that downloads the APK (with a progress bar) and launches the
/// system installer.
class UpdateDialog extends StatefulWidget {
  const UpdateDialog({Key? key, required this.info}) : super(key: key);

  final UpdateInfo info;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  bool get _isEnglish =>
      Localizations.localeOf(context).languageCode == 'en';

  Future<void> _startUpdate() async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });
    try {
      await UpdateService.downloadAndInstall(
        widget.info,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      // The system installer has taken over; close the dialog.
      if (mounted) Navigator.of(context).pop();
    } on InstallPermissionRequired {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = _isEnglish
            ? 'Please allow installing apps from this source, then tap Update again.'
            : 'لطفاً اجازهٔ نصب برنامه از این منبع را بدهید، سپس دوباره «به‌روزرسانی» را بزنید.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = _isEnglish
            ? 'Update failed. Check your connection and try again.'
            : 'به‌روزرسانی ناموفق بود. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final title = _isEnglish
        ? 'Update available'
        : 'به‌روزرسانی جدید';
    final versionLine = _isEnglish
        ? 'Version ${info.version} is available.'
        : 'نسخهٔ ${info.version} در دسترس است.';

    return PopScope(
      canPop: !info.mandatory && !_downloading,
      child: AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(versionLine),
            if (info.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(info.notes),
            ],
            if (_downloading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
              ),
              const SizedBox(height: 8),
              Text(
                _progress > 0
                    ? '${(_progress * 100).toStringAsFixed(0)}%'
                    : (_isEnglish ? 'Downloading…' : 'در حال دانلود…'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: _downloading
            ? const []
            : [
                if (!info.mandatory)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(_isEnglish ? 'Later' : 'بعداً'),
                  ),
                FilledButton(
                  onPressed: _startUpdate,
                  child: Text(_isEnglish ? 'Update' : 'به‌روزرسانی'),
                ),
              ],
      ),
    );
  }
}
