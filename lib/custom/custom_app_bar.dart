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

Color? _getThemeForegroundColor(BuildContext context) {
  try {
    // 테마의 textOnPrimary (Primary 배경에 사용할 흰색 텍스트) 사용
    return context.palette.textOnPrimary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.white; // AppBar는 보통 흰색 텍스트
  }
}

// AppBar 위젯
//
// 사용 예시:
// ```dart
// CustomAppBar(title: "홈")
// CustomAppBar(title: "홈", backgroundColor: Colors.blue, actions: [IconButton(...)])
// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // AppBar 제목 (필수)
  // String인 경우 Text 위젯으로 자동 변환, Widget인 경우 그대로 사용
  final dynamic title;

  // AppBar 배경색 (기본값: Colors.blue)
  final Color? backgroundColor;

  // AppBar 전경색/아이콘 색상 (기본값: Colors.white)
  final Color? foregroundColor;

  // 제목 중앙 정렬 여부 (기본값: true)
  final bool centerTitle;

  // 왼쪽에 표시할 위젯 (뒤로가기 버튼 등)
  // leading이 지정되어 있으면 drawer가 있어도 leading이 우선 표시됩니다.
  final Widget? leading;

  // Drawer 아이콘 (drawer가 있고 leading이 없을 때 사용)
  // 기본값: Icons.menu
  // drawer가 있고 leading이 없으면 이 아이콘으로 Drawer를 여는 버튼이 자동으로 표시됩니다.
  final IconData? drawerIcon;

  // Drawer 아이콘 색상 (drawerIcon 사용 시)
  // 기본값: foregroundColor 또는 Colors.white
  final Color? drawerIconColor;

  // Drawer 아이콘 크기 (drawerIcon 사용 시)
  // 기본값: 24.0
  final double? drawerIconSize;

  // Drawer 아이콘 위젯 (drawer가 있고 leading이 없을 때 사용)
  // drawerIconWidget이 지정되면 drawerIcon, drawerIconColor, drawerIconSize는 무시됩니다.
  // drawerIconWidget을 사용하면 완전히 커스텀된 위젯을 사용할 수 있습니다.
  final Widget? drawerIconWidget;

  // 오른쪽에 표시할 액션 버튼들
  final List<Widget>? actions;

  // AppBar 높이 (기본값: kToolbarHeight)
  final double? toolbarHeight;

  // 제목 텍스트 스타일
  final TextStyle? titleTextStyle;

  // 자동으로 뒤로가기 버튼 표시 여부 (기본값: true, leading이 있으면 false)
  final bool automaticallyImplyLeading;

  CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.leading,
    this.drawerIcon,
    this.drawerIconColor,
    this.drawerIconSize,
    this.drawerIconWidget,
    this.actions,
    this.toolbarHeight,
    this.titleTextStyle,
    this.automaticallyImplyLeading = true,
  }) : assert(
         CustomCommonUtil.isString(title) || CustomCommonUtil.isWidget(title),
         'title은 String 또는 Widget이어야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? _getThemePrimaryColor(context) ?? Colors.blue;
    final fgColor =
        foregroundColor ?? _getThemeForegroundColor(context) ?? Colors.white;

    // title이 String인지 Widget인지 확인하고 처리
    Widget titleWidget;
    if (CustomCommonUtil.isString(title)) {
      // String인 경우 Text 위젯으로 변환
      titleWidget = Text(
        title as String,
        style:
            titleTextStyle ??
            TextStyle(
              color: fgColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      );
    } else {
      // Widget인 경우 그대로 사용
      titleWidget = title as Widget;
    }

    Widget? finalLeading = leading;
    bool shouldImplyLeading;

    // drawerIconWidget이 지정되어 있고 leading이 없으면 커스텀 Drawer 버튼 생성
    if (drawerIconWidget != null && leading == null) {
      finalLeading = Builder(
        builder: (builderContext) {
          return IconButton(
            icon: drawerIconWidget!,
            onPressed: () {
              final scaffoldState = Scaffold.maybeOf(builderContext);
              scaffoldState?.openDrawer();
            },
            tooltip: MaterialLocalizations.of(
              builderContext,
            ).openAppDrawerTooltip,
          );
        },
      );
      shouldImplyLeading = false; // leading을 직접 지정했으므로 false
    }
    // drawerIcon이 지정되어 있고 leading이 없으면 커스텀 Drawer 버튼 생성
    else if (drawerIcon != null && leading == null) {
      final iconColor = drawerIconColor ?? fgColor;
      final iconSize = drawerIconSize ?? 24.0;
      finalLeading = Builder(
        builder: (builderContext) {
          return IconButton(
            icon: Icon(drawerIcon, color: iconColor, size: iconSize),
            onPressed: () {
              final scaffoldState = Scaffold.maybeOf(builderContext);
              scaffoldState?.openDrawer();
            },
            tooltip: MaterialLocalizations.of(
              builderContext,
            ).openAppDrawerTooltip,
          );
        },
      );
      shouldImplyLeading = false; // leading을 직접 지정했으므로 false
    } else if (leading == null) {
      // leading이 없으면 automaticallyImplyLeading 값에 따라 자동으로 뒤로가기/Drawer 아이콘 표시
      // Flutter가 자동으로 drawer가 있으면 Icons.menu를 표시합니다.
      shouldImplyLeading = automaticallyImplyLeading;
      
      // PopScope의 canPop이 false인 경우 뒤로가기 버튼이 작동하지 않으므로
      // 직접 Navigator.pop()을 호출하도록 커스텀 leading 생성
      if (shouldImplyLeading && Navigator.canPop(context)) {
        finalLeading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
        shouldImplyLeading = false; // 커스텀 leading을 사용하므로 false로 설정
      }
    } else {
      // leading이 있으면 automaticallyImplyLeading을 false로 설정하여
      // 사용자가 지정한 leading을 표시
      shouldImplyLeading = false;
    }

    return AppBar(
      title: titleWidget,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      centerTitle: centerTitle,
      leading: finalLeading,
      actions: actions,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: shouldImplyLeading,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
