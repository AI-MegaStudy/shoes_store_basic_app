import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';
import 'package:shoes_store_basic_app/utils/order_status_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/widgets/customer/customer_order_card.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/return_detail_view.dart';

/// 고객용 수령 완료 목록 화면
/// 모바일 세로 화면에 최적화된 수령 완료 목록 화면입니다.
/// 검색 필터와 수령 완료 주문 카드 리스트를 표시하며, 카드를 탭하면 상세 페이지로 이동합니다.
class ReturnListView extends StatefulWidget {
  const ReturnListView({super.key});

  @override
  State<ReturnListView> createState() => _ReturnListViewState();
}

class _ReturnListViewState extends State<ReturnListView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 주문 목록 데이터 (상태 2 이상)
  List<Purchase> _orders = [];

  /// 주문 상태 맵 (주문 ID -> 상태)
  Map<int, String> _orderStatusMap = {};

  /// 로딩 상태
  bool _isLoading = true;

  /// 정렬 기준 (기본값: 주문 번호)
  String _sortBy = 'orderCode';

  /// 정렬 방향 (true: 오름차순, false: 내림차순)
  bool _sortAscending = true;

  /// 주문 핸들러
  final PurchaseHandler _purchaseHandler = PurchaseHandler();

  /// 주문 항목 핸들러
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// DB에서 수령 완료 이상 상태(2 이상)의 주문 목록을 불러오는 함수
  /// 현재 로그인한 사용자의 주문만 필터링하여 가져옵니다.
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserStorage.getUserId();
      if (userId == null) {
        AppLogger.w('사용자 정보가 없습니다. 로그인이 필요합니다.');
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      AppLogger.d('=== 수령 완료 목록 조회 시작 ===');
      AppLogger.d('사용자 ID: $userId');

      /// 현재 사용자의 주문 목록 조회
      final purchases = await _purchaseHandler.queryByCustomerId(userId);
      AppLogger.d('조회된 Purchase 개수: ${purchases.length}');

      /// 시간순으로 정렬 (최신순)
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      /// 상태가 2 이상인 주문만 필터링하고 반품 가능 여부 확인
      final completedOrders = <Purchase>[];
      final statusMap = <int, String>{};
      final now = DateTime.now();

      for (final purchase in purchases) {
        if (purchase.id != null) {
          try {
            final items = await _purchaseItemHandler.queryByPurchaseId(
              purchase.id!,
            );

            bool hasStatus2OrAbove = false;
            for (final item in items) {
              final statusNum = OrderStatusUtils.parseStatusToNumber(
                item.pcStatus,
              );
              if (statusNum >= 2) {
                hasStatus2OrAbove = true;
                break;
              }
            }

            if (hasStatus2OrAbove) {
              completedOrders.add(purchase);

              final returnStatus = OrderStatusUtils.determineReturnStatus(
                items,
                purchase,
                now: now,
              );
              statusMap[purchase.id!] = returnStatus;

              AppLogger.d(
                '수령 완료 주문 추가: id=${purchase.id}, orderCode=${purchase.orderCode}, 반품 상태: $returnStatus',
              );
            }
          } catch (e) {
            AppLogger.e('주문 상태 조회 실패 (ID: ${purchase.id})', error: e);
          }
        }
      }

      AppLogger.d('=== 수령 완료 목록 조회 완료 (${completedOrders.length}개) ===');

      setState(() {
        _orders = completedOrders;
        _orderStatusMap = statusMap;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('수령 완료 목록 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

  /// 검색어에 따라 필터링되고 정렬된 주문 목록 반환
  List<Purchase> get _filteredOrders {
    var filtered = _orders;

    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((order) {
        if (order.orderCode.toLowerCase().contains(searchText)) {
          return true;
        }

        final orderDate = _normalizeDate(order.timeStamp);
        final searchDate = _normalizeDate(searchText);

        if (orderDate.contains(searchDate) || searchDate.contains(orderDate)) {
          return true;
        }

        if (order.timeStamp.toLowerCase().contains(searchText) ||
            order.pickupDate.toLowerCase().contains(searchText)) {
          return true;
        }

        return false;
      }).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'orderCode':
          comparison = a.orderCode.compareTo(b.orderCode);
          break;
        case 'orderDate':
          comparison = a.timeStamp.compareTo(b.timeStamp);
          break;
        default:
          comparison = a.orderCode.compareTo(b.orderCode);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// 정렬 기준 변경
  void _changeSortOrder(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = true;
      }
    });
  }

  /// 날짜 문자열 정규화
  String _normalizeDate(String dateString) {
    final cleaned = dateString.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned;
  }

  /// 주문 날짜 포맷팅 (날짜만 있으면 날짜만, 시간이 있으면 날짜 시분까지)
  String _formatOrderDate(String timeStamp) {
    try {
      // DateTime 파싱 (ISO 8601 형식 또는 일반 형식)
      DateTime dateTime;
      if (timeStamp.contains('T')) {
        // ISO 8601 형식: 2025-12-26T01:45:17.6658615 -> T를 공백으로 변경 후 파싱
        dateTime = DateTime.parse(timeStamp.replaceFirst('T', ' '));
      } else {
        // 일반 형식: 2025-12-26 또는 2025-12-26 01:45:17
        dateTime = DateTime.parse(timeStamp);
      }

      // 시간이 있는지 확인 (시/분이 0이 아니거나 초/밀리초가 있는지)
      final hasTime =
          dateTime.hour != 0 ||
          dateTime.minute != 0 ||
          dateTime.second != 0 ||
          dateTime.millisecond != 0;

      if (hasTime) {
        // 날짜 + 시분: yyyy-MM-dd HH:mm
        return CustomCommonUtil.formatDate(dateTime, 'yyyy-MM-dd HH:mm');
      } else {
        // 날짜만: yyyy-MM-dd
        return CustomCommonUtil.formatDate(dateTime, 'yyyy-MM-dd');
      }
    } catch (e) {
      // 파싱 실패 시 원본 반환 (fallback)
      return timeStamp.split(' ').first.replaceAll('T', ' ').split('.').first;
    }
  }

  /// 주문 카드 위젯 생성
  Widget _buildOrderCard(Purchase order) {
    final orderDate = _formatOrderDate(order.timeStamp);

    String orderStatus = order.id != null
        ? _orderStatusMap[order.id] ?? '반품 불가'
        : '반품 불가';

    return GestureDetector(
      onTap: () async {
        if (order.id != null) {
          await CustomNavigationUtil.to(
            context,
            ReturnDetailView(purchaseId: order.id!),
          );
          _loadOrders();
        }
      },
      child: CustomerOrderCard(
        orderId: order.orderCode,
        orderStatus: orderStatus,
        orderDate: orderDate,
        totalPrice: null,
      ),
    );
  }

  /// 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 빈 주문 목록 메시지 위젯
  Widget _buildEmptyMessage() {
    return Center(
      child: CustomPadding(
        padding: const EdgeInsets.symmetric(vertical: config.extraLargeSpacing),
        child: CustomText(
          '수령 완료 내역이 없습니다.',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 주문 목록 위젯
  Widget _buildOrderList() {
    return Column(
      children: _filteredOrders.map((order) => _buildOrderCard(order)).toList(),
    );
  }

  /// 정렬 버튼 위젯
  Widget _buildSortButton(String sortBy, String label) {
    final isActive = _sortBy == sortBy;
    final icon = isActive
        ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.sort;

    final p = context.palette;

    return GestureDetector(
      onTap: () => _changeSortOrder(sortBy),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ), // 작은 버튼 패딩이므로 상수화하지 않음
        decoration: BoxDecoration(
          color: isActive
              ? p.chipSelectedBg.withOpacity(0.2)
              : p.chipUnselectedBg,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: p.primary, width: 2) : null,
        ),
        child: CustomRow(
          spacing: 4,
          children: [
            CustomText(
              label,
              style: config.smallTextStyle.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Icon(icon, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: '수령완료 / 반품 목록',
        centerTitle: true,
        titleTextStyle: config.boldLabelStyle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: const EdgeInsets.all(16),
            child: CustomColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                CustomTextField(
                  controller: _searchController,
                  hintText: '주문번호 또는 주문날짜로 검색',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (_) => setState(() {}),
                ),

                CustomRow(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: config.smallSpacing,
                  children: [
                    _buildSortButton('orderCode', '주문번호'),
                    _buildSortButton('orderDate', '주문일'),
                  ],
                ),

                CustomText('수령완료 / 반품 목록', style: config.titleStyle),

                if (_isLoading)
                  _buildLoadingIndicator()
                else if (_filteredOrders.isEmpty)
                  _buildEmptyMessage()
                else
                  _buildOrderList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
