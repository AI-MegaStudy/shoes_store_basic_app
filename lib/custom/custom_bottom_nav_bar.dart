import 'custom_common_util.dart';
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

// 하단 네비게이션 바 아이템 모델
class BottomNavItem {
  // 아이콘 (선택사항, icon과 label 중 하나는 반드시 필요)
  final IconData? icon;

  // 선택된 아이콘 (선택사항, 없으면 icon 사용)
  final IconData? selectedIcon;

  // 라벨 (선택사항, icon과 label 중 하나는 반드시 필요)
  // String 또는 Widget을 받을 수 있습니다.
  // - String인 경우: Text 위젯으로 자동 변환
  // - Widget인 경우: 그대로 사용
  final dynamic label;

  // 페이지 위젯
  final Widget page;

  // 이 아이템의 선택된 색상 (선택사항, 없으면 CustomBottomNavBar의 selectedColor 사용)
  final Color? selectedColor;

  // 이 아이템의 선택되지 않은 색상 (선택사항, 없으면 CustomBottomNavBar의 unselectedColor 사용)
  final Color? unselectedColor;

  BottomNavItem({
    this.icon,
    this.selectedIcon,
    this.label,
    required this.page,
    this.selectedColor,
    this.unselectedColor,
  }) : assert(
         icon != null || label != null,
         'icon과 label 중 하나는 반드시 제공되어야 합니다.',
       ),
       assert(
         label == null || label is String || label is Widget,
         'label은 String 또는 Widget이어야 합니다.',
       );
}

// 하단 네비게이션 바 위젯
//
// 사용 예시:
// ```dart
// CustomBottomNavBar(
//   items: [
//     BottomNavItem(icon: Icons.home, label: "홈", page: HomePage()),
//     BottomNavItem(icon: Icons.favorite, page: FavoritePage()),
//   ],
// )
// ```
class CustomBottomNavBar extends StatefulWidget {
  // 하단 네비게이션 바 아이템 리스트 (필수, 최소 2개, 최대 5개)
  final List<BottomNavItem> items;

  // 현재 선택된 인덱스 (필수)
  final int currentIndex;

  // 탭 선택 시 호출되는 콜백 함수 (필수)
  final ValueChanged<int> onTap;

  // 선택된 아이템 색상 (기본값: Colors.blue)
  final Color? selectedColor;

  // 선택되지 않은 아이템 색상 (기본값: Colors.grey)
  final Color? unselectedColor;

  // 배경색
  final Color? backgroundColor;

  // 아이템 타입 (기본값: BottomNavigationBarType.fixed)
  final BottomNavigationBarType type;

  // 아이콘 크기 (기본값: 24)
  final double? iconSize;

  // 선택된 아이템 폰트 크기 (기본값: 14)
  final double? selectedFontSize;

  // 선택되지 않은 아이템 폰트 크기 (기본값: 12)
  final double? unselectedFontSize;

