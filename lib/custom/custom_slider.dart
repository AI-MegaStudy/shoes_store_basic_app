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
    return Colors.grey.shade300;
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

// Slider 위젯
//
// 사용 예시:
// ```dart
// CustomSlider(value: _sliderValue, onChanged: (value) {})
// CustomSlider(value: _sliderValue, min: 0, max: 100, label: "볼륨", divisions: 10, onChanged: (value) {})
// ```
class CustomSlider extends StatelessWidget {
  // Slider의 현재 값 (필수)
  final double value;

  // Slider 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<double>? onChanged;

  // Slider 값 변경 완료 시 호출되는 콜백 함수
  final ValueChanged<double>? onChangeEnd;

  // Slider 값 변경 시작 시 호출되는 콜백 함수
  final ValueChanged<double>? onChangeStart;

  // Slider의 최소값 (기본값: 0.0)
  final double? min;

  // Slider의 최대값 (기본값: 1.0)
  final double? max;

  // Slider의 분할 수 (null인 경우 연속적인 슬라이더)
  final int? divisions;

  // Slider의 레이블 텍스트
  final String? label;

  // Slider 활성화 상태의 색상 (기본값: Colors.blue)
  final Color? activeColor;

  // Slider 비활성화 상태의 색상
  final Color? inactiveColor;

  // Slider 썸(thumb) 색상
  final Color? thumbColor;

  // Slider 오버레이 색상
  final Color? overlayColor;

  // Slider 위에 표시할 제목 텍스트
  final String? title;

  // 제목 텍스트 스타일
  final TextStyle? titleStyle;

  // Slider 아래에 표시할 현재 값 텍스트
  final bool showValue;

  // 값 텍스트 스타일
  final TextStyle? valueStyle;

  // Slider와 제목/값 사이의 간격 (기본값: 8)
  final double? spacing;

  // Slider의 시각적 밀도
  final VisualDensity? visualDensity;

  // 커스텀 SliderThemeData (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final SliderThemeData? sliderTheme;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
    this.min,
    this.max,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.overlayColor,
    this.title,
    this.titleStyle,
    this.showValue = false,
    this.valueStyle,
    this.spacing,
    this.visualDensity,
    this.sliderTheme,
  }) : assert(
         value >= (min ?? 0.0) && value <= (max ?? 1.0),
         'value는 min과 max 사이의 값이어야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    final sliderWidget = SliderTheme(
      data:
          sliderTheme ??
          SliderThemeData(
            activeTrackColor:
                activeColor ?? _getThemePrimaryColor(context) ?? Colors.blue,
            inactiveTrackColor:
                inactiveColor ??
                _getThemeTextSecondaryColor(context) ??
                Colors.grey.shade300,
            thumbColor:
                thumbColor ??
                activeColor ??
                _getThemePrimaryColor(context) ??
                Colors.blue,
            overlayColor:
                overlayColor ??
                (activeColor ?? _getThemePrimaryColor(context) ?? Colors.blue)
                    .withValues(alpha: 0.12),
            valueIndicatorColor:
                activeColor ?? _getThemePrimaryColor(context) ?? Colors.blue,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white, // Value indicator는 항상 흰색
              fontSize: 12,
            ),
          ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        onChangeStart: onChangeStart,
        min: min ?? 0.0,
        max: max ?? 1.0,
        divisions: divisions,
        label: label,
      ),
    );

    // 제목이나 값 표시가 필요한 경우 Column으로 감싸서 반환
    if (title != null || showValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style:
                  titleStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getThemeTextPrimaryColor(context) ?? Colors.black87,
                  ),
            ),
            SizedBox(height: spacing ?? 8),
          ],
          sliderWidget,
          if (showValue) ...[
            SizedBox(height: spacing ?? 8),
            Text(
              value.toStringAsFixed(divisions != null ? 0 : 1),
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: 14,
                    color:
                        _getThemeTextSecondaryColor(context) ??
                        Colors.grey.shade600,
                  ),
            ),
          ],
        ],
      );
    }

    return sliderWidget;
  }
}
