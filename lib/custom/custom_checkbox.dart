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
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
}

// Checkbox 위젯
//
// 사용 예시:
// ```dart
// CustomCheckbox(value: _isChecked, onChanged: (value) {})
// CustomCheckbox(value: _isChecked, label: "이용약관 동의", onChanged: (value) {})
// ```
class CustomCheckbox extends StatelessWidget {
  // Checkbox의 현재 값 (필수)
  final bool? value;

  // Checkbox 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<bool?>? onChanged;

  // Checkbox 활성화 상태의 색상 (기본값: Colors.blue)
  final Color? activeColor;

  // Checkbox 비활성화 상태의 색상
  final Color? inactiveColor;

  // Checkbox 체크 마크 색상
  final Color? checkColor;

  // Checkbox 옆에 표시할 레이블 텍스트
  final String? label;

  // 레이블 텍스트 스타일
  final TextStyle? labelStyle;

  // Checkbox와 레이블 사이의 간격 (기본값: 8)
  final double? spacing;

  // Checkbox 크기 조절 (기본값: null, Material 3 기본 크기 사용)
  final MaterialTapTargetSize? materialTapTargetSize;

  // Checkbox의 시각적 밀도
  final VisualDensity? visualDensity;

  // 커스텀 CheckboxThemeData (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final CheckboxThemeData? checkboxTheme;

  // 레이블과 체크박스의 세로 정렬 방식 (기본값: CrossAxisAlignment.center)
  final CrossAxisAlignment labelAlignment;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.label,
    this.labelStyle,
    this.spacing,
    this.materialTapTargetSize,
    this.visualDensity,
    this.checkboxTheme,
    this.labelAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final checkboxWidget = CheckboxTheme(
      data:
          checkboxTheme ??
          CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return inactiveColor;
              }
              if (states.contains(WidgetState.selected)) {
                return activeColor ??
                    _getThemePrimaryColor(context) ??
                    Colors.blue;
              }
              return inactiveColor;
            }),
            checkColor: WidgetStateProperty.all(checkColor ?? Colors.white),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                final themeColor =
                    activeColor ??
                    _getThemePrimaryColor(context) ??
                    Colors.blue;
                return themeColor.withValues(alpha: 0.12);
              }
              return null;
            }),
          ),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        checkColor: checkColor,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity,
      ),
    );

    // 레이블이 있는 경우 Row로 감싸서 반환
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: labelAlignment,
        children: [
          checkboxWidget,
          SizedBox(width: spacing ?? 8),
          Flexible(
            child: Text(
              label!,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: _getThemeTextPrimaryColor(context) ?? Colors.black87,
                  ),
            ),
          ),
        ],
      );
    }

    return checkboxWidget;
  }
}
