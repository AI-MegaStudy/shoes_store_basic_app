import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/utils/order_utils.dart';
import 'package:shoes_store_basic_app/utils/order_status_colors.dart';

/// 고객용 주문 카드 위젯
/// 고객용 주문 목록 화면에서 사용하는 주문 카드입니다.
/// 모바일 세로 화면에 최적화되어 있으며, 선택 상태는 필요 없습니다.
class CustomerOrderCard extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;
  /// 주문 상태 (예: 대기중, 준비완료, 픽업완료 등)
  final String orderStatus;
  /// 주문 날짜 (선택사항)
  final String? orderDate;
  /// 총 주문 금액 (선택사항)
  final int? totalPrice;

  const CustomerOrderCard({
    super.key,
    required this.orderId,
    required this.orderStatus,
    this.orderDate,
    this.totalPrice,
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
          // 주문 ID와 상태를 한 줄에 표시
          CustomRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 주문 ID (굵은 글씨)
              CustomText(
                orderId,
                style: config.mediumTextStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              // 주문 상태 (배지 형태로 표시)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OrderStatusColors.getStatusColor(orderStatus),
                  borderRadius: config.defaultBorderRadius,
                ),
                child: CustomText(
                  orderStatus,
                  style: config.smallTextStyle.copyWith(color: p.textOnPrimary),
                ),
              ),
            ],
          ),
          // 주문 날짜 표시 (있는 경우)
          if (orderDate != null)
            CustomText(
              '주문일: $orderDate',
              style: config.smallTextStyle.copyWith(color: p.textSecondary),
            ),
          // 총 주문 금액 표시 (있는 경우)
          if (totalPrice != null)
            CustomText(
              '총 금액: ${OrderUtils.formatPrice(totalPrice!)}원',
              style: config.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
              color: p.primary,
            ),
        ],
      ),
    );
  }

}

