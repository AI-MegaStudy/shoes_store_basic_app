import 'package:flutter/foundation.dart';

/// 앱 전역 로깅 유틸리티 클래스
///
/// 디버그 모드: 모든 로그 출력
/// 릴리즈 모드: 에러 로그만 출력 (선택적)
class AppLogger {
  static const bool _enableReleaseErrorLogs = true;

  /// 디버그 로그
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('🔵 DEBUG: $prefix$message');
    }
  }

  /// 정보 로그
  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('ℹ️ INFO: $prefix$message');
    }
  }

  /// 경고 로그
  static void w(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('⚠️ WARN: $prefix$message');
      if (error != null) {
        print('   Error: $error');
      }
    }
  }

  /// 에러 로그 (릴리즈 모드에서도 출력 가능)
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode || _enableReleaseErrorLogs) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('❌ ERROR: $prefix$message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// 성공 로그
  static void s(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('✅ SUCCESS: $prefix$message');
    }
  }
}
