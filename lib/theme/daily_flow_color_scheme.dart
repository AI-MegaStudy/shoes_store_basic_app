import 'package:flutter/material.dart';

/// DailyFlow 앱 전용 컬러 스키마
///
/// 이 앱에서만 사용하는 특수 컬러들을 정의합니다.
/// - Progress Bar 색상 (아침/낮/저녁/Anytime)
/// - 중요도 색상 (1~5단계)
class DailyFlowColorScheme {
  /// 요약 Progress Bar - 아침 색상
  final Color progressMorning;

  /// 요약 Progress Bar - 낮 색상
  final Color progressNoon;

  /// 요약 Progress Bar - 저녁 색상
  final Color progressEvening;

  /// 요약 Progress Bar - 야간 색상
  final Color progressNight;

  /// 요약 Progress Bar - 종일 색상
  final Color progressAnytime;

  /// 중요도 1단계: 매우 낮음
  final Color priorityVeryLow;

  /// 중요도 2단계: 낮음
  final Color priorityLow;

  /// 중요도 3단계: 보통
  final Color priorityMedium;

  /// 중요도 4단계: 높음
  final Color priorityHigh;

  /// 중요도 5단계: 매우 높음
  final Color priorityVeryHigh;

  const DailyFlowColorScheme({
    required this.progressMorning,
    required this.progressNoon,
    required this.progressEvening,
    required this.progressNight,
    required this.progressAnytime,
    required this.priorityVeryLow,
    required this.priorityLow,
    required this.priorityMedium,
    required this.priorityHigh,
    required this.priorityVeryHigh,
  });
}
