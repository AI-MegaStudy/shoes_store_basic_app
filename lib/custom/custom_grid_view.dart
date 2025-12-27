import 'package:flutter/material.dart';

// GridView 위젯
//
// 사용 예시:
// ```dart
// CustomGridView(itemCount: 20, crossAxisCount: 2, itemBuilder: (context, index) => Widget())
// ```
class CustomGridView extends StatelessWidget {
  // 그리드 아이템 개수 (필수)
  final int itemCount;

  // 각 아이템을 생성하는 빌더 함수 (필수)
  final Widget Function(BuildContext context, int index) itemBuilder;

  // 가로축 아이템 개수 (필수)
  final int crossAxisCount;

  // 아이템들 사이의 간격 (기본값: 8)
  final double? spacing;

  // 그리드 전체에 적용할 패딩
  final EdgeInsets? padding;

  // 아이템의 가로세로 비율 (기본값: 1.0)
  final double? childAspectRatio;

  // 메인 축 스크롤 방향 (기본값: Axis.vertical)
  final Axis scrollDirection;

  // 스크롤 물리 효과
  final ScrollPhysics? physics;

  // 그리드가 비어있을 때 표시할 위젯
  final Widget? emptyWidget;

  // 그리드가 로딩 중일 때 표시할 위젯
  final Widget? loadingWidget;

  // 로딩 중 여부
  final bool isLoading;

  // 최대 크로스 액시스 확장 개수 (SliverGridDelegateWithMaxCrossAxisExtent 사용 시)
  final double? maxCrossAxisExtent;

  // 메인 축 간격
  final double? mainAxisSpacing;

  // 크로스 축 간격
  final double? crossAxisSpacing;

  const CustomGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.spacing,
    this.padding,
    this.childAspectRatio,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    // 로딩 중인 경우
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    // 아이템이 없는 경우
    if (itemCount == 0 && emptyWidget != null) {
      return emptyWidget!;
    }

    final double spacingValue = spacing ?? 8.0;
    final double mainSpacing = mainAxisSpacing ?? spacingValue;
    final double crossSpacing = crossAxisSpacing ?? spacingValue;

    // maxCrossAxisExtent가 설정된 경우 SliverGridDelegateWithMaxCrossAxisExtent 사용
    final SliverGridDelegate gridDelegate = maxCrossAxisExtent != null
        ? SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent!,
            mainAxisSpacing: mainSpacing,
            crossAxisSpacing: crossSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
          )
        : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainSpacing,
            crossAxisSpacing: crossSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
          );

    return GridView.builder(
      gridDelegate: gridDelegate,
      padding: padding ?? EdgeInsets.zero,
      scrollDirection: scrollDirection,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
