import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class SimpleUpdateService {
  static const String updateUrl = 'https://api.github.com/repos/yourusername/persian-calendar/releases/latest';
  
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final response = await http.get(Uri.parse(updateUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].replaceFirst('v', '');
        final downloadUrl = data['html_url'];
        
        if (_isNewerVersion(currentVersion, latestVersion)) {
          _showUpdateDialog(context, latestVersion, downloadUrl);
        }
      }
    } catch (e) {
      print('خطا در بررسی آپدیت: $e');
    }
  }
  
  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
  
  static void _showUpdateDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آپدیت جدید'),
        content: Text('نسخه $version موجود است. آیا میخواهید آپدیت کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بعداً'),
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(url));
              Navigator.pop(context);
            },
            child: const Text('آپدیت'),
          ),
        ],
      ),
    );
  }
}