  // 현재 페이지를 표시할 위젯 (선택사항, 없으면 items의 page 사용)
  final Widget? currentPage;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.type = BottomNavigationBarType.fixed,
    this.iconSize,
    this.selectedFontSize,
    this.unselectedFontSize,
    this.currentPage,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         '하단 네비게이션 바 아이템은 2개 이상 5개 이하여야 합니다.',
       );

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // 하단 네비게이션 바를 생성하는 메서드
  BottomNavigationBar _buildBottomNavBar() {
    final defaultSelectedColor =
        widget.selectedColor ?? _getThemePrimaryColor(context) ?? Colors.blue;
    final defaultUnselectedColor =
        widget.unselectedColor ??
        _getThemeTextSecondaryColor(context) ??
        Colors.grey;
    final iconSize = widget.iconSize ?? 24.0;
    final selectedFontSize = widget.selectedFontSize ?? 14.0;
    final unselectedFontSize = widget.unselectedFontSize ?? 12.0;

    // 아이콘만 있는 아이템이 있는지 확인 (label이 null인 아이템)
    final hasIconOnlyItems = widget.items.any(
      (item) => item.icon != null && item.label == null,
    );

    // 개별 아이템 색상이 있는지 확인
    final hasIndividualColors = widget.items.any(
      (item) => item.selectedColor != null || item.unselectedColor != null,
    );

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: widget.type,
      // 개별 색상이 있으면 null로 설정하고 각 아이템에서 처리
      selectedItemColor: hasIndividualColors ? null : defaultSelectedColor,
      unselectedItemColor: hasIndividualColors ? null : defaultUnselectedColor,
      backgroundColor: widget.backgroundColor,
      selectedFontSize: selectedFontSize,
      unselectedFontSize: unselectedFontSize,
      iconSize: iconSize,
      // 아이콘만 있는 아이템이 있으면 label 숨기기
      showSelectedLabels: !hasIconOnlyItems,
      showUnselectedLabels: !hasIconOnlyItems,
      items: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = index == widget.currentIndex;

        // 아이템별 색상 결정 (아이템 색상 > 기본 색상)
        final itemSelectedColor = item.selectedColor ?? defaultSelectedColor;
        final itemUnselectedColor =
            item.unselectedColor ?? defaultUnselectedColor;
        final currentColor = isSelected
            ? itemSelectedColor
            : itemUnselectedColor;

        // BottomNavigationBar는 모든 아이템이 label을 가져야 함 (null 불가)
        // 아이콘만 있는 경우 빈 문자열 사용

        // label이 String인지 Widget인지 확인
        final labelText = CustomCommonUtil.toLabelString(item.label);
        final labelWidget = CustomCommonUtil.isWidget(item.label)
            ? item.label as Widget
            : null;

        // 아이콘이 있는 경우
        if (item.icon != null) {
          // label이 Widget인 경우 icon과 함께 사용할 수 없으므로 label만 사용
          if (labelWidget != null) {
            return BottomNavigationBarItem(
              icon: labelWidget,
              activeIcon: labelWidget,
              label: '',
            );
          }
          // label이 String인 경우
          return BottomNavigationBarItem(
            icon: Icon(
              item.icon,
              size: iconSize,
              color: hasIndividualColors ? currentColor : null,
            ),
            activeIcon: Icon(
              item.selectedIcon ?? item.icon,
              size: iconSize,
              color: hasIndividualColors ? currentColor : null,
            ),
            label: labelText ?? '',
          );
        }
        // 아이콘이 없고 텍스트만 있는 경우
        // label이 Widget인 경우
        if (labelWidget != null) {
          return BottomNavigationBarItem(
            icon: labelWidget,
            activeIcon: labelWidget,
            label: '',
          );
        }
        // label이 String인 경우
        // 텍스트를 아이콘처럼 표시하고 label은 빈 문자열로 설정
        // 텍스트만 있는 경우 항상 색상 적용 (아이템 색상 > 기본 색상)
        return BottomNavigationBarItem(
          icon: Text(
            labelText ?? '',
            style: TextStyle(
              fontSize: unselectedFontSize,
              color: currentColor, // 항상 색상 적용
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          activeIcon: Text(
            labelText ?? '',
            style: TextStyle(
              fontSize: selectedFontSize,
              color: currentColor, // 항상 색상 적용
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          label: '', // label은 빈 문자열로 설정하여 텍스트가 중복되지 않도록
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack을 사용하여 모든 페이지를 유지하면서 현재 페이지만 표시
    // 이렇게 하면 각 페이지의 상태가 유지되고, key 없이도 정상 동작함
    final pages = widget.items.map((item) => item.page).toList();
    
    // currentPage가 지정된 경우 해당 페이지만 사용, 아니면 IndexedStack 사용
    if (widget.currentPage != null) {
      final currentPage = widget.currentPage!;
      
      // 현재 페이지가 Scaffold인 경우, bottomNavigationBar를 추가한 새 Scaffold 생성
      if (currentPage is Scaffold) {
        return _ScaffoldWithBottomNav(
          scaffold: currentPage,
          bottomNavBar: _buildBottomNavBar(),
        );
      }

      // Scaffold가 아닌 경우 기본 Scaffold로 감싸기
      return Scaffold(
        body: currentPage,
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // IndexedStack을 사용하여 모든 페이지를 유지 (기본 BottomNavigationBar와 동일한 방식)
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

// Scaffold에 bottomNavigationBar를 추가하는 헬퍼 위젯
class _ScaffoldWithBottomNav extends StatelessWidget {
  final Scaffold scaffold;
  final BottomNavigationBar bottomNavBar;

  const _ScaffoldWithBottomNav({
    required this.scaffold,
    required this.bottomNavBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold.key,
      appBar: scaffold.appBar,
      body: scaffold.body,
      floatingActionButton: scaffold.floatingActionButton,
      floatingActionButtonLocation: scaffold.floatingActionButtonLocation,
      persistentFooterButtons: scaffold.persistentFooterButtons,
      drawer: scaffold.drawer,
      endDrawer: scaffold.endDrawer,
      bottomNavigationBar: bottomNavBar,
      backgroundColor: scaffold.backgroundColor,
      resizeToAvoidBottomInset: scaffold.resizeToAvoidBottomInset,
      extendBody: scaffold.extendBody,
      extendBodyBehindAppBar: scaffold.extendBodyBehindAppBar,
    );
  }
}
