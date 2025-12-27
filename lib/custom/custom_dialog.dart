import 'custom_button.dart';
import 'custom_text.dart';
import 'utils_core.dart';
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

Color? _getThemeCardBackgroundColor(BuildContext context) {
  try {
    return context.palette.cardBackground;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey[900] : Colors.white;
  }
}

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
    return Colors.grey;
  }
}

// 다이얼로그 타입 enum
enum DialogType {
  // 확인만 있는 다이얼로그 (단일 버튼)
  single,

  // 확인/취소가 있는 다이얼로그 (이중 버튼)
  dual,

  // 커스텀 버튼들을 사용하는 다이얼로그
  custom,
}

// 다이얼로그 액션 아이템 클래스
// 각 버튼의 정보를 담는 클래스입니다.
class DialogActionItem {
  // 버튼에 표시할 텍스트 또는 위젯
  // String인 경우 CustomText로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  // 버튼 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  // 버튼 클릭 시 실행될 콜백 (Dialog context 전달)
  final void Function(BuildContext dialogContext)? onTapWithContext;

  // 버튼 타입 (기본값: ButtonType.text)
  final ButtonType buttonType;

  // 버튼 배경색
  final Color? backgroundColor;

  // 버튼 전경색/텍스트 색상
  final Color? foregroundColor;

  // 버튼 최소 크기
  final Size? minimumSize;

  // 버튼 모서리 둥글기
  final double? borderRadius;

  // 이 버튼 클릭 시 다이얼로그가 자동으로 닫힐지 여부 (기본값: true)
  final bool autoDismiss;

  DialogActionItem({
    required this.label,
    this.onTap,
    this.onTapWithContext,
    this.buttonType = ButtonType.text,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumSize,
    this.borderRadius,
    this.autoDismiss = true,
  }) : assert(
         CustomCommonUtil.isString(label) || CustomCommonUtil.isWidget(label),
         'label은 String 또는 Widget이어야 합니다.',
       );
}

// 다이얼로그 액션 그룹 클래스
// 버튼들을 그룹으로 묶어서 배치 방향을 지정할 수 있습니다.
// Column과 Row를 섞어서 그리드처럼 배치할 수 있습니다.
class DialogActionGroup {
  // 이 그룹의 버튼들
  final List<DialogActionItem> actions;

  // 배치 방향 (기본값: Axis.vertical, Column 사용)
  final Axis direction;

  // 주축 정렬 (Row의 경우 MainAxisAlignment, Column의 경우 MainAxisAlignment)
  final MainAxisAlignment mainAxisAlignment;

  // 교차축 정렬 (Row의 경우 CrossAxisAlignment, Column의 경우 CrossAxisAlignment)
  final CrossAxisAlignment crossAxisAlignment;

  // 버튼 간 간격
  final double? spacing;

  DialogActionGroup({
    required this.actions,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing,
  });
}

