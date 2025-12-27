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

// Radio 위젯
//
// 사용 예시:
// ```dart
// CustomRadio<String>(value: "option1", groupValue: _selectedOption, onChanged: (value) {})
// CustomRadio<String>(value: "option1", groupValue: _selectedOption, label: "옵션 1", onChanged: (value) {})
// ```
class CustomRadio<T> extends StatelessWidget {
  // Radio의 값 (필수)
  final T value;

  // 현재 선택된 그룹 값 (필수)
  final T? groupValue;

  // Radio 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<T?>? onChanged;

  // Radio 활성화 상태의 색상 (기본값: Colors.blue)
  final Color? activeColor;

  // Radio 비활성화 상태의 색상
  final Color? inactiveColor;

  // Radio 옆에 표시할 레이블 텍스트
  final String? label;

  // 레이블 텍스트 스타일
  final TextStyle? labelStyle;

  // Radio와 레이블 사이의 간격 (기본값: 8)
  final double? spacing;

  // Radio 크기 조절 (기본값: null, Material 3 기본 크기 사용)
  final MaterialTapTargetSize? materialTapTargetSize;

  // Radio의 시각적 밀도
  final VisualDensity? visualDensity;

  // 플랫폼에 맞는 스타일 자동 적용 여부 (기본값: true)
  // true인 경우 Radio.adaptive 사용, false인 경우 Radio 사용
  final bool adaptive;

  // 커스텀 RadioThemeData (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final RadioThemeData? radioTheme;

  const CustomRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.labelStyle,
    this.spacing,
    this.materialTapTargetSize,
    this.visualDensity,
    this.adaptive = true,
    this.radioTheme,
  });

  @override
  Widget build(BuildContext context) {
    final radioWidget = RadioTheme(
      data:
          radioTheme ??
          RadioThemeData(
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
      child: adaptive
          ? Radio<T>.adaptive(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: activeColor,
              materialTapTargetSize: materialTapTargetSize,
              visualDensity: visualDensity,
            )
          : Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: activeColor,
              materialTapTargetSize: materialTapTargetSize,
              visualDensity: visualDensity,
            ),
    );

    // 레이블이 있는 경우 Row로 감싸서 반환
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radioWidget,
          SizedBox(width: spacing ?? 8),
          Text(
            label!,
            style:
                labelStyle ??
                TextStyle(
                  fontSize: 16,
                  color: _getThemeTextPrimaryColor(context) ?? Colors.black87,
                ),
          ),
        ],
      );
    }

    return radioWidget;
  }
}
