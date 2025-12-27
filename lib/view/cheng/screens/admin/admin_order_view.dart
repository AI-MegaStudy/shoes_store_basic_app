import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/admin_storage.dart';
import 'package:shoes_store_basic_app/utils/admin_tablet_utils.dart';
import 'package:shoes_store_basic_app/utils/order_status_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/widgets/admin/admin_drawer.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_order_detail_view.dart';
import 'package:shoes_store_basic_app/view/cheng/widgets/admin/order_card.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_return_order_view.dart';

/// 관리자/직원 주문 관리 화면
/// 태블릿에서 가로 모드로 강제 표시되는 주문 관리 화면입니다.
/// 좌측에 주문 목록을 표시하고, 우측에 선택된 주문의 상세 정보를 표시합니다.

class AdminOrderView extends StatefulWidget {
  const AdminOrderView({super.key});

  @override
  State<AdminOrderView> createState() => _AdminOrderViewState();
}

class _AdminOrderViewState extends State<AdminOrderView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 현재 선택된 주문 ID (Purchase id)
  /// null이면 우측에 "데이터 없음" 메시지 표시
  int? _selectedOrderId;

  /// 주문 목록 데이터
  List<Purchase> _orders = [];

  /// 주문 상태 맵 (주문 ID -> 상태)
  Map<int, String> _orderStatusMap = {};

  /// 고객 정보 맵 (주문 ID -> 고객명)
  Map<int, String> _customerNameMap = {};

  /// 로딩 상태
  bool _isLoading = true;

  /// 주문 핸들러
  final PurchaseHandler _purchaseHandler = PurchaseHandler();

  /// 주문 항목 핸들러
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();

  /// 검색어에 따라 필터링된 주문 목록 반환
  List<Purchase> get _filteredOrders {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _orders;
    }
    return _orders.where((order) {
      if (order.orderCode.toLowerCase().contains(searchText)) {
        return true;
      }
      final customerName = _customerNameMap[order.id] ?? '';
      if (customerName.toLowerCase().contains(searchText)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    lockTabletLandscape(context);
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    unlockAllOrientations();
    super.dispose();
  }

  /// 모든 주문 목록 불러오기
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.d('=== 관리자 주문 목록 조회 시작 ===');

      /// 모든 주문 조회
      final purchases = await _purchaseHandler.queryAll();
      AppLogger.d('조회된 Purchase 개수: ${purchases.length}');

      /// 시간순으로 정렬 (최신순)
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      /// 각 주문의 상태와 고객명 계산
      final statusMap = <int, String>{};
      final customerNameMap = <int, String>{};

      /// 고객별로 그룹화하여 조회 (최적화)
      final customerIds = purchases
          .where((p) => p.cid != null)
          .map((p) => p.cid!)
          .toSet()
          .toList();

      /// 각 고객별 주문 목록 + 고객 정보 조회 (최적화)
      for (final cid in customerIds) {
        try {
          final purchasesWithCustomer = await _purchaseHandler
              .queryListWithCustomer(cid);
          for (final purchaseMap in purchasesWithCustomer) {
            final purchaseId = purchaseMap['id'] as int?;
            if (purchaseId == null) continue;

            final customerName = purchaseMap['cName'] as String?;
            if (customerName != null) {
              customerNameMap[purchaseId] = customerName;
            }
          }
        } catch (e) {
          AppLogger.e('고객별 주문 조회 실패 (cid: $cid)', error: e);
        }
      }

      /// 각 주문의 상태 계산
      for (final purchase in purchases) {
        if (purchase.id != null) {
          try {
            /// PurchaseItem 조회
            final items = await _purchaseItemHandler.queryByPurchaseId(
              purchase.id!,
            );

            /// 주문 상태 결정 (주문 관리 화면: 반품 상태 무시하고 status 2 이상이면 "제품 수령 완료"로 표시)
            final status =
                OrderStatusUtils.determineOrderStatusForOrderManagement(
                  items,
                  purchase,
                );
            statusMap[purchase.id!] = status;
          } catch (e) {
            AppLogger.e('주문 상태 조회 실패 (ID: ${purchase.id})', error: e);
            statusMap[purchase.id!] = config.pickupStatus[0]!; // '제품 준비 중'
          }
        }
      }

      AppLogger.d('=== 관리자 주문 목록 조회 완료 ===');

      setState(() {
        _orders = purchases;
        _orderStatusMap = statusMap;
        _customerNameMap = customerNameMap;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('주문 목록 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: CustomAppBar(
        title: '관리자',
        centerTitle: true,
        drawerIcon: Icons.menu,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      drawer: AdminDrawer(
        currentMenu: AdminMenuType.orderManagement,
        userName: AdminStorage.getAdminName(),
        userRole: AdminStorage.getAdminRole(),
        menuItems: [
          AdminDrawerMenuItem(
            label: '주문 관리',
            icon: Icons.shopping_cart,
            menuType: AdminMenuType.orderManagement,
            onTap: (_) {
              // 현재 페이지이므로 아무 동작 없음
            },
          ),
          AdminDrawerMenuItem(
            label: '반품 관리',
            icon: Icons.assignment_return,
            menuType: AdminMenuType.returnManagement,
            onTap: (ctx) {
              CustomNavigationUtil.off(ctx, const AdminReturnOrderView());
            },
          ),
        ],
        onProfileEditTap: () async {
          final result = await CustomNavigationUtil.toNamed(
            context,
            config.routeAdminProfileEdit,
          );
          if (result == true) {
            AppLogger.d('관리자 개인정보 수정 완료 - drawer 갱신', tag: 'OrderView');
            setState(() {});
          }
        },
      ),
      body: SafeArea(
        child: CustomRow(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 좌측 1/3: 주문 목록
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: CustomPadding(
                  padding: const EdgeInsets.all(16),
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: config.mediumSpacing,
                    children: [
                      // 검색 필터
                      CustomTextField(
                        controller: _searchController,
                        hintText: '고객명/주문번호 찾기',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: (_) => setState(() {}),
                      ),

                      // 주문 목록 제목
                      CustomText('주문 목록', style: config.titleStyle),

                      // 주문 목록 리스트 표시
                      // 주문이 없으면 안내 메시지 표시, 있으면 주문 카드 리스트 표시
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: config.extraLargeSpacing,
                            ),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_filteredOrders.isEmpty)
                        Center(
                          child: CustomText(
                            '주문이 없습니다.',
                            style: config.bodyTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        // 각 주문을 OrderCard로 표시
                        ..._filteredOrders.map((order) {
                          final orderStatus = order.id != null
                              ? _orderStatusMap[order.id] ??
                                    config.pickupStatus[0]! // '제품 준비 중'
                              : config.pickupStatus[0]!; // '제품 준비 중'
                          final customerName = order.id != null
                              ? _customerNameMap[order.id] ?? '고객 정보 없음'
                              : '고객 정보 없음';

                          return OrderCard(
                            orderId: order.orderCode,
                            customerName: customerName,
                            orderStatus: orderStatus,
                            // 현재 선택된 주문인지 확인하여 선택 상태 전달
                            isSelected: _selectedOrderId == order.id,
                            onTap: () {
                              // 카드 클릭 시 해당 주문을 선택 상태로 변경
                              setState(() {
                                _selectedOrderId = order.id;
                              });
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),

            // 세로 디바이더
            VerticalDivider(width: 1, thickness: 1, color: p.divider),

            // 우측 2/3: 주문자 상세 정보
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: CustomPadding(
                  padding: const EdgeInsets.all(16),
                  child: _selectedOrderId == null
                      ? Center(
                          child: CustomText(
                            '데이터 없음',
                            style: config.titleStyle.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : AdminOrderDetailView(purchaseId: _selectedOrderId!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----Function Start----
  // (태블릿 관련 함수는 admin_tablet_utils.dart로 이동)

  //----Function End----
}
