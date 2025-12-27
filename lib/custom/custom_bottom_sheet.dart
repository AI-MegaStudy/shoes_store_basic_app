import 'custom_text.dart';
import 'utils_core.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeCardBackgroundColor(BuildContext context) {
  try {
    return context.palette.cardBackground;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey[900] : Colors.white;
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

Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey;
  }
}

// BottomSheet 항목 정보 클래스
class BottomSheetItem {
  // 항목의 텍스트 또는 위젯
  // String인 경우 CustomText로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  // 항목의 아이콘 (선택사항)
  final IconData? icon;

  // 항목의 텍스트 색상 (선택사항, 기본값: Colors.black)
  final Color? textColor;

  // 항목 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  // 이 항목이 위험한 작업인지 여부 (true일 경우 빨간색으로 표시)
  final bool isDestructive;

  BottomSheetItem({
    required this.label,
    this.icon,
    this.textColor,
    this.onTap,
    this.isDestructive = false,
  }) : assert(
         CustomCommonUtil.isString(label) || CustomCommonUtil.isWidget(label),
         'label은 String 또는 Widget이어야 합니다.',
       );
}

// 하단 시트 다이얼로그 헬퍼 클래스
//
// 사용 예시:
// ```dart
// CustomBottomSheet.show(
//   context: context,
//   title: "옵션 선택",
//   items: [BottomSheetItem(label: "옵션1", onTap: () {})],
// )
// ```
class CustomBottomSheet {
  // BottomSheet를 표시하는 정적 메서드
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    List<BottomSheetItem>? items,
    Widget? child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? borderRadius,
    bool isScrollControlled = false,
    double? height,
  }) {
    assert(
      (items != null && items.isNotEmpty) || child != null,
      'items 또는 child 중 하나는 필수입니다.',
    );

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor:
          backgroundColor ??
          _getThemeCardBackgroundColor(context) ??
          Colors.white,
      isScrollControlled: isScrollControlled,
      shape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
            )
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
      builder: (ctx) {
        Widget content;

        if (child != null) {
          // 커스텀 위젯이 제공된 경우
          content = child;
        } else {
          // items가 제공된 경우
          content = SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목과 메시지
                if (title != null || message != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          CustomText(
                            title,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                _getThemeTextPrimaryColor(context) ??
                                Colors.black,
                          ),
                        if (message != null) ...[
                          if (title != null) const SizedBox(height: 4),
                          CustomText(
                            message,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color:
                                _getThemeTextSecondaryColor(context) ??
                                Colors.grey.shade600,
                          ),
                        ],
                      ],
                    ),
                  ),

                // 구분선
                if (title != null || message != null) const Divider(height: 20),

                // 항목들
                ...items!.map((item) {
                  // label이 String인지 Widget인지 확인하고 처리
                  Widget labelWidget;
                  if (CustomCommonUtil.isString(item.label)) {
                    // String인 경우 CustomText로 변환
                    labelWidget = CustomText(
                      item.label as String,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: item.isDestructive
                          ? Colors.red
                          : (item.textColor ??
                                _getThemeTextPrimaryColor(context) ??
                                Colors.black),
                    );
                  } else {
                    // Widget인 경우 그대로 사용
                    labelWidget = item.label as Widget;
                  }

                  return ListTile(
                    leading: item.icon != null
                        ? Icon(
                            item.icon,
                            color: item.isDestructive
                                ? Colors.red
                                : (item.textColor ??
                                      _getThemeTextPrimaryColor(context) ??
                                      Colors.black),
                          )
                        : null,
                    title: labelWidget,
                    onTap: () {
                      CustomNavigationUtil.back(ctx, result: item.onTap);
                      item.onTap?.call();
                    },
                  );
                }),
              ],
            ),
          );
        }

        // height가 지정된 경우 SizedBox로 감싸기
        if (height != null) {
          content = SizedBox(height: height, child: content);
        }

        return content;
      },
    );
  }
}
