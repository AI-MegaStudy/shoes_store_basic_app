import 'package:flutter/material.dart';

// Row 위젯
//
// 사용 예시:
// ```dart
// CustomRow(children: [Widget1(), Widget2()])
// CustomRow(children: [...], spacing: 16, padding: EdgeInsets.all(16))
// ```
class CustomRow extends StatelessWidget {
  // Row의 자식 위젯들 (필수)
  final List<Widget> children;

  // 자식 위젯들 사이의 간격 (기본값: 12)
  final double? spacing;

  // Row의 정렬 방식 (기본값: MainAxisAlignment.start)
  final MainAxisAlignment? mainAxisAlignment;

  // Row의 교차축 정렬 방식 (기본값: CrossAxisAlignment.center)
  final CrossAxisAlignment? crossAxisAlignment;

  // Row 전체에 적용할 패딩
  final EdgeInsets? padding;

  // Row의 너비
  final double? width;

  // Row의 높이
  final double? height;

  // 배경색
  final Color? backgroundColor;

  const CustomRow({
    super.key,
    required this.children,
    this.spacing,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // spacing이 있으면 SizedBox로 간격 추가
    final spacedChildren = spacing != null && spacing! > 0
        ? _addSpacing(children, spacing!)
        : children;

    // Row 위젯 생성
    Widget row = Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: spacedChildren,
    );

    // width나 height가 지정된 경우 SizedBox로 감싸기
    if (width != null || height != null) {
      row = SizedBox(width: width, height: height, child: row);
    }

    // padding이 있으면 Padding으로 감싸기
    if (padding != null) {
      row = Padding(padding: padding!, child: row);
    }

    // backgroundColor가 있으면 Container로 감싸기
    if (backgroundColor != null) {
      row = Container(color: backgroundColor, child: row);
    }

    return row;
  }

  // children 리스트에 spacing을 추가하는 메서드
  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      // 마지막 요소가 아니면 SizedBox 추가
      if (i < children.length - 1) {
        spaced.add(SizedBox(width: spacing));
      }
    }
    return spaced;
  }
}
