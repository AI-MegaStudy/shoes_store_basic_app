import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/admin_storage.dart';

/// 관리자 메뉴 타입 열거형
enum AdminMenuType {
  orderManagement,
  returnManagement,
}

/// 관리자 드로워 메뉴 아이템 클래스
class AdminDrawerMenuItem {
  final String label;
  final IconData icon;
  final AdminMenuType menuType;
  final void Function(BuildContext) onTap;

  const AdminDrawerMenuItem({
    required this.label,
    required this.icon,
    required this.menuType,
    required this.onTap,
  });
}

/// 관리자 드로워 위젯
class AdminDrawer extends StatelessWidget {
  final AdminMenuType currentMenu;
  final String? userName;
  final String? userRole;
  final List<AdminDrawerMenuItem>? menuItems;
  final VoidCallback? onProfileEditTap;

  const AdminDrawer({
    super.key,
    required this.currentMenu,
    this.userName,
    this.userRole,
    this.menuItems,
    this.onProfileEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = userName ?? '관리자';
    final String displayRole = userRole ?? '관리자';
    final List<AdminDrawerMenuItem> items = menuItems ?? _getDefaultMenuItems(context);

    return CustomDrawer(
      header: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: context.palette.primary),
        padding: config.screenPadding,
        child: CustomColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: config.smallSpacing,
          children: [
            CustomText(
              displayRole,
              style: config.mediumTextStyle,
              color: context.palette.textOnPrimary,
            ),
            CustomText(
              displayName,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.palette.textOnPrimary,
            ),
          ],
        ),
      ),
      middleChildren: [const Divider(height: 1)],
      items: items.map((item) {
        return DrawerItem(
          label: item.label,
          icon: item.icon,
          selected: item.menuType == currentMenu,
          onTap: () {
            if (item.menuType != currentMenu) {
              // Scaffold의 context를 가져와서 저장 (드로어를 닫기 전에)
              final scaffoldContext = Scaffold.of(context).context;
              // 드로어를 닫지 않고 바로 페이지 교체
              // pushReplacement로 페이지가 교체되면 드로어는 자동으로 닫힘
              item.onTap(scaffoldContext);
            } else {
              // 현재 메뉴이면 드로어만 닫기
              Navigator.of(context).pop();
            }
          },
        );
      }).toList(),
      bottomChildren: [const Divider(height: 1)],
      footer: Padding(
        padding: config.screenPadding,
        child: CustomColumn(
          spacing: config.mediumSpacing,
          children: [
            CustomButton(
              btnText: '개인정보 수정',
              buttonType: ButtonType.outlined,
              onCallBack: () {
                CustomNavigationUtil.back(context);
                onProfileEditTap?.call();
              },
              minimumSize: const Size(double.infinity, 48),
            ),
            CustomButton(
              btnText: '테스트 페이지로 이동',
              buttonType: ButtonType.outlined,
              onCallBack: () {
                CustomNavigationUtil.back(context);
                CustomNavigationUtil.toNamed(context, config.routeTestNavigationPage);
              },
              minimumSize: const Size(double.infinity, 48),
            ),
            CustomButton(
              btnText: '로그아웃',
              buttonType: ButtonType.outlined,
              onCallBack: () {
                // Scaffold context를 미리 저장 (드로어 닫기 전에)
                final scaffoldContext = Scaffold.of(context).context;
                // 드로어 닫기
                Navigator.of(context).pop();
                // 다음 프레임에서 다이얼로그 표시 (드로어가 완전히 닫힌 후)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    CustomDialog.show(
                      scaffoldContext,
                      title: '로그아웃',
                      message: '정말 로그아웃하시겠습니까?',
                      type: DialogType.dual,
                      confirmText: '로그아웃',
                      cancelText: '취소',
                      autoDismissOnConfirm: false,
                      onConfirmWithContext: (dialogContext) {
                        AdminStorage.clearAdmin();
                        // 다이얼로그 닫기
                        Navigator.of(dialogContext).pop();
                        // 다음 프레임에서 navigation 수행 (다이얼로그가 완전히 닫힌 후)
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (scaffoldContext.mounted) {
                            CustomNavigationUtil.offAllNamed(scaffoldContext, config.routeAdminLogin);
                          }
                        });
                      },
                    );
                  }
                });
              },
              minimumSize: const Size(double.infinity, 48),
            ),
          ],
        ),
      ),
    );
  }

  List<AdminDrawerMenuItem> _getDefaultMenuItems(BuildContext context) {
    return [
      AdminDrawerMenuItem(
        label: '주문 관리',
        icon: Icons.shopping_cart,
        menuType: AdminMenuType.orderManagement,
        onTap: (_) {},
      ),
      AdminDrawerMenuItem(
        label: '반품 관리',
        icon: Icons.assignment_return,
        menuType: AdminMenuType.returnManagement,
        onTap: (_) {},
      ),
    ];
  }
}

