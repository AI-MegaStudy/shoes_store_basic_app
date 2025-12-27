import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey;
  }
}

// Container 위젯
//
// 사용 예시:
// ```dart
// CustomContainer(child: Widget())
// CustomContainer(child: Widget(), padding: EdgeInsets.all(16), backgroundColor: Colors.white)
// ```
class CustomContainer extends StatelessWidget {
  // Container 내부에 표시할 자식 위젯 (필수)
  final Widget child;

  // Container 배경색
  final Color? backgroundColor;

  // Container 모서리 둥글기
  final double? borderRadius;

  // Container 전체에 적용할 패딩
  final EdgeInsets? padding;

  // Container 테두리 색상
  final Color? borderColor;

  // Container 테두리 두께
  final double? borderWidth;

  // Container 그림자 색상
  final Color? shadowColor;

  // Container 그림자 블러 반경
  final double? blurRadius;

  // Container 그림자 확산 반경
  final double? spreadRadius;

  // Container 그림자 오프셋
  final Offset? shadowOffset;

  // Container 너비
  final double? width;

  // Container 높이
  final double? height;

  // Container 마진
  final EdgeInsets? margin;

  // Container 정렬 방식
  final AlignmentGeometry? alignment;

  // Container 제약 조건
  final BoxConstraints? constraints;

  const CustomContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.borderColor,
    this.borderWidth,
    this.shadowColor,
    this.blurRadius,
    this.spreadRadius,
    this.shadowOffset,
    this.width,
    this.height,
    this.margin,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
            : null,
        boxShadow:
            (shadowColor != null ||
                blurRadius != null ||
                spreadRadius != null ||
                shadowOffset != null)
            ? [
                BoxShadow(
                  color:
                      shadowColor ??
                      (_getThemeTextSecondaryColor(context) ?? Colors.grey)
                          .withValues(alpha: 0.2),
                  spreadRadius: spreadRadius ?? 1.0,
                  blurRadius: blurRadius ?? 8.0,
                  offset: shadowOffset ?? const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    return container;
  }
}
