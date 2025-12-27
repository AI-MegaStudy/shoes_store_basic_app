import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
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

/// 반품 주문 상품 정보를 담는 클래스
class ReturnItemInfo {
  final String productName;
  final int size;
  final String color;
  final int quantity;
  final int price;
  final String returnStatus; // 반품 상태 (pcStatus 기반)

  ReturnItemInfo({
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    required this.returnStatus,
  });
}

/// 관리자용 반품 주문 상세 정보 화면
/// 반품 관리 화면의 우측에 표시되는 반품 주문 상세 정보를 보여주는 화면입니다.
/// 주문자 정보, 반품 상품 목록을 포함합니다. (읽기 전용)
class AdminReturnOrderDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const AdminReturnOrderDetailView({super.key, required this.purchaseId});

  @override
  State<AdminReturnOrderDetailView> createState() =>
      _AdminReturnOrderDetailViewState();
}

class _AdminReturnOrderDetailViewState
    extends State<AdminReturnOrderDetailView> {
  /// 로딩 상태
  bool _isLoading = true;

  /// 주문 정보
  Purchase? _purchase;

  /// 고객 정보
  Customer? _customer;

  /// 주문 상품 목록
  List<ReturnItemInfo> _orderItems = [];

  /// 반품 상태 (반품 가능 / 반품 불가)
  String _returnStatus = '반품 불가';

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
  void didUpdateWidget(AdminReturnOrderDetailView oldWidget) {
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
      AppLogger.d('=== 관리자 반품 상세 조회 시작 ===');
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
        final orderItemsMap = <String, ReturnItemInfo>{};
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

            /// 반품 상태 결정 (pcStatus 기반)
            final statusNum = OrderStatusUtils.parseStatusToNumber(
              item.pcStatus,
            );
            String returnStatusText;
            if (statusNum >= 3) {
              // parseStatusToNumber가 0~5만 반환하므로 null 체크 불필요
              returnStatusText = config.pickupStatus[statusNum]!;
            } else {
              returnStatusText = config.pickupStatus[3]!; // '반품 신청'
            }

            /// 같은 제품 구분 키
            final size = productWithBase['size'] as int? ?? 0;
            final color = productWithBase['pColor'] as String? ?? '';
            final itemKey = '${item.pid}_${size}_$color';

            if (orderItemsMap.containsKey(itemKey)) {
              /// 수량 합산 및 상태 업데이트
              final existingItem = orderItemsMap[itemKey]!;
              final existingStatusNum = OrderStatusUtils.parseStatusToNumber(
                existingItem.returnStatus,
              );
              final currentStatusNum = OrderStatusUtils.parseStatusToNumber(
                item.pcStatus,
              );
              final higherStatusNum = existingStatusNum > currentStatusNum
                  ? existingStatusNum
                  : currentStatusNum;
              // parseStatusToNumber가 0~5만 반환하므로 null 체크 불필요
              final higherStatusText = higherStatusNum >= 3
                  ? config.pickupStatus[higherStatusNum]!
                  : config.pickupStatus[3]!; // '반품 신청'

              orderItemsMap[itemKey] = ReturnItemInfo(
                productName: existingItem.productName,
                size: existingItem.size,
                color: existingItem.color,
                quantity: existingItem.quantity + item.pcQuantity,
                price: existingItem.price,
                returnStatus: higherStatusText,
              );
            } else {
              /// 새 제품 추가
              final productName = productWithBase['pName'] as String? ?? '';
              final basePrice = productWithBase['basePrice'] as int? ?? 0;
              orderItemsMap[itemKey] = ReturnItemInfo(
                productName: productName,
                size: size,
                color: color,
                quantity: item.pcQuantity,
                price: basePrice,
                returnStatus: returnStatusText,
              );
            }
          } catch (e) {
            AppLogger.e('상품 정보 조회 실패 (pid: ${item.pid})', error: e);
          }
        }

        final orderItemsList = orderItemsMap.values.toList();
        final returnStatus = OrderStatusUtils.determineReturnStatus(
          purchaseItems,
          purchase,
        );

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _returnStatus = returnStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('반품 상세 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_purchase == null || _customer == null) {
      return Center(
        child: CustomText(
          '주문 정보를 불러올 수 없습니다.',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          textAlign: TextAlign.center,
        ),
      );
    }

    // 주문 상품들의 총 가격 계산
    final totalPrice = _orderItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // 주문 ID 표시 및 반품 상태
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
              // 반품 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OrderStatusColors.getStatusColor(_returnStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomText(
                  _returnStatus,
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

        // 반품 상품들 제목
        CustomText('반품 상품들', fontSize: 18, fontWeight: FontWeight.bold),

        // 반품 상품 리스트 (각 상품을 카드로 표시, 읽기 전용)
        if (_orderItems.isEmpty)
          CustomText(
            '반품 상품이 없습니다.',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            textAlign: TextAlign.center,
          )
        else
          ..._orderItems.map((item) {
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: CustomColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  // 상품명
                  CustomText(
                    item.productName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  // 상품 정보 (사이즈, 색상, 수량)
                  CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          '사이즈: ${item.size} | 색상: ${item.color} | 수량: ${item.quantity}',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: p.textSecondary,
                        ),
                      ),
                      // 가격 표시 (오른쪽 정렬)
                      CustomText(
                        '${OrderUtils.formatPrice(item.price * item.quantity)}원',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: p.primary,
                      ),
                    ],
                  ),
                  // 반품 상태 표시 (읽기 전용 - 관리자 화면)
                  // 30일 경과 시 회색으로 표시, 그 외에는 상태에 따른 색상
                  Builder(
                    builder: (context) {
                      // 반품 상태 확인
                      final statusNum = OrderStatusUtils.parseStatusToNumber(
                        item.returnStatus,
                      );
                      final isReturnCompleted = statusNum == 5; // 반품 완료

                      // 상태 텍스트 결정: 반품 완료가 아니면 "반품 신청"
                      final statusText = isReturnCompleted
                          ? config.pickupStatus[5]! // '반품 완료'
                          : config.pickupStatus[3]!; // '반품 신청'

                      // pickupDate로부터 30일 경과 확인
                      bool is30DaysPassed = false;
                      if (_purchase != null) {
                        is30DaysPassed =
                            OrderStatusUtils.isPickupDatePassed30Days(
                              _purchase!,
                              DateTime.now(),
                            );
                      }

                      // 30일 경과 시 회색으로 표시, 그 외에는 상태에 따른 색상
                      final statusColor = (is30DaysPassed && !isReturnCompleted)
                          ? p.divider
                          : OrderStatusColors.getStatusColor(statusText);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomText(
                          statusText,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: p.textOnPrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),

        // 총 주문 금액 표시 카드
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: CustomRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText('총 주문 금액', fontSize: 16, fontWeight: FontWeight.bold),
              CustomText(
                '${OrderUtils.formatPrice(totalPrice)}원',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
