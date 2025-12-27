import 'package:shoes_store_basic_app/view/cheng/widgets/admin/base_order_card.dart';

/// 반품 관리용 반품 주문 카드 위젯
class ReturnOrderCard extends BaseOrderCard {
  const ReturnOrderCard({
    super.key,
    required super.orderId,
    required super.customerName,
    required super.orderStatus,
    required super.isSelected,
    required super.onTap,
  });
}

