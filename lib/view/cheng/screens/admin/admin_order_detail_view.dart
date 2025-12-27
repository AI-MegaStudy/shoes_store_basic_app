import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/utils/order_status_colors.dart';
import 'package:shoes_store_basic_app/utils/order_status_utils.dart';
import 'package:shoes_store_basic_app/utils/order_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/widgets/customer/customer_info_card.dart';

/// 주문 상품 정보를 담는 클래스
class OrderItemInfo {
  final String productName;
  final int size;
  final String color;
  final int quantity;
  final int price;

  OrderItemInfo({
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });
}

/// 관리자용 주문 상세 정보 뷰
/// 주문 관리 화면의 우측에 표시되는 주문 상세 정보를 보여주는 위젯입니다.
/// 읽기 전용으로, 버튼은 비활성화되어 있습니다.
class AdminOrderDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const AdminOrderDetailView({super.key, required this.purchaseId});

  @override
  State<AdminOrderDetailView> createState() => _AdminOrderDetailViewState();
}

class _AdminOrderDetailViewState extends State<AdminOrderDetailView> {
  /// 로딩 상태
  bool _isLoading = true;

  /// 주문 정보
  Purchase? _purchase;

  /// 고객 정보
  Customer? _customer;

  /// 주문 상품 목록
  List<OrderItemInfo> _orderItems = [];

  /// 주문 상태
  String _orderStatus = '';

  /// 주문 핸들러
  final PurchaseHandler _purchaseHandler = PurchaseHandler();

  /// 주문 항목 핸들러
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();

  /// 고객 핸들러
  final CustomerHandler _customerHandler = CustomerHandler();

