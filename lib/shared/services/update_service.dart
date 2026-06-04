import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;

import '../../core/constants/app_constants.dart';

class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/davide3011/biteplan/releases/latest';

  /// Returns the latest version string if it's newer than the current version,
  /// or null if already up to date or if the check fails.
  static Future<String?> checkUpdate() async {
    if (kIsWeb) return null;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final request = await client
          .getUrl(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 5));
      request.headers
        ..set('Accept', 'application/vnd.github+json')
        ..set('User-Agent', 'biteplan/$kAppVersion');
      final response =
          await request.close().timeout(const Duration(seconds: 5));
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (response.statusCode != 200) return null;
      final data = jsonDecode(body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String).replaceFirst(RegExp(r'^v'), '');
      return isNewer(tag, kAppVersion) ? tag : null;
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  static bool isNewer(String remote, String local) {
    final r = parseVersion(remote);
    final l = parseVersion(local);
    for (var i = 0; i < 3; i++) {
      if (r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return false;
  }

  @visibleForTesting
  static List<int> parseVersion(String v) {
    final parts = v.split('.');
    return List.generate(
        3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}
