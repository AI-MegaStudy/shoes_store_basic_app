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

// Text 위젯
//
// 사용 예시:
// ```dart
// CustomText("확인")
// CustomText("확인", fontSize: 24, color: Colors.blue)
// ```
class CustomText extends StatelessWidget {
  // 표시할 텍스트 내용 (필수)
  final String text;

  // 텍스트 크기 (기본값: 20)
  final double? fontSize;

  // 텍스트 굵기 (기본값: FontWeight.bold)
  final FontWeight? fontWeight;

  // 텍스트 색상 (기본값: Colors.black)
  final Color? color;

  // 텍스트 정렬 방식
  final TextAlign? textAlign;

  // 최대 줄 수
  final int? maxLines;

  // 텍스트 오버플로우 처리 방식
  final TextOverflow? overflow;

  // 커스텀 TextStyle (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final TextStyle? style;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 스타일 정의
    final defaultStyle = TextStyle(
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? _getThemeTextPrimaryColor(context) ?? Colors.black,
    );

    // 사용자가 커스텀 style을 제공한 경우, 기본 스타일과 병합
    final finalStyle = style != null ? defaultStyle.merge(style) : defaultStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
