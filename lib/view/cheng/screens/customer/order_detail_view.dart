import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase_item.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';
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

/// 고객용 주문 상세 화면
/// 모바일 세로 화면에 최적화된 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록, 총 가격, 픽업 완료 버튼을 포함합니다.
class OrderDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const OrderDetailView({super.key, required this.purchaseId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
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

  /// 픽업 완료 여부
  bool _isPickupCompleted = false;

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

  /// DB에서 주문 상세 정보를 불러오는 함수
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserStorage.getUserId();
      if (userId == null) {
        AppLogger.w('사용자 정보가 없습니다.');
        CustomNavigationUtil.back(context);
        return;
      }

      AppLogger.d('=== 주문 상세 조회 시작 ===');
      AppLogger.d('주문 ID (Purchase id): ${widget.purchaseId}');

      /// 주문 정보 조회
      final purchase = await _purchaseHandler.queryById(widget.purchaseId);
      if (purchase == null) {
        AppLogger.w('주문을 찾을 수 없습니다: ${widget.purchaseId}');
        CustomSnackBar.showError(context, message: '주문을 찾을 수 없습니다.');
        CustomNavigationUtil.back(context);
        return;
      }

      /// 현재 사용자(Customer id)의 주문인지 확인
      if (purchase.cid != userId) {
        AppLogger.w(
          '권한이 없습니다. 주문 소유자(cid): ${purchase.cid}, 현재 사용자(cid): $userId',
        );
        CustomSnackBar.showError(context, message: '권한이 없습니다.');
        CustomNavigationUtil.back(context);
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

      /// 주문 상품 목록 조회
      if (purchase.id != null) {
        final purchaseItems = await _purchaseItemHandler.queryByPurchaseId(
          purchase.id!,
        );
        AppLogger.d('=== PurchaseItem 조회 결과 ===');
        AppLogger.d('조회된 PurchaseItem 개수: ${purchaseItems.length}');

        // PurchaseItem ID 중복 확인
        final itemIdSet = <int>{};
        final duplicateIds = <int>[];
        for (final item in purchaseItems) {
          if (item.id != null) {
            if (itemIdSet.contains(item.id)) {
              duplicateIds.add(item.id!);
              AppLogger.w('중복된 PurchaseItem ID 발견: ${item.id}');
            } else {
              itemIdSet.add(item.id!);
            }
          }
        }

        if (duplicateIds.isNotEmpty) {
          AppLogger.w('중복된 PurchaseItem ID 목록: $duplicateIds');
        }

        // 상품 정보 조회 및 조합
        // 같은 제품(pid, size, color)은 수량을 합쳐서 하나의 카드로 표시
        final orderItemsMap =
            <String, OrderItemInfo>{}; // key: "pid_size_color"
        final processedItemIds = <int>{}; // 중복 확인용 (PurchaseItem ID 기준)

        for (var i = 0; i < purchaseItems.length; i++) {
          final item = purchaseItems[i];

          // 중복 확인 (같은 PurchaseItem ID가 이미 처리되었는지)
          if (item.id != null && processedItemIds.contains(item.id)) {
            AppLogger.w('중복된 PurchaseItem 발견: ID=${item.id}, 건너뜀');
            continue;
          }

          if (item.id != null) {
            processedItemIds.add(item.id!);
          }

          AppLogger.d(
            'PurchaseItem[$i] 처리: id=${item.id}, pid=${item.pid}, pcid=${item.pcid}, quantity=${item.pcQuantity}, status=${item.pcStatus}',
          );

          try {
            /// Product + ProductBase 조인 조회 (최적화)
            final productWithBase = await _productHandler.queryWithBase(
              item.pid,
            );
            if (productWithBase == null) {
              AppLogger.w('Product를 찾을 수 없음: pid=${item.pid}');
              continue;
            }

            /// 같은 제품(pid, size, color)을 구분하는 키 생성
            final size = productWithBase['size'] as int? ?? 0;
            final color = productWithBase['pColor'] as String? ?? '';
            final itemKey = '${item.pid}_${size}_$color';

            if (orderItemsMap.containsKey(itemKey)) {
              final existingItem = orderItemsMap[itemKey]!;
              final updatedItem = OrderItemInfo(
                productName: existingItem.productName,
                size: existingItem.size,
                color: existingItem.color,
                quantity: existingItem.quantity + item.pcQuantity,
                price: existingItem.price,
              );
              orderItemsMap[itemKey] = updatedItem;
              AppLogger.d(
                '기존 OrderItem 수량 합산: ${existingItem.productName}, 기존 수량=${existingItem.quantity}, 추가 수량=${item.pcQuantity}, 총 수량=${updatedItem.quantity}',
              );
            } else {
              final productName = productWithBase['pName'] as String? ?? '';
              final basePrice = productWithBase['basePrice'] as int? ?? 0;
              final orderItem = OrderItemInfo(
                productName: productName,
                size: size,
                color: color,
                quantity: item.pcQuantity,
                price: basePrice,
              );
              orderItemsMap[itemKey] = orderItem;
              AppLogger.d(
                'OrderItem 추가: ${orderItem.productName}, 사이즈=${orderItem.size}, 색상=${orderItem.color}, 수량=${orderItem.quantity}, 가격=${orderItem.price}',
              );
            }
          } catch (e) {
            AppLogger.e('상품 정보 조회 실패 (pid: ${item.pid})', error: e);
          }
        }

        final orderItemsList = orderItemsMap.values.toList();

        AppLogger.d('=== 최종 결과 ===');
        AppLogger.d('PurchaseItem 개수: ${purchaseItems.length}');
        AppLogger.d('OrderItem 개수: ${orderItemsList.length}');
        AppLogger.d('처리된 PurchaseItem ID: $processedItemIds');

        /// 픽업 완료 여부 결정 (status 2 이상이면 완료)
        final allCompleted = purchaseItems.every((item) {
          final statusNum = OrderStatusUtils.parseStatusToNumber(item.pcStatus);
          return statusNum >= 2;
        });

        /// 주문 상태 결정 (공용 유틸리티 사용)
        final orderStatus = OrderStatusUtils.determineOrderStatusForCustomer(
          purchaseItems,
          purchase,
        );

        AppLogger.d('주문 상태: $orderStatus, 픽업 완료 여부: $allCompleted');

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _isPickupCompleted = allCompleted;
          _orderStatus = orderStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('주문 상세 로드 실패', error: e, stackTrace: stackTrace);
      CustomSnackBar.showError(context, message: '주문 정보를 불러올 수 없습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 픽업 완료 처리
  Future<void> _handlePickupComplete() async {
    if (_purchase?.id == null) {
      return;
    }

    try {
      final purchaseItems = await _purchaseItemHandler.queryByPurchaseId(
        _purchase!.id!,
      );
      final completeStatus = config.pickupStatus[2]!; // '제품 수령 완료'

      for (final item in purchaseItems) {
        if (item.id != null) {
          final updatedItem = PurchaseItem(
            id: item.id,
            pid: item.pid,
            pcid: item.pcid,
            pcQuantity: item.pcQuantity,
            pcStatus: completeStatus,
          );
          await _purchaseItemHandler.updateData(updatedItem);
          AppLogger.d(
            'PurchaseItem ID ${item.id} 업데이트 완료: pcStatus = $completeStatus',
          );
        }
      }

      // 상태 업데이트
      setState(() {
        _isPickupCompleted = true;
        _orderStatus = completeStatus;
      });

      CustomSnackBar.showSuccess(context, message: '픽업이 완료되었습니다.');

      // 이전 페이지로 돌아가기 (result를 true로 전달하여 리스트 페이지에서 갱신하도록 함)
      CustomNavigationUtil.back(context, result: true);
    } catch (e, stackTrace) {
      AppLogger.e('픽업 완료 처리 실패', error: e, stackTrace: stackTrace);
      CustomSnackBar.showError(context, message: '픽업 완료 처리에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: CustomAppBar(
          title: '주문 상세',
          centerTitle: true,
          titleTextStyle: config.boldLabelStyle,
          backgroundColor: p.background,
          foregroundColor: p.textPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_purchase == null || _customer == null) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: CustomAppBar(
          title: '주문 상세',
          centerTitle: true,
          titleTextStyle: config.boldLabelStyle,
          backgroundColor: p.background,
          foregroundColor: p.textPrimary,
        ),
        body: const Center(child: Text('주문 정보를 불러올 수 없습니다.')),
      );
    }

    // 주문 상품들의 총 가격 계산
    final totalPrice = _orderItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: '주문 상세',
        centerTitle: true,
        titleTextStyle: config.boldLabelStyle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: config.screenPadding,
            child: CustomColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: config.defaultSpacing,
              children: [
                // 주문 ID 표시
                CustomCard(
                  padding: config.screenPadding,
                  child: CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        '주문번호: ${_purchase?.orderCode ?? widget.purchaseId.toString()}',
                        style: config.mediumTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 주문 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrderStatusColors.getStatusColor(_orderStatus),
                          borderRadius: config.defaultBorderRadius,
                        ),
                        child: CustomText(
                          _orderStatus,
                          style: config.smallTextStyle,
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
                CustomText('주문 상품', style: config.titleStyle),

                // 주문 상품 리스트 (각 상품을 카드로 표시)
                if (_orderItems.isEmpty)
                  CustomText(
                    '주문 상품이 없습니다.',
                    style: config.bodyTextStyle,
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
                            style: config.mediumTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 상품 정보 (사이즈, 색상, 수량)
                          CustomRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                '사이즈: ${item.size} | 색상: ${item.color} | 수량: ${item.quantity}',
                                style: config.bodyTextStyle,
                                color: p.textSecondary,
                              ),
                              CustomText(
                                '${OrderUtils.formatPrice(item.price * item.quantity)}원',
                                style: config.bodyTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: p.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                // 총 가격 표시 카드
                CustomCard(
                  padding: config.screenPadding,
                  child: CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        '총 주문 금액',
                        style: config.mediumTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomText(
                        '${OrderUtils.formatPrice(totalPrice)}원',
                        style: config.titleStyle,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),

                // 상태별 버튼 표시
                // 제품 준비 완료 상태이고 아직 픽업 완료되지 않은 경우에만 활성화
                if (!_isPickupCompleted &&
                    _orderStatus == config.pickupStatus[1]!) // '제품 준비 완료'
                  // 활성화된 픽업 완료 버튼
                  CustomButton(
                    btnText: '픽업 완료',
                    buttonType: ButtonType.elevated,
                    onCallBack: _handlePickupComplete,
                    minimumSize: const Size(double.infinity, 50),
                  )
                else
                  // 비활성화된 버튼 (상태에 따라 텍스트 변경)
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
                          _orderStatus, // 현재 주문 상태를 버튼 텍스트로 표시
                          style: config.mediumTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
