import 'package:flutter/material.dart';
import 'custom_common_util.dart';
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

Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey;
  }
}

Color? _getThemeCardBackgroundColor(BuildContext context) {
  try {
    return context.palette.cardBackground;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey[900] : Colors.white;
  }
}

// DropdownButton 위젯 (String/Widget 지원)
//
// 사용 예시:
// ```dart
// CustomDropdownButton(value: selectedValue, items: ['옵션1', '옵션2'], onChanged: (value) {})
// ```
class CustomDropdownButton<T> extends StatelessWidget {
  // 현재 선택된 값
  final T? value;

  // 선택 가능한 항목 리스트 (필수)
  // String 또는 Widget 리스트를 지원합니다.
  final List<dynamic> items;

  // 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<T?>? onChanged;

  // 드롭다운 버튼 힌트 텍스트
  final String? hint;

  // 드롭다운 버튼 힌트 위젯
  final Widget? hintWidget;

  // 드롭다운 버튼 비활성화 여부 (기본값: false)
  final bool isEnabled;

  // 드롭다운 버튼 배경색
  final Color? backgroundColor;

  // 드롭다운 버튼 테두리 색상
  final Color? borderColor;

  // 드롭다운 버튼 테두리 두께
  final double? borderWidth;

  // 드롭다운 버튼 모서리 둥글기
  final double? borderRadius;

  // 드롭다운 버튼 패딩
  final EdgeInsets? padding;

  // 드롭다운 버튼 너비
  final double? width;

  // 드롭다운 버튼 높이
  final double? height;

  // 텍스트 스타일
  final TextStyle? textStyle;

  // 아이콘 색상
  final Color? iconColor;

  // 아이콘 크기
  final double? iconSize;

  // 드롭다운 메뉴 배경색
  final Color? dropdownColor;

  // 드롭다운 메뉴 아이템 높이
  final double? itemHeight;

  // 커스텀 아이템 빌더 함수
  // null이면 기본 Text 위젯 또는 Widget을 사용합니다.
  final Widget Function(dynamic item)? itemBuilder;

  // 커스텀 선택된 아이템 빌더 함수
  // null이면 기본 Text 위젯 또는 Widget을 사용합니다.
  final Widget Function(T? value)? selectedItemBuilder;

  const CustomDropdownButton({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.hintWidget,
    this.isEnabled = true,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.dropdownColor,
    this.itemHeight,
    this.itemBuilder,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // DropdownMenuItem 리스트 생성
    final List<DropdownMenuItem<T>> dropdownItems = items.map((item) {
      return DropdownMenuItem<T>(
        value: item is T ? item : null,
        child: itemBuilder != null
            ? itemBuilder!(item)
            : CustomCommonUtil.toWidget(
                item,
                style:
                    textStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: _getThemeTextPrimaryColor(context) ?? Colors.black,
                    ),
              ),
      );
    }).toList();

    // 선택된 아이템 빌더 (DropdownButton의 selectedItemBuilder는 List<Widget>을 반환해야 함)
    List<Widget> Function(BuildContext)? selectedItemListBuilder;
    if (selectedItemBuilder != null) {
      selectedItemListBuilder = (context) {
        return items.map<Widget>((item) {
          // value와 일치하는 item에 대해서만 selectedItemBuilder 사용
          if (item == value) {
            return selectedItemBuilder!(value);
          }
          // 다른 item들은 기본 표시
          return itemBuilder != null
              ? itemBuilder!(item)
              : CustomCommonUtil.toWidget(
                  item,
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16,
                        color:
                            _getThemeTextPrimaryColor(context) ?? Colors.black,
                      ),
                );
        }).toList();
      };
    } else if (value != null) {
      // selectedItemBuilder가 없으면 기본 처리
      selectedItemListBuilder = (context) {
        return items.map<Widget>((item) {
          return itemBuilder != null
              ? itemBuilder!(item)
              : CustomCommonUtil.toWidget(
                  item,
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16,
                        color:
                            _getThemeTextPrimaryColor(context) ?? Colors.black,
                      ),
                );
        }).toList();
      };
    }

    // 힌트 위젯
    final Widget? hintWidgetToUse =
        hintWidget ??
        (hint != null
            ? Text(
                hint!,
                style:
                    textStyle?.copyWith(
                      color:
                          _getThemeTextSecondaryColor(context) ?? Colors.grey,
                    ) ??
                    TextStyle(
                      fontSize: 16,
                      color:
                          _getThemeTextSecondaryColor(context) ?? Colors.grey,
                    ),
              )
            : null);

    // 드롭다운 버튼 위젯
    final dropdownButton = DropdownButton<T>(
      value: value,
      items: dropdownItems,
      onChanged: isEnabled ? onChanged : null,
      hint: hintWidgetToUse,
      selectedItemBuilder: selectedItemListBuilder,
      style:
          textStyle ??
          TextStyle(
            fontSize: 16,
            color: _getThemeTextPrimaryColor(context) ?? Colors.black,
          ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: iconColor ?? _getThemeTextSecondaryColor(context) ?? Colors.grey,
        size: iconSize ?? 24,
      ),
      dropdownColor:
          dropdownColor ??
          _getThemeCardBackgroundColor(context) ??
          Colors.white,
      itemHeight: itemHeight ?? kMinInteractiveDimension,
      isExpanded: width != null,
    );

    // 스타일이 적용된 컨테이너로 감싸기
    return Container(
      width: width,
      height: height,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            _getThemeCardBackgroundColor(context) ??
            Colors.white,
        border: Border.all(
          color:
              borderColor ??
              _getThemeTextSecondaryColor(context) ??
              Colors.grey.shade300,
          width: borderWidth ?? 1.0,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 4.0),
      ),
      child: dropdownButton,
    );
  }
}
