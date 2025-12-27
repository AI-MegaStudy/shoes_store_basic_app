import 'package:flutter/material.dart';
import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';

/// 주문자 상세 정보 카드 위젯
/// 주문 관리와 반품 관리 화면에서 공통으로 사용하는 주문자 정보 표시 카드입니다.
/// 주문자 이름, 연락처, 이메일을 카드 형태로 표시합니다.
class CustomerInfoCard extends StatelessWidget {
  /// 주문자 이름
  final String name;
  /// 주문자 연락처 (전화번호)
  final String phone;
  /// 주문자 이메일 주소
  final String email;

  const CustomerInfoCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: CustomColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: config.mediumSpacing,
        children: [
          // 카드 제목
          CustomText(
            '주문자 상세 정보',
            style: config.titleStyle,
          ),
          // 주문자 이름 표시
          CustomText(
            '이름 : $name',
            style: config.bodyTextStyle,
          ),
          // 주문자 연락처 표시
          CustomText(
            '연락처: $phone',
            style: config.bodyTextStyle,
          ),
          // 주문자 이메일 표시
          CustomText(
            '이메일: $email',
            style: config.bodyTextStyle,
          ),
        ],
      ),
    );
  }
}

