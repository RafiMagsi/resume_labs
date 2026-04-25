import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract final class PlatformConfig {
  static const MethodChannel _channel =
      MethodChannel('com.nextfiction.resumelabs/config');

  static Future<String?> getFirebasePdfFunctionUrl() async {
    if (kIsWeb) return null;
    try {
      final value =
          await _channel.invokeMethod<String>('getFirebasePdfFunctionUrl');
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (_) {
      return null;
    }
  }
}
