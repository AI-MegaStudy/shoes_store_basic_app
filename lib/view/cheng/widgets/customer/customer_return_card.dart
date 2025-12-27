import 'package:flutter/material.dart';
import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';

/// 고객용 수령 완료 카드 위젯
/// 고객용 수령 완료 목록 화면에서 사용하는 주문 카드입니다.
/// 모바일 세로 화면에 최적화되어 있으며, 선택 상태는 필요 없습니다.
class CustomerReturnCard extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;
  /// 주문 날짜 (선택사항)
  final String? orderDate;

  const CustomerReturnCard({
    super.key,
    required this.orderId,
    this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: config.screenPadding,
      child: CustomColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: config.smallSpacing,
        children: [
          // 주문 ID 표시
          CustomText(
            orderId,
            style: config.mediumTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          // 주문 날짜 표시 (있는 경우)
          if (orderDate != null)
            CustomText(
              '수령일: $orderDate',
              style: config.smallTextStyle,
              color: p.textSecondary,
            ),
        ],
      ),
    );
  }

}

