import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

String get apiBaseUrl {
  // 🌍 PROD
  if (kReleaseMode) {
    return 'https://api.loudence.com';
  }

  // 🌐 WEB (Mac tarayıcıdan Windows backend)
  if (kIsWeb) {
    return 'http://192.168.0.17:8000';
  }

  // 🍎 iOS Simulator / Device
  if (Platform.isIOS) {
    return 'http://192.168.0.17:8000';
  }

  // 🤖 Android Emulator
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }

  // Fallback
  return 'http://192.168.0.17:8000';
}