// 다이얼로그 헬퍼 클래스
//
// 사용 예시:
// ```dart
// CustomDialog.show(context, title: "알림", message: "메시지")
// CustomDialog.show(context, title: "확인", message: "진행하시겠습니까?", type: DialogType.dual, onConfirm: () {})
// ```
class CustomDialog {
  // 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required dynamic title,
    required dynamic message,
    DialogType type = DialogType.single,
    String confirmText = "확인",
    String cancelText = "취소",
    VoidCallback? onConfirm,
    void Function(BuildContext dialogContext)? onConfirmWithContext,
    void Function(BuildContext dialogContext, BuildContext scaffoldContext)?
    onConfirmWithContexts,
    VoidCallback? onCancel,
    void Function(BuildContext dialogContext)? onCancelWithContext,
    void Function(BuildContext dialogContext, BuildContext scaffoldContext)?
    onCancelWithContexts,
    bool autoDismissOnConfirm = true,
    bool autoDismissOnCancel = true,
    List<DialogActionItem>? customActions,
    List<DialogActionGroup>? customActionGroups,
    List<Widget>? actions,
    bool barrierDismissible = false,
    Color? backgroundColor,
    double? borderRadius,
    MainAxisAlignment actionsAlignment = MainAxisAlignment.center,
  }) {
    // title과 message가 String인지 Widget인지 확인
    assert(
      CustomCommonUtil.isString(title) || CustomCommonUtil.isWidget(title),
      'title은 String 또는 Widget이어야 합니다.',
    );
    assert(
      CustomCommonUtil.isString(message) || CustomCommonUtil.isWidget(message),
      'message는 String 또는 Widget이어야 합니다.',
    );

    // 커스텀 액션이 있으면 기본 버튼 무시하고 customActions만 사용
    final hasCustomActions = customActions != null && customActions.isNotEmpty;
    final hasCustomActionGroups =
        customActionGroups != null && customActionGroups.isNotEmpty;
    final hasActions = actions != null && actions.isNotEmpty;
    final hasAnyCustomAction =
        hasCustomActions || hasCustomActionGroups || hasActions;
    final effectiveType = hasAnyCustomAction ? DialogType.custom : type;

    // actionsAlignment는 dual 타입(기본 버튼 2개)일 때만 사용
    final effectiveAlignment = (effectiveType == DialogType.dual)
        ? actionsAlignment
        : MainAxisAlignment.center;

    // title Widget 생성
    Widget titleWidget;
    if (CustomCommonUtil.isString(title)) {
      titleWidget = CustomText(
        title as String,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _getThemeTextPrimaryColor(context) ?? Colors.black,
      );
    } else {
      titleWidget = title as Widget;
    }

    // message Widget 생성
    Widget messageWidget;
    if (CustomCommonUtil.isString(message)) {
      messageWidget = CustomText(
        message as String,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _getThemeTextPrimaryColor(context) ?? Colors.black,
      );
    } else {
      messageWidget = message as Widget;
    }

    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        // Dialog 내부에 ScaffoldMessenger와 투명한 Scaffold를 추가하여
        // SnackBar가 Dialog 위에 표시되도록 함
        return ScaffoldMessenger(
          child: Builder(
            builder: (scaffoldContext) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: MediaQuery.removePadding(
                  context: scaffoldContext,
                  removeBottom: true,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: AlertDialog(
                        backgroundColor:
                            backgroundColor ??
                            _getThemeCardBackgroundColor(context) ??
                            Colors.white,
                        shape: borderRadius != null
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              )
                            : null,
                        title: titleWidget,
                        content: messageWidget,
                        actionsAlignment: effectiveAlignment,
                        actions: _buildActions(
                          ctx: ctx,
                          scaffoldContext:
                              context, // 원래 Scaffold context (하위 호환성)
                          dialogScaffoldContext:
                              scaffoldContext, // Dialog 내부 Scaffold context
                          type: effectiveType,
                          confirmText: confirmText,
                          cancelText: cancelText,
                          onConfirm: onConfirm,
                          onConfirmWithContext: onConfirmWithContext,
                          onConfirmWithContexts: onConfirmWithContexts,
                          onCancel: onCancel,
                          onCancelWithContext: onCancelWithContext,
                          onCancelWithContexts: onCancelWithContexts,
                          autoDismissOnConfirm: autoDismissOnConfirm,
                          autoDismissOnCancel: autoDismissOnCancel,
                          customActions: customActions,
                          customActionGroups: customActionGroups,
                          actions: actions,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 다이얼로그 액션 버튼들을 생성하는 메서드
  static List<Widget> _buildActions({
    required BuildContext ctx,
    required BuildContext scaffoldContext,
    required BuildContext dialogScaffoldContext,
    required DialogType type,
    required String confirmText,
    required String cancelText,
    VoidCallback? onConfirm,
    void Function(BuildContext dialogContext)? onConfirmWithContext,
    void Function(BuildContext dialogContext, BuildContext scaffoldContext)?
    onConfirmWithContexts,
    VoidCallback? onCancel,
    void Function(BuildContext dialogContext)? onCancelWithContext,
    void Function(BuildContext dialogContext, BuildContext scaffoldContext)?
    onCancelWithContexts,
    bool autoDismissOnConfirm = true,
    bool autoDismissOnCancel = true,
    List<DialogActionItem>? customActions,
    List<DialogActionGroup>? customActionGroups,
    List<Widget>? actions,
  }) {
    // actions 위젯이 직접 제공된 경우 (최우선)
    if (actions != null && actions.isNotEmpty) {
      return actions;
    }

    // customActionGroups가 제공된 경우
    if (customActionGroups != null && customActionGroups.isNotEmpty) {
      return customActionGroups.map((group) {
        // 그룹 내 버튼들을 생성
        final groupButtons = <Widget>[];
        for (final action in group.actions) {
          groupButtons.add(
            CustomButton(
              btnText: action.label,
              buttonType: action.buttonType,
              backgroundColor: action.backgroundColor,
              foregroundColor: action.foregroundColor,
              minimumSize: group.direction == Axis.horizontal
                  ? (action.minimumSize ?? const Size(0, 40))
                  : (action.minimumSize ?? const Size(double.infinity, 40)),
              borderRadius: action.borderRadius,
              onCallBack: () {
                action.onTapWithContext?.call(ctx);
                action.onTap?.call();
                if (action.autoDismiss) {
                  Navigator.of(ctx).pop();
                }
              },
            ),
          );

          // spacing이 있고 마지막 버튼이 아니면 간격 추가
          if (group.spacing != null &&
              groupButtons.length < group.actions.length) {
            if (group.direction == Axis.horizontal) {
              groupButtons.add(SizedBox(width: group.spacing));
            } else {
              groupButtons.add(SizedBox(height: group.spacing));
            }
          }
        }

        // 방향에 따라 Row 또는 Column으로 배치
        if (group.direction == Axis.horizontal) {
          return SizedBox(
            height: 40, // Row의 높이를 고정하여 무한 높이 제약 문제 해결
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: group.mainAxisAlignment,
              crossAxisAlignment: group.crossAxisAlignment,
              children: groupButtons,
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: group.mainAxisAlignment,
            crossAxisAlignment: group.crossAxisAlignment,
            children: groupButtons,
          );
        }
      }).toList();
    }

    // customActions가 제공된 경우 (하위 호환성)
    if (type == DialogType.custom && customActions != null) {
      // 기본적으로 Column으로 세로 배치
      return [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: customActions.map((action) {
            return CustomButton(
              btnText: action.label,
              buttonType: action.buttonType,
              backgroundColor: action.backgroundColor,
              foregroundColor: action.foregroundColor,
              minimumSize:
                  action.minimumSize ?? const Size(double.infinity, 40),
              borderRadius: action.borderRadius,
              onCallBack: () {
                action.onTapWithContext?.call(ctx);
                action.onTap?.call();
                if (action.autoDismiss) {
                  Navigator.of(ctx).pop();
                }
              },
            );
          }).toList(),
        ),
      ];
    } else if (type == DialogType.single) {
      // 단일 버튼 (확인만)
      return [
        CustomButton(
          btnText: confirmText,
          backgroundColor: _getThemePrimaryColor(ctx) ?? Colors.blue,
          minimumSize: const Size(100, 40),
          onCallBack: () {
            onConfirmWithContexts?.call(ctx, scaffoldContext);
            onConfirmWithContext?.call(ctx);
            onConfirm?.call();
            if (autoDismissOnConfirm) {
              Navigator.of(ctx).pop();
            }
          },
        ),
      ];
    } else {
      // 이중 버튼 (확인/취소)
      return [
        CustomButton(
          btnText: cancelText,
          buttonType: ButtonType.outlined,
          backgroundColor: _getThemeTextSecondaryColor(ctx) ?? Colors.grey,
          minimumSize: const Size(80, 40),
          onCallBack: () {
            onCancelWithContexts?.call(ctx, scaffoldContext);
            onCancelWithContext?.call(ctx);
            onCancel?.call();
            if (autoDismissOnCancel) {
              Navigator.of(ctx).pop();
            }
          },
        ),
        CustomButton(
          btnText: confirmText,
          backgroundColor: _getThemePrimaryColor(ctx) ?? Colors.blue,
          minimumSize: const Size(80, 40),
          onCallBack: () {
            onConfirmWithContexts?.call(ctx, scaffoldContext);
            onConfirmWithContext?.call(ctx);
            onConfirm?.call();
            if (autoDismissOnConfirm) {
              Navigator.of(ctx).pop();
            }
          },
        ),
      ];
    }
  }
}
