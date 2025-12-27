import 'package:flutter/material.dart';

// Column 위젯
//
// 사용 예시:
// ```dart
// CustomColumn(children: [Widget1(), Widget2()])
// CustomColumn(children: [...], spacing: 16, padding: EdgeInsets.all(16))
// ```
class CustomColumn extends StatelessWidget {
  // Column의 자식 위젯들 (필수)
  final List<Widget> children;

  // 자식 위젯들 사이의 간격 (기본값: 12)
  final double? spacing;

  // Column의 정렬 방식 (기본값: MainAxisAlignment.start)
  final MainAxisAlignment? mainAxisAlignment;

  // Column의 주축 크기 (기본값: MainAxisSize.max)
  final MainAxisSize? mainAxisSize;

  // Column의 교차축 정렬 방식 (기본값: CrossAxisAlignment.center)
  final CrossAxisAlignment? crossAxisAlignment;

  // Column 전체에 적용할 패딩
  final EdgeInsets? padding;

  // Column의 너비 (기본값: double.infinity)
  final double? width;

  // Column의 높이
  final double? height;

  // 배경색
  final Color? backgroundColor;

  const CustomColumn({
    super.key,
    required this.children,
    this.spacing,
    this.mainAxisAlignment,
    this.mainAxisSize,
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

    // Column 위젯 생성
    Widget column = Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: spacedChildren,
    );

    // width가 지정된 경우 SizedBox로 감싸기
    if (width != null || height != null) {
      column = SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: column,
      );
    }

    // padding이 있으면 Padding으로 감싸기
    if (padding != null) {
      column = Padding(padding: padding!, child: column);
    }

    // backgroundColor가 있으면 Container로 감싸기
    if (backgroundColor != null) {
      column = Container(color: backgroundColor, child: column);
    }

    return column;
  }

  // children 리스트에 spacing을 추가하는 메서드
  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      // 마지막 요소가 아니면 SizedBox 추가
      if (i < children.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }
    return spaced;
  }
}
