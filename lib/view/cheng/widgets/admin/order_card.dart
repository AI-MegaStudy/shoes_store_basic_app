import 'package:shoes_store_basic_app/view/cheng/widgets/admin/base_order_card.dart';

/// 주문 관리용 주문 카드 위젯
class OrderCard extends BaseOrderCard {
  const OrderCard({
    super.key,
    required super.orderId,
    required super.customerName,
    required super.orderStatus,
    required super.isSelected,
    required super.onTap,
  });
}

