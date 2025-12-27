import 'custom_text.dart';
import 'custom_common_util.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeSnackBarBackgroundColor(BuildContext context) {
  try {
    // SnackBar는 보통 어두운 배경을 사용하므로 textSecondary를 어둡게 사용
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return context.palette.textSecondary.withValues(alpha: 0.8);
    } else {
      return Colors.grey.shade800; // 라이트 모드에서는 기존 색상 유지
    }
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey.shade800;
  }
}

Color? _getThemeSnackBarTextColor(BuildContext context) {
  try {
    // SnackBar는 보통 어두운 배경이므로 흰색 텍스트 사용
    return Colors.white;
  } catch (e) {
    // PaletteContext가 없는 경우 기본값 사용
    return Colors.white;
  }
}

// SnackBar 헬퍼 클래스
//
// 사용 예시:
// ```dart
// CustomSnackBar.show(context, message: "메시지")
// CustomSnackBar.showSuccess(context, message: "성공했습니다")
// CustomSnackBar.showError(context, message: "에러가 발생했습니다")
// ```
class CustomSnackBar {
  // SnackBar를 표시하는 정적 메서드
  static void show(
    BuildContext context, {
    required dynamic message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
  }) {
    // message가 String인지 Widget인지 확인
    assert(
      CustomCommonUtil.isString(message) || CustomCommonUtil.isWidget(message),
      'message는 String 또는 Widget이어야 합니다.',
    );

    // message Widget 생성
    Widget messageWidget;
    if (CustomCommonUtil.isString(message)) {
      // String인 경우 CustomText로 변환
      messageWidget = CustomText(
        message as String,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor ?? _getThemeSnackBarTextColor(context) ?? Colors.white,
      );
    } else {
      // Widget인 경우 그대로 사용
      messageWidget = message as Widget;
    }

    // 전달받은 context를 그대로 사용
    // Dialog 내부에서 사용할 때는 원래 Scaffold의 context를 전달받아 사용
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: messageWidget,
        backgroundColor:
            backgroundColor ??
            _getThemeSnackBarBackgroundColor(context) ??
            Colors.grey.shade800,
        duration: duration,
        behavior: behavior,
        // margin은 floating에서만 사용 가능
        margin: behavior == SnackBarBehavior.floating ? margin : null,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: _getThemeSnackBarTextColor(context) ?? Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  // 성공 메시지를 표시하는 메서드 (녹색 배경)
  static void showSuccess(
    BuildContext context, {
    required dynamic message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      behavior: behavior,
      margin: margin,
    );
  }

  // 에러 메시지를 표시하는 메서드 (빨간색 배경)
  static void showError(
    BuildContext context, {
    required dynamic message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      behavior: behavior,
      margin: margin,
    );
  }

  // 경고 메시지를 표시하는 메서드 (주황색 배경)
  static void showWarning(
    BuildContext context, {
    required dynamic message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      behavior: behavior,
      margin: margin,
    );
  }

  // 정보 메시지를 표시하는 메서드 (파란색 배경)
  static void showInfo(
    BuildContext context, {
    required dynamic message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      behavior: behavior,
      margin: margin,
    );
  }
}
