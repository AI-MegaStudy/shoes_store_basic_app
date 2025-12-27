import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey.shade600;
  }
}

// 로딩 및 진행률 표시 위젯
//
// 사용 예시:
// ```dart
// CustomProgressIndicator.circular()
// CustomProgressIndicator.linear(value: 0.5, label: "50%")
// ```
class CustomProgressIndicator extends StatelessWidget {
  // 진행률 값 (0.0 ~ 1.0, linear 타입일 때만 사용)
  final double? value;

  // 진행률 라벨 (선택사항)
  final String? label;

  // 진행률 표시 타입
  final ProgressIndicatorType type;

  // 색상
  final Color? color;

  // 배경색 (linear 타입일 때만 사용)
  final Color? backgroundColor;

  // 스트로크 너비 (circular 타입일 때만 사용)
  final double? strokeWidth;

  // 크기 (circular 타입일 때만 사용)
  final double? size;

  // 최소 높이 (linear 타입일 때만 사용)
  final double? minHeight;

  // 원형 로딩 인디케이터 생성자
  const CustomProgressIndicator.circular({
    super.key,
    this.color,
    this.strokeWidth,
    this.size,
  }) : type = ProgressIndicatorType.circular,
       value = null,
       label = null,
       backgroundColor = null,
       minHeight = null;

  // 선형 진행률 인디케이터 생성자
  const CustomProgressIndicator.linear({
    super.key,
    required this.value,
    this.label,
    this.color,
    this.backgroundColor,
    this.minHeight,
  }) : type = ProgressIndicatorType.linear,
       strokeWidth = null,
       size = null;

  @override
  Widget build(BuildContext context) {
    Widget indicator;

    if (type == ProgressIndicatorType.circular) {
      // 원형 로딩 인디케이터
      Widget circularIndicator = CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth ?? 4.0,
      );

      // size가 지정된 경우 SizedBox로 감싸기
      if (size != null) {
        circularIndicator = SizedBox(
          width: size,
          height: size,
          child: circularIndicator,
        );
      }

      indicator = circularIndicator;
    } else {
      // 선형 진행률 인디케이터
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: backgroundColor,
            minHeight: minHeight ?? 4.0,
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                color:
                    _getThemeTextSecondaryColor(context) ??
                    Colors.grey.shade600,
              ),
            ),
          ],
        ],
      );
    }

    return indicator;
  }
}

// ProgressIndicator 타입 enum
enum ProgressIndicatorType {
  // 원형 로딩 인디케이터
  circular,

  // 선형 진행률 인디케이터
  linear,
}
