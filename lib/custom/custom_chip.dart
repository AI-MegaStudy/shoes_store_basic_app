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

Color? _getThemeTextPrimaryColor(BuildContext context) {
  try {
    return context.palette.textPrimary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

Color? _getThemeChipSelectedBgColor(BuildContext context) {
  try {
    return context.palette.chipSelectedBg;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return _getThemePrimaryColor(context) ?? Colors.blue;
  }
}

Color? _getThemeChipSelectedTextColor(BuildContext context) {
  try {
    return context.palette.chipSelectedText;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.white;
  }
}

// 태그, 필터, 선택 표시용 Chip 위젯
//
// 사용 예시:
// ```dart
// CustomChip(label: "태그", onDeleted: () {})
// CustomChip(label: "필터", selectable: true, selected: true, onSelected: (selected) {})
// CustomChip(label: "고정 크기", width: 120) // 너비 고정
// CustomChip(label: "고정 크기", width: 120, height: 50) // 너비와 높이 모두 고정
// ```
class CustomChip extends StatelessWidget {
  // Chip에 표시할 라벨 (필수)
  // String인 경우 Text로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  // 삭제 버튼 클릭 시 콜백
  final VoidCallback? onDeleted;

  // 선택 가능한 Chip인지 여부
  final bool selectable;

  // 선택된 상태 (selectable이 true일 때만 유효)
  final bool selected;

  // 선택 상태 변경 시 콜백 (selectable이 true일 때만 유효)
  final ValueChanged<bool>? onSelected;

  // 왼쪽에 표시할 아바타
  final Widget? avatar;

  // 배경색
  final Color? backgroundColor;

  // 선택된 상태의 배경색
  final Color? selectedColor;

  // 삭제 아이콘 색상
  final Color? deleteIconColor;

  // 라벨 색상
  final Color? labelColor;

  // 선택된 상태의 라벨 색상
  final Color? selectedLabelColor;

  // 패딩
  final EdgeInsetsGeometry? padding;

  // 모서리 둥글기
  final double? borderRadius;

  // 아이콘 크기
  final double? iconSize;

  // 삭제 아이콘
  final IconData? deleteIcon;

  // 툴팁 메시지
  final String? tooltip;

  // Chip의 너비 (지정하면 크기 고정, 생략하면 유동적)
  final double? width;

  // Chip의 높이 (지정하면 크기 고정, 생략하면 유동적)
  final double? height;

  const CustomChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.selectable = false,
    this.selected = false,
    this.onSelected,
    this.avatar,
    this.backgroundColor,
    this.selectedColor,
    this.deleteIconColor,
    this.labelColor,
    this.selectedLabelColor,
    this.padding,
    this.borderRadius,
    this.iconSize,
    this.deleteIcon,
    this.tooltip,
    this.width,
    this.height,
  }) : assert(
         !selectable || onSelected != null || !selected,
         'selectable이 true일 때 onSelected가 제공되어야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    // label이 String인지 Widget인지 확인
    Widget labelWidget;
    if (label is String) {
      labelWidget = Text(
        label as String,
        style: TextStyle(
          color: selectable && selected
              ? (selectedLabelColor ??
                    _getThemeChipSelectedTextColor(context) ??
                    Colors.white)
              : (labelColor ??
                    _getThemeTextPrimaryColor(context) ??
                    Colors.black),
        ),
      );
    } else {
      labelWidget = label as Widget;
    }

    Widget chip;

    // 선택 가능한 Chip
    if (selectable) {
      chip = ChoiceChip(
        label: labelWidget,
        selected: selected,
        onSelected: onSelected,
        avatar: avatar,
        backgroundColor: backgroundColor,
        selectedColor:
            selectedColor ??
            _getThemeChipSelectedBgColor(context) ??
            Colors.blue,
        labelStyle: TextStyle(
          color: selected
              ? (selectedLabelColor ??
                    _getThemeChipSelectedTextColor(context) ??
                    Colors.white)
              : (labelColor ??
                    _getThemeTextPrimaryColor(context) ??
                    Colors.black),
        ),
        padding:
            padding ??
            ((width != null || height != null) && selectable
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : null),
        shape: borderRadius != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
              )
            : null,
        // 크기 고정을 위해 visualDensity 조정
        visualDensity: (width != null || height != null)
            ? VisualDensity.compact
            : null,
        materialTapTargetSize: (width != null || height != null)
            ? MaterialTapTargetSize.shrinkWrap
            : null,
      );
    }
    // 삭제 가능한 Chip
    else if (onDeleted != null) {
      chip = Chip(
        label: labelWidget,
        onDeleted: onDeleted,
        avatar: avatar,
        backgroundColor: backgroundColor,
        deleteIconColor: deleteIconColor,
        labelStyle: TextStyle(
          color:
              labelColor ?? _getThemeTextPrimaryColor(context) ?? Colors.black,
        ),
        padding: padding,
        shape: borderRadius != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
              )
            : null,
        deleteIcon: deleteIcon != null
            ? Icon(deleteIcon, size: iconSize ?? 18)
            : null,
      );
    }
    // 기본 Chip
    else {
      chip = Chip(
        label: labelWidget,
        avatar: avatar,
        backgroundColor: backgroundColor,
        labelStyle: TextStyle(
          color:
              labelColor ?? _getThemeTextPrimaryColor(context) ?? Colors.black,
        ),
        padding: padding,
        shape: borderRadius != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
              )
            : null,
      );
    }

    // tooltip이 있는 경우 Tooltip으로 감싸기
    if (tooltip != null) {
      chip = Tooltip(message: tooltip, child: chip);
    }

    // width 또는 height가 지정되면 크기 고정
    if (width != null || height != null) {
      chip = Container(
        width: width,
        height: height,
        clipBehavior: Clip.none, // 선택 아이콘이 잘리지 않도록
        child: chip,
      );
    }

    return chip;
  }
}
