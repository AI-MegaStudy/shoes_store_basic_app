import 'custom_text.dart';
import 'custom_common_util.dart';
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

// 버튼 타입을 선택하는 enum
enum ButtonType {
  // TextButton 타입
  text,

  // ElevatedButton 타입
  elevated,

  // OutlinedButton 타입
  outlined,
}

// 버튼 위젯 (TextButton, ElevatedButton, OutlinedButton 지원)
//
// 사용 예시:
// ```dart
// CustomButton(btnText: "확인", onCallBack: () {})
// CustomButton(btnText: "확인", buttonType: ButtonType.elevated, backgroundColor: Colors.red, onCallBack: () {})
// ```
class CustomButton extends StatelessWidget {
  // 버튼에 표시할 텍스트 또는 위젯 (필수)
  // String인 경우 CustomText로 자동 변환, Widget인 경우 그대로 사용
  final dynamic btnText;

  // 버튼 클릭 시 실행될 콜백 함수
  // null로 설정하면 버튼이 비활성화됩니다
  final VoidCallback? onCallBack;

  // 버튼 타입 (기본값: ButtonType.text)
  final ButtonType buttonType;

  // 버튼 배경색 (기본값: Colors.blue)
  final Color? backgroundColor;

  // 버튼 전경색/텍스트 색상
  // - TextButton, ElevatedButton: 기본값 Colors.white (배경색이 있으므로)
  // - OutlinedButton: 기본값 Colors.black (배경색이 없으므로)
  final Color? foregroundColor;

  // 버튼 최소 크기 (기본값: Size(100, 60))
  final Size? minimumSize;

  // 버튼 고정 크기 (설정 시 minimumSize보다 우선 적용)
  final Size? fixedSize;

  // 버튼 모서리 둥글기 (기본값: 10)
  final double? borderRadius;

  // 커스텀 버튼 스타일 (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final ButtonStyle? btnStyle;

  // CustomText의 fontSize (기본값: 20)
  final double? textFontSize;

  // CustomText의 fontWeight (기본값: FontWeight.bold)
  final FontWeight? textFontWeight;

  // CustomText의 color
  // - textColor가 명시되면 그것을 사용
  // - 배경색이 있는 버튼(TextButton, ElevatedButton): 기본값 Colors.white
  // - 배경색이 없는 버튼(OutlinedButton): 기본값 Colors.black
  final Color? textColor;

  CustomButton({
    super.key,
    required this.btnText,
    this.onCallBack,
    this.buttonType = ButtonType.text,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumSize,
    this.fixedSize,
    this.borderRadius,
    this.btnStyle,
    this.textFontSize,
    this.textFontWeight,
    this.textColor,
  }) : assert(
         CustomCommonUtil.isString(btnText) ||
             CustomCommonUtil.isWidget(btnText),
         'btnText는 String 또는 Widget이어야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    // 기본 스타일 생성
    final defaultStyle = _createButtonStyle(context);

    // 사용자가 커스텀 btnStyle을 제공한 경우, 기본 스타일과 병합
    final finalStyle = btnStyle != null
        ? defaultStyle.merge(btnStyle)
        : defaultStyle;

    // btnText가 String인지 Widget인지 확인하고 처리
    Widget buttonChild;

    if (CustomCommonUtil.isString(btnText)) {
      // String인 경우 CustomText로 변환
      // CustomText의 색상 결정
      // - textColor가 명시되면 그것을 사용
      // - 배경색이 있는 버튼(TextButton, ElevatedButton): 기본 흰색
      // - 배경색이 없는 버튼(OutlinedButton): 기본 검은색
      // 텍스트 색상 결정
      // - textColor가 명시되면 그것을 사용
      // - foregroundColor가 있으면 사용
      // - OutlinedButton: 테마 텍스트 색상 또는 검은색
      // - TextButton/ElevatedButton: 흰색
      final textColorFinal =
          textColor ??
          foregroundColor ??
          (buttonType == ButtonType.outlined
              ? (_getThemeTextPrimaryColor(context) ?? Colors.black)
              : Colors.white);

      // CustomText 위젯 생성
      buttonChild = CustomText(
        btnText as String,
        fontSize: textFontSize ?? 20,
        fontWeight: textFontWeight ?? FontWeight.bold,
        color: textColorFinal,
      );
    } else {
      // Widget인 경우 그대로 사용
      buttonChild = btnText as Widget;
    }

    // 버튼 타입에 따라 적절한 버튼 위젯 반환
    // onCallBack이 null이면 버튼이 비활성화됩니다
    switch (buttonType) {
      case ButtonType.text:
        return TextButton(
          onPressed: onCallBack,
          style: finalStyle,
          child: buttonChild,
        );
      case ButtonType.elevated:
        return ElevatedButton(
          onPressed: onCallBack,
          style: finalStyle,
          child: buttonChild,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: onCallBack,
          style: finalStyle,
          child: buttonChild,
        );
    }
  }

  // 기본 버튼 스타일을 생성하는 메서드
  ButtonStyle _createButtonStyle(BuildContext context) {
    final bgColor =
        backgroundColor ?? _getThemePrimaryColor(context) ?? Colors.blue;
    final minSize = minimumSize ?? const Size(100, 60);
    final radius = borderRadius ?? 10;

    // 버튼 타입에 따라 다른 스타일 생성
    switch (buttonType) {
      case ButtonType.text:
        // TextButton: 배경색이 있으므로 기본 텍스트 색상은 흰색
        final textFgColor = foregroundColor ?? Colors.white;
        return TextButton.styleFrom(
          minimumSize: fixedSize != null ? null : minSize,
          fixedSize: fixedSize,
          foregroundColor: textFgColor,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      case ButtonType.elevated:
        // ElevatedButton: 배경색이 있으므로 기본 텍스트 색상은 흰색
        final elevatedFgColor = foregroundColor ?? Colors.white;
        return ElevatedButton.styleFrom(
          minimumSize: fixedSize != null ? null : minSize,
          fixedSize: fixedSize,
          foregroundColor: elevatedFgColor,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      case ButtonType.outlined:
        // OutlinedButton: 배경색이 없으므로 기본 텍스트 색상은 테마 텍스트 색상 또는 검은색
        final outlinedFgColor =
            foregroundColor ??
            _getThemeTextPrimaryColor(context) ??
            Colors.black;
        return OutlinedButton.styleFrom(
          minimumSize: fixedSize != null ? null : minSize,
          fixedSize: fixedSize,
          foregroundColor: outlinedFgColor,
          side: BorderSide(color: bgColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    }
  }
}
