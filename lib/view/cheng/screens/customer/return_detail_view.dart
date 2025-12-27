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

/// 주문 상품 정보를 담는 클래스 (반품 상세용)
class ReturnItemInfo {
  final String productName;
  final int size;
  final String color;
  final int quantity;
  final int price;
  final int pid; // Product ID (같은 제품의 모든 PurchaseItem 찾기용)
  final String returnStatus; // 반품 상태 (pcStatus 기반)
  final List<int> purchaseItemIds; // 같은 제품의 모든 PurchaseItem ID 목록
  final String actualPcStatus; // 실제 pcStatus 값 (버튼 활성화 판단용)

  ReturnItemInfo({
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    required this.pid,
    required this.returnStatus,
    required this.purchaseItemIds,
    required this.actualPcStatus,
  });
}

/// 고객용 수령 완료 상세 화면
/// 모바일 세로 화면에 최적화된 수령 완료 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록을 포함하며, 각 상품별로 반품 버튼이 있습니다.
class ReturnDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const ReturnDetailView({super.key, required this.purchaseId});

  @override
  State<ReturnDetailView> createState() => _ReturnDetailViewState();
}

class _ReturnDetailViewState extends State<ReturnDetailView> {
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

      AppLogger.d('=== 반품 상세 조회 시작 ===');
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
            <String, ReturnItemInfo>{}; // key: "pid_size_color"
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

            // 반품 상태 결정 (pcStatus 기반)
            final statusNum = OrderStatusUtils.parseStatusToNumber(
              item.pcStatus,
            );
            String returnStatusText;
            if (statusNum >= 3) {
              // 반품 신청 이상 (3, 4, 5) - parseStatusToNumber가 0~5만 반환하므로 null 체크 불필요
              returnStatusText = config.pickupStatus[statusNum]!;
            } else {
              // 반품 신청 가능 (2: 제품 수령 완료)
              returnStatusText = config.pickupStatus[3]!; // '반품 신청'
            }

            // 실제 pcStatus 값 저장 (버튼 활성화 판단용)
            final actualPcStatus = item.pcStatus;

            // 같은 제품(pid, size, color)을 구분하는 키 생성
            final size = productWithBase['size'] as int? ?? 0;
            final color = productWithBase['pColor'] as String? ?? '';
            final itemKey = '${item.pid}_${size}_$color';

