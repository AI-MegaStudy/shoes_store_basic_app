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

Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey;
  }
}

// 리스트 선택기 위젯
//
// 사용 예시:
// ```dart
// CustomPickerView(items: ['옵션1', '옵션2'], selectedItem: '옵션1', onItemSelected: (item) {})
// ```
class CustomPickerView<T> extends StatelessWidget {
  // 선택 가능한 항목 리스트 (필수)
  final List<T> items;

  // 현재 선택된 항목
  final T? selectedItem;

  // 항목 선택 시 호출되는 콜백 함수 (필수)
  final ValueChanged<T> onItemSelected;

  // 커스텀 아이템 빌더 함수 (null이면 기본 Text 위젯 사용)
  final Widget Function(T item)? itemBuilder;

  // 선택기 높이 (기본값: 200)
  final double? height;

  // 아이템 높이 (기본값: 50)
  final double? itemHeight;

  // 배경색
  final Color? backgroundColor;

  // 선택된 아이템 스타일
  final TextStyle? selectedItemStyle;

  // 선택되지 않은 아이템 스타일
  final TextStyle? unselectedItemStyle;

  // 선택된 아이템 배경색
  final Color? selectedItemColor;

  // 선택되지 않은 아이템 배경색
  final Color? unselectedItemColor;

  // 스크롤 물리 효과
  final ScrollPhysics? physics;

  // 다중 선택 모드 (기본값: false)
  final bool multiSelect;

  // 다중 선택된 항목 리스트 (multiSelect가 true일 때 사용)
  final List<T>? selectedItems;

  // 다중 선택 시 호출되는 콜백 함수
  final ValueChanged<List<T>>? onItemsSelected;

  const CustomPickerView({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onItemSelected,
    this.itemBuilder,
    this.height,
    this.itemHeight,
    this.backgroundColor,
    this.selectedItemStyle,
    this.unselectedItemStyle,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.physics,
    this.multiSelect = false,
    this.selectedItems,
    this.onItemsSelected,
  }) : assert(
         !multiSelect ||
             (multiSelect && selectedItems != null && onItemsSelected != null),
         '다중 선택 모드에서는 selectedItems와 onItemsSelected가 필요합니다.',
       );

  @override
  Widget build(BuildContext context) {
    if (multiSelect) {
      return _buildMultiSelectPicker(context);
    }
    return _buildSingleSelectPicker(context);
  }

  Widget _buildSingleSelectPicker(BuildContext context) {
    return Container(
      height: height ?? 200,
      color: backgroundColor ?? Colors.transparent,
      child: ListView.builder(
        physics: physics ?? const BouncingScrollPhysics(),
        itemCount: items.length,
        itemExtent: itemHeight ?? 50,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItem == item;

          return InkWell(
            onTap: () => onItemSelected(item),
            child: Container(
              color: isSelected
                  ? (selectedItemColor ?? Colors.blue.withOpacity(0.1))
                  : (unselectedItemColor ?? Colors.transparent),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: itemBuilder != null
                  ? itemBuilder!(item)
                  : Text(
                      item.toString(),
                      style: isSelected
                          ? (selectedItemStyle ??
                                TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _getThemePrimaryColor(context) ??
                                      Colors.blue,
                                ))
                          : (unselectedItemStyle ??
                                TextStyle(
                                  fontSize: 16,
                                  color:
                                      _getThemeTextPrimaryColor(context) ??
                                      Colors.black87,
                                )),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMultiSelectPicker(BuildContext context) {
    final selected = selectedItems ?? [];

    return Container(
      height: height ?? 200,
      color: backgroundColor ?? Colors.transparent,
      child: ListView.builder(
        physics: physics ?? const BouncingScrollPhysics(),
        itemCount: items.length,
        itemExtent: itemHeight ?? 50,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected.contains(item);

          return InkWell(
            onTap: () {
              final newSelected = List<T>.from(selected);
              if (isSelected) {
                newSelected.remove(item);
              } else {
                newSelected.add(item);
              }
              onItemsSelected!(newSelected);
            },
            child: Container(
              color: isSelected
                  ? (selectedItemColor ?? Colors.blue.withOpacity(0.1))
                  : (unselectedItemColor ?? Colors.transparent),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: _getThemePrimaryColor(context) ?? Colors.blue,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color:
                          _getThemeTextSecondaryColor(context) ?? Colors.grey,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: itemBuilder != null
                        ? itemBuilder!(item)
                        : Text(
                            item.toString(),
                            style: isSelected
                                ? (selectedItemStyle ??
                                      TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _getThemePrimaryColor(context) ??
                                            Colors.blue,
                                      ))
                                : (unselectedItemStyle ??
                                      TextStyle(
                                        fontSize: 16,
                                        color:
                                            _getThemeTextPrimaryColor(
                                              context,
                                            ) ??
                                            Colors.black87,
                                      )),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
