import 'package:flutter/foundation.dart';

/// 백엔드 API 기본 설정.
///
/// 에뮬레이터/실기기에 따라 baseUrl 을 바꿔야 한다:
/// - Android 에뮬레이터: http://10.0.2.2:8080
/// - iOS 시뮬레이터 / 웹: http://localhost:8080
/// - 실기기: PC와 같은 네트워크의 IP (예: http://192.168.0.10:8080)
class ApiConfig {
  static const String _override = String.fromEnvironment(
    'MARING_API_BASE_URL',
  );

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
