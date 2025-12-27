import 'package:flutter/material.dart';

// Padding 위젯
//
// 사용 예시:
// ```dart
// CustomPadding.all(16, child: Widget())
// CustomPadding.horizontal(16, child: Widget())
// ```
class CustomPadding extends StatelessWidget {
  // 패딩을 적용할 자식 위젯 (필수)
  final Widget child;

  // 커스텀 패딩 값 (padding이 지정되면 다른 속성들은 무시됨)
  final EdgeInsets? padding;

  // 모든 방향에 동일한 패딩 적용
  final double? all;

  // 수평 방향(좌우) 패딩
  final double? horizontal;

  // 수직 방향(상하) 패딩
  final double? vertical;

  // 위쪽 패딩
  final double? top;

  // 아래쪽 패딩
  final double? bottom;

  // 왼쪽 패딩
  final double? left;

  // 오른쪽 패딩
  final double? right;

  const CustomPadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  // 모든 방향에 동일한 패딩을 적용하는 생성자
  const CustomPadding.all(this.all, {super.key, required this.child})
    : padding = null,
      horizontal = null,
      vertical = null,
      top = null,
      bottom = null,
      left = null,
      right = null;

  // 수평 방향(좌우)에 패딩을 적용하는 생성자
  const CustomPadding.horizontal(
    this.horizontal, {
    super.key,
    required this.child,
  }) : padding = null,
       all = null,
       vertical = null,
       top = null,
       bottom = null,
       left = null,
       right = null;

  // 수직 방향(상하)에 패딩을 적용하는 생성자
  const CustomPadding.vertical(this.vertical, {super.key, required this.child})
    : padding = null,
      all = null,
      horizontal = null,
      top = null,
      bottom = null,
      left = null,
      right = null;

  @override
  Widget build(BuildContext context) {
    // padding이 명시적으로 지정된 경우 그것을 사용
    if (padding != null) {
      return Padding(padding: padding!, child: child);
    }

    // all이 지정된 경우
    if (all != null) {
      return Padding(padding: EdgeInsets.all(all!), child: child);
    }

    // 개별 방향 패딩 값들을 조합하여 EdgeInsets 생성
    final EdgeInsets finalPadding = EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );

    return Padding(padding: finalPadding, child: child);
  }
}
