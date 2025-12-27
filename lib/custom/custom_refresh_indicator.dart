import 'package:flutter/material.dart';

// Pull to refresh 기능 위젯
//
// 사용 예시:
// ```dart
// CustomRefreshIndicator(
//   onRefresh: () async {},
//   child: ListView(...),
// )
// ```
class CustomRefreshIndicator extends StatelessWidget {
  // 새로고침 시 실행될 비동기 콜백 (필수)
  final Future<void> Function() onRefresh;

  // 새로고침 인디케이터 아래에 표시할 자식 위젯 (필수)
  final Widget child;

  // 새로고침 인디케이터 색상
  final Color? color;

  // 새로고침 인디케이터 배경색
  final Color? backgroundColor;

  // 새로고침 인디케이터가 표시되는 위치 (화면 상단으로부터의 거리)
  final double? displacement;

  // 새로고침 인디케이터가 표시되는 동안 스크롤이 가능한지 여부를 결정하는 함수
  final ScrollNotificationPredicate? notificationPredicate;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement,
    this.notificationPredicate,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      displacement: displacement ?? 40.0,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      child: child,
    );
  }
}
