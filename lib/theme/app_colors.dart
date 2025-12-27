/// 앱 컬러 시스템 - 모든 컬러 관련 클래스와 확장을 export
///
/// 기존 코드 호환성을 위해 이 파일에서 모든 컬러 관련 요소를 export합니다.
///
/// 사용 예시:
/// ```dart
/// import 'package:shoes_store_basic_app/view/cheng/theme/app_colors.dart';
///
/// final p = context.palette; // AppColorScheme
/// Container(color: p.primary)
/// ```
library;

export 'common_color_scheme.dart';
export 'daily_flow_color_scheme.dart';
export 'app_color_scheme.dart';
export 'app_theme_mode.dart';
export 'palette_context.dart';

import 'package:flutter/material.dart';
import 'common_color_scheme.dart';
import 'app_color_scheme.dart';

/// 라이트 / 다크 팔레트 정의
///
/// 각 테마 모드에 맞는 CommonColorScheme과 DailyFlowColorScheme을 조합하여
/// AppColorScheme을 생성합니다.
class AppColors {
  const AppColors._();

  /// 라이트 테마 컬러 스키마
  static const AppColorScheme light = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFFF5F5F5), // 연한 회색 배경
      cardBackground: Colors.white, // 순수 흰색 카드
      primary: Color(0xFF1976D2), // Material Blue 700
      accent: Color(0xFFFF9800), // Material Orange 500
      textPrimary: Color(0xFF212121), // 거의 검은색 텍스트
      textSecondary: Color(0xFF757575), // 중간 회색 텍스트
      divider: Color(0xFFE0E0E0), // 연한 회색 구분선
      chipSelectedBg: Color(0xFF1976D2), // Primary와 동일
      chipSelectedText: Colors.white, // 흰색 텍스트
      chipUnselectedBg: Color(0xFFE3F2FD), // 연한 파랑 배경
      chipUnselectedText: Color(0xFF1565C0), // 진한 파랑 텍스트
      textOnPrimary: Colors.white, // Primary 배경에 사용할 흰색 텍스트
    ) /*,
    dailyFlow: DailyFlowColorScheme(
      progressMorning: Color(0xFFFF9800), // 주황색 (오전)
      progressNoon: Color(0xFFFFEB3B), // 밝은 노란색 (오후)
      progressEvening: Color(0xFF00BCD4), // 청록색 (저녁)
      progressNight: Color(0xFF673AB7), // 보라색 (야간)
      progressAnytime: Color(0xFF9C27B0), // 보라색 (종일)
      priorityVeryLow: Color(0xFF9E9E9E), // 회색 (매우 낮음)
      priorityLow: Color(0xFF2196F3), // 파란색 (낮음)
      priorityMedium: Color(0xFF4CAF50), // 초록색 (보통)
      priorityHigh: Color(0xFFFF9800), // 주황색 (높음)
      priorityVeryHigh: Color(0xFFF44336), // 빨간색 (매우 높음)
    ),
    */,
  );

  /// 다크 테마 컬러 스키마
  static const AppColorScheme dark = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFF121212), // Material Dark 배경
      cardBackground: Color(0xFF1E1E1E), // 약간 밝은 다크 카드
      primary: Color(0xFF90CAF9), // 밝은 파랑 (다크 모드용)
      accent: Color(0xFFFFB74D), // 밝은 주황 (다크 모드용)
      textPrimary: Color(0xFFFFFFFF), // 순수 흰색 텍스트
      textSecondary: Color(0xFFB0B0B0), // 밝은 회색 텍스트
      divider: Color(0xFF424242), // 중간 회색 구분선
      chipSelectedBg: Color(0xFF1976D2), // Primary 색상 (다크에서도 잘 보임)
      chipSelectedText: Colors.white, // 흰색 텍스트 (가독성 향상)
      chipUnselectedBg: Color(0xFF2C2C2C), // 약간 밝은 다크 배경
      chipUnselectedText: Color(0xFFB0BEC5), // 밝은 회색 텍스트
      textOnPrimary: Colors.black, // Primary 배경에 사용할 검은색 텍스트
    ),
    /*
    ,
    dailyFlow: DailyFlowColorScheme(
      progressMorning: Color(0xFFFFB74D), // 밝은 주황색 (오전)
      progressNoon: Color(0xFFFFF59D), // 밝은 노란색 (오후)
      progressEvening: Color(0xFF4DD0E1), // 밝은 청록색 (저녁)
      progressNight: Color(0xFF9575CD), // 밝은 보라색 (야간)
      progressAnytime: Color(0xFFCE93D8), // 밝은 보라색 (종일)
      priorityVeryLow: Color(0xFF757575), // 밝은 회색 (매우 낮음)
      priorityLow: Color(0xFF64B5F6), // 밝은 파란색 (낮음)
      priorityMedium: Color(0xFF81C784), // 밝은 초록색 (보통)
      priorityHigh: Color(0xFFFFB74D), // 밝은 주황색 (높음)
      priorityVeryHigh: Color(0xFFE57373), // 밝은 빨간색 (매우 높음)
    ),
    */
  );
}
