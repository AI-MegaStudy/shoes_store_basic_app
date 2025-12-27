import 'package:flutter/material.dart';

// 접을 수 있는 리스트 아이템 위젯
//
// 사용 예시:
// ```dart
// CustomExpansionTile(title: "제목", children: [Widget()])
// CustomExpansionTile(title: "제목", leading: Icon(Icons.info), initiallyExpanded: true, children: [Widget()])
// ```
class CustomExpansionTile extends StatelessWidget {
  // 확장 타일의 제목 (필수)
  final Widget title;

  // 확장 타일의 서브타이틀 (선택사항)
  final Widget? subtitle;

  // 확장 시 표시할 자식 위젯들 (필수)
  final List<Widget> children;

  // 왼쪽에 표시할 아이콘 또는 위젯
  final Widget? leading;

  // 오른쪽에 표시할 위젯 (기본적으로 확장/축소 아이콘이 표시됨)
  final Widget? trailing;

  // 초기 확장 상태 (기본값: false)
  final bool initiallyExpanded;

  // 확장 상태 변경 시 콜백
  final ValueChanged<bool>? onExpansionChanged;

  // 배경색
  final Color? backgroundColor;

  // 확장된 상태의 배경색
  final Color? collapsedBackgroundColor;

  // 아이콘 색상
  final Color? iconColor;

  // 확장된 상태의 아이콘 색상
  final Color? collapsedIconColor;

  // 텍스트 색상
  final Color? textColor;

  // 확장된 상태의 텍스트 색상
  final Color? collapsedTextColor;

  // 타일 패딩
  final EdgeInsetsGeometry? tilePadding;

  // 자식 위젯들에 적용할 패딩
  final EdgeInsetsGeometry? childrenPadding;

  // 모서리 둥글기
  final double? borderRadius;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.leading,
    this.trailing,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.iconColor,
    this.collapsedIconColor,
    this.textColor,
    this.collapsedTextColor,
    this.tilePadding,
    this.childrenPadding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: onExpansionChanged,
      backgroundColor: backgroundColor,
      collapsedBackgroundColor: collapsedBackgroundColor,
      iconColor: iconColor,
      collapsedIconColor: collapsedIconColor,
      textColor: textColor,
      collapsedTextColor: collapsedTextColor,
      tilePadding:
          tilePadding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      childrenPadding: childrenPadding ?? const EdgeInsets.all(16),
      shape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
            )
          : null,
      collapsedShape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
            )
          : null,
      children: children,
    );
  }
}
