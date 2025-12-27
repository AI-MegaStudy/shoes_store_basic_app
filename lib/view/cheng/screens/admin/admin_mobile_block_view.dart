import 'package:flutter/material.dart';
import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';

import 'package:shoes_store_basic_app/custom/custom.dart';

class AdminMobileBlockView extends StatelessWidget {
  const AdminMobileBlockView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      appBar: CustomAppBar(title: '접근 제한', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: config.screenPadding,
            child: CustomColumn(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: config.defaultSpacing,
              children: [
                Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: p.accent,
                  ),
                ),
                CustomCard(
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: config.smallSpacing, // spacing으로 통일하여 SizedBox 제거
                    children: [
                      CustomText(
                        '모바일 접근 제한',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      CustomText(
                        '관리자 기능은 태블릿에서만 사용 가능합니다.',
                        style: config.mediumTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      CustomText(
                        '관리자 계정으로 로그인하시려면 태블릿 기기에서 접속해주세요.',
                        style: config.bodyTextStyle,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      CustomText(
                        '안내 사항',
                        style: config.mediumTextStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      CustomText(
                        '• 관리자 기능은 보안상의 이유로 태블릿에서만 제공됩니다.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      CustomText(
                        '• 일반 사용자는 모바일에서도 모든 기능을 이용할 수 있습니다.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      CustomText(
                        '• 문의사항이 있으시면 고객센터로 연락해주세요.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  btnText: '확인',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _handleConfirm(context),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 확인 버튼 클릭 처리
  void _handleConfirm(BuildContext context) {
    CustomNavigationUtil.back(context);
  }
}