  /// 제품 핸들러
  final ProductHandler _productHandler = ProductHandler();

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  @override
  void didUpdateWidget(AdminOrderDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.purchaseId != widget.purchaseId) {
      _loadOrderDetail();
    }
  }

  /// 주문 상세 정보 불러오기
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.d('=== 관리자 주문 상세 조회 시작 ===');
      AppLogger.d('주문 ID (Purchase id): ${widget.purchaseId}');

      /// 주문 정보 조회
      final purchase = await _purchaseHandler.queryById(widget.purchaseId);
      if (purchase == null) {
        AppLogger.w('주문을 찾을 수 없습니다: ${widget.purchaseId}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      AppLogger.d(
        '주문 조회 성공: id=${purchase.id}, cid=${purchase.cid}, orderCode=${purchase.orderCode}',
      );

      /// 고객 정보 조회
      if (purchase.cid != null) {
        try {
          _customer = await _customerHandler.queryById(purchase.cid!);
        } catch (e) {
          AppLogger.e('고객 정보 조회 실패', error: e);
        }
      }

      /// 주문 상품 목록 조회 및 조합
      if (purchase.id != null) {
        final purchaseItems = await _purchaseItemHandler.queryByPurchaseId(
          purchase.id!,
        );
        AppLogger.d('조회된 PurchaseItem 개수: ${purchaseItems.length}');

        /// 같은 제품(pid, size, color)은 수량을 합쳐서 하나의 카드로 표시
        final orderItemsMap = <String, OrderItemInfo>{};
        final processedItemIds = <int>{};

        for (final item in purchaseItems) {
          if (item.id != null && processedItemIds.contains(item.id!)) {
            continue;
          }

          if (item.id != null) {
            processedItemIds.add(item.id!);
          }

          try {
            /// Product + ProductBase 조인 조회 (최적화)
            final productWithBase = await _productHandler.queryWithBase(
              item.pid,
            );
            if (productWithBase == null) {
              AppLogger.w('Product를 찾을 수 없음: pid=${item.pid}');
              continue;
            }

            /// 같은 제품 구분 키
            final size = productWithBase['size'] as int? ?? 0;
            final color = productWithBase['pColor'] as String? ?? '';
            final itemKey = '${item.pid}_${size}_$color';

            if (orderItemsMap.containsKey(itemKey)) {
              /// 수량 합산
              final existingItem = orderItemsMap[itemKey]!;
              orderItemsMap[itemKey] = OrderItemInfo(
                productName: existingItem.productName,
                size: existingItem.size,
                color: existingItem.color,
                quantity: existingItem.quantity + item.pcQuantity,
                price: existingItem.price,
              );
            } else {
              /// 새 제품 추가
              final productName = productWithBase['pName'] as String? ?? '';
              final basePrice = productWithBase['basePrice'] as int? ?? 0;
              orderItemsMap[itemKey] = OrderItemInfo(
                productName: productName,
                size: size,
                color: color,
                quantity: item.pcQuantity,
                price: basePrice,
              );
            }
          } catch (e) {
            AppLogger.e('상품 정보 조회 실패 (pid: ${item.pid})', error: e);
          }
        }

        final orderItemsList = orderItemsMap.values.toList();
        // 주문 관리 화면의 디테일도 목록과 동일하게 반품 상태 무시
        final orderStatus =
            OrderStatusUtils.determineOrderStatusForOrderManagement(
              purchaseItems,
              purchase,
            );

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _orderStatus = orderStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('주문 상세 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// PurchaseItem 목록을 기반으로 주문 전체 상태를 결정하는 함수

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_purchase == null || _customer == null) {
      return const Center(child: Text('주문 정보를 불러올 수 없습니다.'));
    }

    // 주문 상품들의 총 가격 계산
    final totalPrice = _orderItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // 상태에 따라 버튼 텍스트 결정
    // 관리자 화면은 읽기 전용이므로 상태에 맞는 텍스트를 표시
    // 제품 준비 완료 상태일 때만 "픽업 준비 완료", 그 외에는 현재 상태 표시
    String buttonText;
    final statusNum = OrderStatusUtils.parseStatusToNumber(_orderStatus);
    if (statusNum == 1) {
      // 제품 준비 완료 상태: 픽업 준비 완료 버튼 (비활성화) - 관리자 관점
      buttonText = '픽업 준비 완료';
    } else {
      // 그 외 상태: 현재 상태 텍스트 표시 (제품 수령 완료, 제품 준비 중, 반품 신청 등)
      buttonText = _orderStatus;
    }

    AppLogger.d(
      '버튼 텍스트 결정: orderStatus="$_orderStatus", statusNum=$statusNum, buttonText="$buttonText"',
    );

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // 주문 ID 및 상태 표시
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: CustomRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                '주문번호: ${_purchase?.orderCode ?? widget.purchaseId.toString()}',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // 주문 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OrderStatusColors.getStatusColor(_orderStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomText(
                  _orderStatus,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: p.textOnPrimary,
                ),
              ),
            ],
          ),
        ),

        // 주문자 상세 정보 카드
        CustomerInfoCard(
          name: _customer!.cName,
          phone: _customer!.cPhoneNumber,
          email: _customer!.cEmail,
        ),

        // 주문 상품들 제목
        CustomText('주문 상품들', fontSize: 18, fontWeight: FontWeight.bold),

        // 주문 상품 리스트 (각 상품을 카드로 표시)
        if (_orderItems.isEmpty)
          CustomText(
            '주문 상품이 없습니다.',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            textAlign: TextAlign.center,
          )
        else
          ..._orderItems.map((item) {
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: CustomRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 상품명 (가장 넓은 영역)
                  Expanded(
                    flex: 2,
                    child: CustomText(
                      item.productName,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  // 사이즈 표시
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      '${item.size}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 색상 표시
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      item.color,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 수량 표시
                  SizedBox(
                    width: 40,
                    child: CustomText(
                      '${item.quantity}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 가격 표시 (오른쪽 정렬)
                  SizedBox(
                    width: 100,
                    child: CustomText(
                      '${OrderUtils.formatPrice(item.price * item.quantity)}원',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

        // 총 가격 표시 (오른쪽 정렬)
        CustomRow(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              '총 가격: ${OrderUtils.formatPrice(totalPrice)}원',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        // 픽업 완료 버튼 (읽기 전용 - 비활성화)
        IgnorePointer(
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: p.divider,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: CustomText(
                buttonText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: p.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
