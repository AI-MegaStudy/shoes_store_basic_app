import 'package:flutter/material.dart';

// ListView 위젯
//
// 사용 예시:
// ```dart
// CustomListView(itemCount: 10, itemBuilder: (context, index) => Widget())
// ```
class CustomListView extends StatelessWidget {
  // 리스트 아이템 개수 (필수)
  final int itemCount;

  // 각 아이템을 생성하는 빌더 함수 (필수)
  final Widget Function(BuildContext context, int index) itemBuilder;

  // 스크롤 방향 (기본값: Axis.vertical)
  final Axis scrollDirection;

  // 리스트 아이템들 사이의 간격
  final double? itemSpacing;

  // 리스트 전체에 적용할 패딩
  final EdgeInsets? padding;

  // 리스트 아이템들 사이의 구분선
  final Widget? separator;

  // 스크롤 물리 효과
  final ScrollPhysics? physics;

  // 리스트가 비어있을 때 표시할 위젯
  final Widget? emptyWidget;

  // 리스트가 로딩 중일 때 표시할 위젯
  final Widget? loadingWidget;

  // 로딩 중 여부
  final bool isLoading;

  const CustomListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.itemSpacing,
    this.padding,
    this.separator,
    this.physics,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
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

    // separator가 있으면 ListView.separated 사용
    if (separator != null || itemSpacing != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        padding: padding,
        physics: physics ?? const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) {
          if (separator != null) return separator!;
          return SizedBox(
            height: scrollDirection == Axis.vertical ? itemSpacing : null,
            width: scrollDirection == Axis.horizontal ? itemSpacing : null,
          );
        },
      );
    }

    // 일반 ListView.builder 사용
    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
