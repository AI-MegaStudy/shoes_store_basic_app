import 'package:flutter/material.dart';

/// 공용 컬러 스키마
///
/// 다른 앱에서도 재사용 가능한 기본 컬러들을 정의합니다.
/// - 배경색, 카드 배경색
/// - Primary, Accent 색상
/// - 텍스트 색상 (Primary, Secondary)
/// - 구분선 색상
/// - 필터 칩 색상
class CommonColorScheme {
  /// 전체 배경 색
  final Color background;

  /// 카드/패널 배경 색
  final Color cardBackground;

  /// 주요 포인트 색
  final Color primary;

  /// 보조 포인트 색
  final Color accent;

  /// 기본 텍스트 색
  final Color textPrimary;

  /// 보조 텍스트 색
  final Color textSecondary;

  /// 구분선 색
  final Color divider;

  /// 필터 칩 선택 배경 색
  final Color chipSelectedBg;

  /// 필터 칩 선택 텍스트 색
  final Color chipSelectedText;

  /// 필터 칩 비선택 배경 색
  final Color chipUnselectedBg;

  /// 필터 칩 비선택 텍스트 색
  final Color chipUnselectedText;

  /// Primary 색상 배경에 사용할 텍스트 색 (반전색, 기본: 흰색)
  final Color textOnPrimary;

  const CommonColorScheme({
    required this.background,
    required this.cardBackground,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.chipSelectedBg,
    required this.chipSelectedText,
    required this.chipUnselectedBg,
    required this.chipUnselectedText,
    required this.textOnPrimary,
  });
}
