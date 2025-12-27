import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemePrimaryColor(BuildContext context) {
  try {
    return context.palette.primary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Theme.of(context).colorScheme.primary;
  }
}

Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey;
  }
}

// TabBar 위젯 (TabBarView 포함)
//
// 사용 예시:
// ```dart
// CustomTabBar(tabs: ["탭1", "탭2"], children: [Widget1(), Widget2()])
// ```
class CustomTabBar extends StatefulWidget {
  // 탭 라벨 리스트 (필수)
  final List<String> tabs;

  // 각 탭에 해당하는 위젯 리스트 (필수, tabs와 개수가 동일해야 함)
  final List<Widget> children;

  // 탭 색상 (기본값: Colors.blue)
  final Color? tabColor;

  // 선택되지 않은 탭 색상
  final Color? unselectedTabColor;

  // 탭 인디케이터 색상
  final Color? indicatorColor;

  // 탭 인디케이터 높이 (기본값: 3)
  final double? indicatorHeight;

  // 탭 라벨 스타일
  final TextStyle? labelStyle;

  // 선택되지 않은 탭 라벨 스타일
  final TextStyle? unselectedLabelStyle;

  // 탭이 스크롤 가능한지 여부 (기본값: false)
  final bool isScrollable;

  // 탭 위치 (기본값: TabBarPosition.top)
  final TabBarPosition position;

  // 탭 클릭 시 콜백 (선택된 탭 인덱스 전달)
  final ValueChanged<int>? onTap;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.children,
    this.tabColor,
    this.unselectedTabColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.isScrollable = false,
    this.position = TabBarPosition.top,
    this.onTap,
  }) : assert(tabs.length == children.length, 'tabs와 children의 개수가 동일해야 합니다.');

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabColor =
        widget.tabColor ?? _getThemePrimaryColor(context) ?? Colors.blue;
    final unselectedTabColor =
        widget.unselectedTabColor ??
        _getThemeTextSecondaryColor(context) ??
        Colors.grey;
    final indicatorColor = widget.indicatorColor ?? tabColor;
    final indicatorHeight = widget.indicatorHeight ?? 3.0;

    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: widget.isScrollable,
      labelColor: tabColor,
      unselectedLabelColor: unselectedTabColor,
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: indicatorHeight,
      labelStyle:
          widget.labelStyle ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle:
          widget.unselectedLabelStyle ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
      onTap: widget.onTap,
    );

    final tabBarView = TabBarView(
      controller: _tabController,
      children: widget.children,
    );

    if (widget.position == TabBarPosition.top) {
      return Column(
        children: [
          tabBar,
          Expanded(child: tabBarView),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: tabBarView),
          tabBar,
        ],
      );
    }
  }
}

// 탭바 위치 enum
enum TabBarPosition {
  // 상단에 탭바 표시
  top,

  // 하단에 탭바 표시
  bottom,
}