            if (orderItemsMap.containsKey(itemKey)) {
              // 이미 같은 제품이 있으면 수량만 합산
              final existingItem = orderItemsMap[itemKey]!;
              // 같은 제품이 여러 PurchaseItem으로 나뉘어 있을 수 있으므로
              // 가장 높은 반품 상태를 유지 (반품 완료 > 반품 처리 중 > 반품 신청)
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

              // PurchaseItem ID 추가
              final updatedPurchaseItemIds = List<int>.from(
                existingItem.purchaseItemIds,
              );
              if (item.id != null) {
                updatedPurchaseItemIds.add(item.id!);
              }

              // 가장 높은 상태의 실제 pcStatus 유지
              final higherActualPcStatus = existingStatusNum > currentStatusNum
                  ? existingItem.actualPcStatus
                  : item.pcStatus;

              final updatedItem = ReturnItemInfo(
                productName: existingItem.productName,
                size: existingItem.size,
                color: existingItem.color,
                quantity: existingItem.quantity + item.pcQuantity, // 수량 합산
                price: existingItem.price,
                pid: existingItem.pid, // Product ID 유지
                returnStatus: higherStatusText,
                purchaseItemIds: updatedPurchaseItemIds,
                actualPcStatus: higherActualPcStatus,
              );
              orderItemsMap[itemKey] = updatedItem;
              AppLogger.d(
                '기존 ReturnItem 수량 합산: ${existingItem.productName}, 기존 수량=${existingItem.quantity}, 추가 수량=${item.pcQuantity}, 총 수량=${updatedItem.quantity}',
              );
            } else {
              // 새로운 제품이면 추가
              final purchaseItemIdsList = <int>[];
              if (item.id != null) {
                purchaseItemIdsList.add(item.id!);
              }
              final productName = productWithBase['pName'] as String? ?? '';
              final basePrice = productWithBase['basePrice'] as int? ?? 0;
              final returnItem = ReturnItemInfo(
                productName: productName,
                size: size,
                color: color,
                quantity: item.pcQuantity,
                price: basePrice,
                pid: item.pid, // Product ID 저장
                returnStatus: returnStatusText,
                purchaseItemIds: purchaseItemIdsList,
                actualPcStatus: actualPcStatus,
              );
              orderItemsMap[itemKey] = returnItem;
              AppLogger.d(
                'ReturnItem 추가: ${returnItem.productName}, 사이즈=${returnItem.size}, 색상=${returnItem.color}, 수량=${returnItem.quantity}, 가격=${returnItem.price}, 반품상태=${returnItem.returnStatus}',
              );
            }
          } catch (e) {
            AppLogger.e('상품 정보 조회 실패 (pid: ${item.pid})', error: e);
          }
        }

        // Map을 List로 변환
        final orderItemsList = orderItemsMap.values.toList();

        AppLogger.d('=== 최종 결과 ===');
        AppLogger.d('PurchaseItem 개수: ${purchaseItems.length}');
        AppLogger.d('ReturnItem 개수: ${orderItemsList.length}');
        AppLogger.d('처리된 PurchaseItem ID: $processedItemIds');

        // 반품 가능 여부 결정
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
      CustomSnackBar.showError(context, message: '주문 정보를 불러올 수 없습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: CustomAppBar(
          title: Text('반품 상세', style: config.boldLabelStyle),
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
          title: Text('반품 상세', style: config.boldLabelStyle),
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
        title: Text('반품 상세', style: config.boldLabelStyle),
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
                // 주문 ID 표시 및 반품 상태
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
                      // 반품 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrderStatusColors.getStatusColor(
                            _returnStatus,
                          ),
                          borderRadius: config.defaultBorderRadius,
                        ),
                        child: CustomText(
                          _returnStatus,
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

                // 주문 상품 리스트 (각 상품을 카드로 표시, 반품 버튼 포함)
                if (_orderItems.isEmpty)
                  CustomText(
                    '주문 상품이 없습니다.',
                    style: config.bodyTextStyle,
                    textAlign: TextAlign.center,
                  )
                else
                  ..._orderItems.map((item) {
                    // 실제 pcStatus를 기반으로 반품 상태 확인
                    final statusNum = OrderStatusUtils.parseStatusToNumber(
                      item.actualPcStatus,
                    );
                    final isReturnCompleted = statusNum == 5; // 반품 완료
                    // 반품 완료(5)일 때만 pickupStatus[5] 사용, 그 외에는 '반품 신청' 텍스트 사용
                    final returnStatusText = isReturnCompleted
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

                    // 버튼 활성화 여부:
                    // - 반품 완료(5)가 아니고
                    // - 30일이 지나지 않았고
                    // - 제품 수령 완료(2) 이상인 경우
                    final isButtonEnabled =
                        !isReturnCompleted && !is30DaysPassed && statusNum >= 2;

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
                              Expanded(
                                child: CustomText(
                                  '사이즈: ${item.size} | 색상: ${item.color} | 수량: ${item.quantity}',
                                  style: config.bodyTextStyle.copyWith(
                                    color: p.textSecondary,
                                  ),
                                ),
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
                          // 반품 버튼
                          // 30일 경과 또는 반품 완료인 경우 회색으로 표시
                          if (isButtonEnabled)
                            // 활성화된 버튼 (반품 가능)
                            CustomButton(
                              btnText: returnStatusText,
                              buttonType: ButtonType.elevated,
                              backgroundColor: p.accent, // 반품 신청 가능: 빨간색
                              onCallBack: () => _showReturnConfirmDialog(item),
                              minimumSize: const Size(double.infinity, 40),
                            )
                          else
                            // 비활성화된 버튼 (반품 완료 또는 30일 경과) - 회색으로 표시
                            IgnorePointer(
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: p.divider,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: CustomText(
                                    returnStatusText,
                                    style: config.bodyTextStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: p.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                // 총 주문 금액 표시 카드
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 반품 확인 다이얼로그 표시
  Future<void> _showReturnConfirmDialog(ReturnItemInfo item) async {
    await CustomDialog.show(
      context,
      title: '반품 확인',
      message: '${item.productName}\n정말 반품 하시겠습니까?',
      type: DialogType.dual,
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () async {
        await _handleReturnComplete(item);
      },
      onCancel: () {
        // 취소 시 아무 작업도 하지 않음
      },
    );
  }

  /// 반품 완료 처리 함수
  /// 같은 제품(pid, size, color)의 모든 PurchaseItem의 pcStatus를 반품 완료(5)로 업데이트하고,
  /// Purchase의 pickupDate를 오늘 날짜 +1로 업데이트합니다.
  Future<void> _handleReturnComplete(ReturnItemInfo item) async {
    if (_purchase?.id == null) {
      AppLogger.w('주문 정보가 없습니다.');
      return;
    }

    try {
      // 반품 완료 상태로 업데이트
      final returnCompleteStatus = config.pickupStatus[5]!; // '반품 완료'

      /// 같은 제품의 모든 PurchaseItem을 반품 완료로 업데이트
      for (final purchaseItemId in item.purchaseItemIds) {
        final purchaseItem = await _purchaseItemHandler.queryById(
          purchaseItemId,
        );
        if (purchaseItem != null) {
          final updatedItem = PurchaseItem(
            id: purchaseItem.id,
            pid: purchaseItem.pid,
            pcid: purchaseItem.pcid,
            pcQuantity: purchaseItem.pcQuantity,
            pcStatus: returnCompleteStatus,
          );
          await _purchaseItemHandler.updateData(updatedItem);
          AppLogger.d(
            'PurchaseItem ID $purchaseItemId 업데이트 완료: pcStatus = $returnCompleteStatus',
          );
        }
      }

      /// Purchase의 pickupDate를 오늘 날짜 +1로 업데이트
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowString = tomorrow.toIso8601String().split('T').first;

      if (_purchase!.id != null) {
        final updatedPurchase = Purchase(
          id: _purchase!.id,
          cid: _purchase!.cid,
          pickupDate: tomorrowString,
          orderCode: _purchase!.orderCode,
          timeStamp: _purchase!.timeStamp,
        );
        await _purchaseHandler.updateData(updatedPurchase);
        AppLogger.d(
          'Purchase ID ${_purchase!.id} pickupDate 업데이트 완료: $tomorrowString',
        );
      }

      /// Purchase 정보 다시 로드
      if (_purchase!.id != null) {
        _purchase = await _purchaseHandler.queryById(_purchase!.id!);
      }

      /// PurchaseItem 정보 다시 로드하여 반품 상태 재계산
      if (_purchase?.id != null) {
        final updatedPurchaseItems = await _purchaseItemHandler
            .queryByPurchaseId(_purchase!.id!);

        /// 반품 가능 여부 재계산
        final updatedReturnStatus = OrderStatusUtils.determineReturnStatus(
          updatedPurchaseItems,
          _purchase!,
        );

        /// 상태 업데이트
        setState(() {
          final index = _orderItems.indexWhere(
            (i) =>
                i.pid == item.pid &&
                i.size == item.size &&
                i.color == item.color,
          );
          if (index != -1) {
            _orderItems[index] = ReturnItemInfo(
              productName: item.productName,
              size: item.size,
              color: item.color,
              quantity: item.quantity,
              price: item.price,
              pid: item.pid,
              returnStatus: returnCompleteStatus,
              purchaseItemIds: item.purchaseItemIds,
              actualPcStatus: returnCompleteStatus, // 실제 pcStatus도 업데이트
            );
          }

          /// 상단 반품 상태 표시 갱신
          _returnStatus = updatedReturnStatus;
        });
      }

      /// 스낵바로 알림 표시
      CustomSnackBar.showSuccess(
        context,
        message: '${item.productName}의 반품이 완료되었습니다.',
      );
    } catch (e, stackTrace) {
      AppLogger.e('반품 완료 처리 실패', error: e, stackTrace: stackTrace);
      CustomSnackBar.showError(context, message: '반품 완료 처리에 실패했습니다.');
    }
  }
}
