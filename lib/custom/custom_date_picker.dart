import 'package:flutter/material.dart';

// 날짜 선택 다이얼로그 헬퍼 클래스
//
// 사용 예시:
// ```dart
// CustomDatePicker.show(context: context)
// CustomDatePicker.show(context: context, initialDate: DateTime(2024, 1, 1), firstDate: DateTime(2000), lastDate: DateTime(2100))
// ```
class CustomDatePicker {
  // 날짜 선택 다이얼로그를 표시합니다.
  //
  // [context] - BuildContext (필수)
  // [initialDate] - 초기 선택 날짜 (기본값: 현재 날짜)
  // [firstDate] - 선택 가능한 최소 날짜 (기본값: 1900년 1월 1일)
  // [lastDate] - 선택 가능한 최대 날짜 (기본값: 2100년 12월 31일)
  // [helpText] - 다이얼로그 도움말 텍스트
  // [cancelText] - 취소 버튼 텍스트 (기본값: "취소")
  // [confirmText] - 확인 버튼 텍스트 (기본값: "확인")
  // [locale] - 로케일 설정
  // [builder] - 커스텀 빌더 함수
  //
  // 반환값: 선택된 DateTime 또는 null (취소한 경우)
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    Widget Function(BuildContext, Widget?)? builder,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initial = initialDate ?? now;
    final DateTime first = firstDate ?? DateTime(1900, 1, 1);
    final DateTime last = lastDate ?? DateTime(2100, 12, 31);

    return await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: helpText,
      cancelText: cancelText ?? "취소",
      confirmText: confirmText ?? "확인",
      locale: locale,
      builder: builder,
    );
  }

  // 날짜 범위 선택 다이얼로그를 표시합니다.
  //
  // [context] - BuildContext (필수)
  // [firstDate] - 선택 가능한 최소 날짜 (기본값: 1900년 1월 1일)
  // [lastDate] - 선택 가능한 최대 날짜 (기본값: 2100년 12월 31일)
  // [helpText] - 다이얼로그 도움말 텍스트
  // [cancelText] - 취소 버튼 텍스트 (기본값: "취소")
  // [confirmText] - 확인 버튼 텍스트 (기본값: "확인")
  // [saveText] - 저장 버튼 텍스트 (기본값: "저장")
  // [locale] - 로케일 설정
  // [builder] - 커스텀 빌더 함수
  //
  // 반환값: 선택된 날짜 범위 (DateTimeRange) 또는 null (취소한 경우)
  static Future<DateTimeRange?> showRange({
    required BuildContext context,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    Locale? locale,
    Widget Function(BuildContext, Widget?)? builder,
  }) async {
    final DateTime first = firstDate ?? DateTime(1900, 1, 1);
    final DateTime last = lastDate ?? DateTime(2100, 12, 31);

    return await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      helpText: helpText,
      cancelText: cancelText ?? "취소",
      confirmText: confirmText ?? "확인",
      saveText: saveText ?? "저장",
      locale: locale,
      builder: builder,
    );
  }
}
