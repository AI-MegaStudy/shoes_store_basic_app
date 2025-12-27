import 'package:flutter/material.dart';
import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/utils/order_status_colors.dart';

/// 주문 카드 기본 위젯
/// 주문 관리와 반품 관리 화면에서 공통으로 사용하는 카드 구조를 제공하는 베이스 클래스입니다.
/// 이 클래스를 상속받아 주문 카드(OrderCard)와 반품 카드(ReturnOrderCard)를 구현합니다.
class BaseOrderCard extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;
  /// 고객 이름
  final String customerName;
  /// 주문 상태 (예: 대기중, 준비완료, 반품요청 등)
  final String orderStatus;
  /// 현재 카드가 선택된 상태인지 여부
  final bool isSelected;
  /// 카드 클릭 시 실행될 콜백 함수
  final VoidCallback onTap;

  const BaseOrderCard({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.orderStatus,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return GestureDetector(
      // 카드 전체를 탭 가능하게 만듦
      onTap: onTap,
      child: CustomCard(
        // 선택된 상태일 때 배경색 변경
        color: isSelected ? p.chipSelectedBg.withOpacity(0.2) : null,
        margin: const EdgeInsets.only(bottom: 8),
        padding: config.mediumPadding,
        child: CustomColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: config.smallSpacing,
          children: [
            // 주문 ID와 상태를 한 줄에 표시
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 주문 ID (굵은 글씨)
                CustomText(orderId, style: config.bodyTextStyle.copyWith(fontWeight: FontWeight.bold)),
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
            // 고객 이름 표시
            CustomText(
              customerName,
              style: config.bodyTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

