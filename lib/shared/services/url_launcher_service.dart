import 'package:flutter/services.dart';

class UrlLauncherService {
  static const _channel = MethodChannel('com.davide.biteplan/launcher');

  static Future<void> launch(String url) async {
    await _channel.invokeMethod<void>('launch', {'url': url});
  }
}
