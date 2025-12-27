import 'package:flutter/cupertino.dart';

// iOS 스타일 날짜 선택기 위젯
//
// 사용 예시:
// ```dart
// CustomCupertinoDatePicker(mode: CupertinoDatePickerMode.date, onDateTimeChanged: (date) {})
// CustomCupertinoDatePicker(mode: CupertinoDatePickerMode.dateAndTime, onDateTimeChanged: (dateTime) {})
// ```
class CustomCupertinoDatePicker extends StatelessWidget {
  // 날짜 선택기 모드 (필수)
  final CupertinoDatePickerMode mode;

  // 날짜/시간 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<DateTime> onDateTimeChanged;

  // 초기 날짜/시간
  final DateTime? initialDateTime;

  // 선택 가능한 최소 날짜
  final DateTime? minimumDate;

  // 선택 가능한 최대 날짜
  final DateTime? maximumDate;

  // 분 간격 (시간 모드에서 사용)
  final int? minuteInterval;

  // 사용 가능한 날짜 필터 함수
  final bool Function(DateTime)? use24hFormat;

  // 24시간 형식 사용 여부 (기본값: false)
  final bool use24HourFormat;

  // 날짜 선택기 높이 (기본값: 216)
  final double? itemExtent;

  // 배경색
  final Color? backgroundColor;

  // 선택기 아이템 스타일
  final TextStyle? textStyle;

  const CustomCupertinoDatePicker({
    super.key,
    required this.mode,
    required this.onDateTimeChanged,
    this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.minuteInterval,
    this.use24hFormat,
    this.use24HourFormat = false,
    this.itemExtent,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: itemExtent ?? 216,
      color:
          backgroundColor ??
          CupertinoColors.systemBackground.resolveFrom(context),
      child: CupertinoDatePicker(
        mode: mode,
        initialDateTime: initialDateTime ?? DateTime.now(),
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        minuteInterval: minuteInterval ?? 1,
        use24hFormat: use24HourFormat,
        onDateTimeChanged: onDateTimeChanged,
        itemExtent: itemExtent ?? 32,
        dateOrder: DatePickerDateOrder.ymd,
      ),
    );
  }
}
