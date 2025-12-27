import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeTextPrimaryColor(BuildContext context) {
  try {
    return context.palette.textPrimary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

// IconButton 위젯
//
// 사용 예시:
// ```dart
// CustomIconButton(icon: Icons.favorite, onPressed: () {})
// CustomIconButton(icon: Icons.star, iconColor: Colors.amber, iconSize: 32, onPressed: () {})
// ```
class CustomIconButton extends StatelessWidget {
  // 표시할 아이콘 (필수)
  final IconData icon;

  // 아이콘 버튼 클릭 시 실행될 콜백 함수 (필수)
  final VoidCallback onPressed;

  // 아이콘 크기 (기본값: 24)
  final double? iconSize;

  // 아이콘 색상 (기본값: Colors.black)
  final Color? iconColor;

  // 아이콘 버튼 배경색
  final Color? backgroundColor;

  // 아이콘 버튼 크기 (기본값: 48)
  final double? size;

  // 아이콘 버튼 모서리 둥글기
  final double? borderRadius;

  // 툴팁 메시지
  final String? tooltip;

  // 아이콘 버튼이 비활성화되어 있는지 여부
  final bool enabled;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.borderRadius,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 48.0;
    final iconSizeFinal = iconSize ?? 24.0;
    final iconColorFinal =
        iconColor ?? _getThemeTextPrimaryColor(context) ?? Colors.black;

    Widget iconButton;

    // 배경색이나 둥근 모서리가 있는 경우 Container로 감싸기
    if (backgroundColor != null || borderRadius != null) {
      iconButton = Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius != null
              ? BorderRadius.circular(borderRadius!)
              : null,
        ),
        child: IconButton(
          icon: Icon(icon, size: iconSizeFinal, color: iconColorFinal),
          onPressed: enabled ? onPressed : null,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
        ),
      );
    } else {
      // 기본 IconButton 사용
      iconButton = IconButton(
        icon: Icon(icon, size: iconSizeFinal, color: iconColorFinal),
        onPressed: enabled ? onPressed : null,
        tooltip: tooltip,
        iconSize: iconSizeFinal,
      );
    }

    return iconButton;
  }
}
