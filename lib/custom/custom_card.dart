import 'package:flutter/material.dart';

// Material Design Card 위젯
//
// 사용 예시:
// ```dart
// CustomCard(child: Widget())
// CustomCard(child: Widget(), padding: EdgeInsets.all(16), elevation: 5)
// ```
class CustomCard extends StatelessWidget {
  // 카드 내부에 표시할 자식 위젯 (필수)
  final Widget child;

  // 카드 배경색
  final Color? color;

  // 카드 elevation (그림자 효과, 기본값: 2)
  final double? elevation;

  // 카드 모서리 둥글기 (기본값: 12)
  final double? borderRadius;

  // 카드 전체에 적용할 패딩 (기본값: EdgeInsets.all(16))
  final EdgeInsets? padding;

  // 카드 마진
  final EdgeInsets? margin;

  // 카드 너비
  final double? width;

  // 카드 높이

  final double? height;

  // 카드 모양 (shape)
  final ShapeBorder? shape;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 값들 설정
    final cardElevation = elevation ?? 2.0;
    final radius = borderRadius ?? 12.0;
    final cardPadding = padding ?? const EdgeInsets.all(16);
    final cardShape =
        shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    Widget card = Card(
      color: color,
      elevation: cardElevation,
      shape: cardShape,
      margin: margin,
      child: Padding(padding: cardPadding, child: child),
    );

    // width나 height가 지정된 경우 SizedBox로 감싸기
    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }

    return card;
  }
}
