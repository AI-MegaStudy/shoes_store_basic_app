import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase_item.dart';
import 'package:shoes_store_basic_app/utils/order_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/cart_storage.dart';
import 'package:shoes_store_basic_app/custom/custom_bottom_sheet.dart';
import 'package:shoes_store_basic_app/custom/custom_common_util.dart';
import 'package:shoes_store_basic_app/view/customer/payment_sheet_content.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 결제 화면
///
/// 장바구니에 담긴 상품들의 목록을 보여주고, 결제를 진행할 수 있는 화면입니다.
/// Cart 화면에서 전달받은 장바구니 정보를 표시하고, 결제 확정 시 PurchaseItem을 DB에 저장합니다.
class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  final _purchaseHandler = PurchaseHandler();
  final _purchaseItemHandler = PurchaseItemHandler();
  final _productHandler = ProductHandler();
  final _loginHistoryHandler = LoginHistoryHandler();

  late final List<Map<String, dynamic>> cart;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Cart 화면에서 전달받은 장바구니 리스트
      final raw = ModalRoute.of(context)?.settings.arguments;
      final List list = (raw is List) ? raw : [];
      cart = list.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        return Map<String, dynamic>.from(e as Map);
      }).toList();
      _initialized = true;
    }
  }

  /// 동적 값을 int로 변환
  ///
  /// [v] 변환할 값
  /// [def] 변환 실패 시 기본값
  /// 반환: int 값
  int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  /// 총 금액 계산
  ///
  /// 장바구니의 모든 상품의 가격 합계를 계산합니다.
  int get totalPrice {
    return cart.fold<int>(0, (sum, e) {
      final q = _asInt(e['quantity'], 1);
      final p = _asInt(e['unitPrice'], 0);
      return sum + (q * p);
    });
  }

  /// 장바구니 비우기
  ///
  /// 구매 완료 후 GlobalStorage에서 장바구니를 삭제합니다.
  void _clearCart() {
    CartStorage.clearCart();
  }

  /// 구매 전 재고 확인
  ///
  /// 장바구니의 모든 상품의 재고를 확인하여 구매 가능한지 검증합니다.
  /// 반환값: (구매 가능 여부, 재고 부족 상품 목록)
  Future<(bool, List<String>)> _validateStock() async {
    final insufficientItems = <String>[];

    for (final e in cart) {
      final productId = _asInt(e['productId']);
      final purchaseQuantity = _asInt(e['quantity'], 1);
      final productName = e['name'] as String? ?? '알 수 없는 상품';

      // DB에서 최신 재고 조회
      final product = await _productHandler.queryById(productId);
      if (product == null) {
        insufficientItems.add('$productName: 제품 정보를 찾을 수 없습니다.');
        continue;
      }

      // 재고 부족 체크
      if (product.pQuantity < purchaseQuantity) {
        insufficientItems.add(
          '$productName: 재고 ${product.pQuantity}개 / 구매 요청 $purchaseQuantity개',
        );
      }
    }

    return (insufficientItems.isEmpty, insufficientItems);
  }

  /// 결제 확정 시 Purchase와 PurchaseItem을 DB에 저장
  ///
  /// 1. 구매 전 재고 확인 (다른 사용자의 구매로 재고가 부족할 수 있음)
  /// 2. 현재 로그인한 사용자 ID를 가져옵니다.
  /// 3. Purchase 객체를 생성하여 DB에 저장합니다.
  ///    - timeStamp: 현재 날짜/시간
  ///    - pickupDate: 현재 날짜 + 1일
  ///    - orderCode: 사용자 ID + 날짜/시간 조합
  /// 4. 생성된 Purchase ID를 사용하여 PurchaseItem들을 저장합니다.
  /// 5. 재고 차감 (구매 완료 시에만)
  ///
  /// 재고가 부족하면 Exception을 발생시킵니다.
  Future<void> _savePurchaseItemsToDb() async {
    // 구매 전 재고 확인 (다른 사용자의 구매로 재고가 변경되었을 수 있음)
    final (isValid, insufficientItems) = await _validateStock();
    if (!isValid) {
      final errorMessage =
          '재고가 부족한 상품이 있습니다:\n${insufficientItems.join('\n')}\n\n'
          '다른 사용자가 구매하여 재고가 변경되었을 수 있습니다.';
      throw Exception(errorMessage);
    }

    // 현재 로그인한 사용자 ID 가져오기
    final userId = UserStorage.getUserId();
    if (userId == null) {
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }

    // 현재 시간과 다음날 시간 계산
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Purchase 객체 생성
    final purchase = Purchase(
      cid: userId,
      timeStamp: now.toIso8601String(),
      pickupDate: tomorrow
          .toIso8601String()
          .split('T')
          .first, // 날짜만 추출 (YYYY-MM-DD)
      orderCode: OrderUtils.generateOrderCode(userId),
    );

    // Purchase를 DB에 저장하고 생성된 ID 가져오기
    final purchaseId = await _purchaseHandler.insertData(purchase);

    // 장바구니의 모든 상품을 PurchaseItem으로 변환하여 저장 및 재고 차감
    for (final e in cart) {
      final productId = _asInt(e['productId']);
      final purchaseQuantity = _asInt(e['quantity'], 1);

      // PurchaseItem 저장
      final item = PurchaseItem(
        pid: productId,
        pcid: purchaseId, // 생성된 Purchase ID 사용
        pcQuantity: purchaseQuantity,
        pcStatus: config.pickupStatus[0]!, // 초기 상태는 "제품 준비 중"
      );

      await _purchaseItemHandler.insertData(item);

      // 재고 차감: 제품의 재고에서 구매 수량만큼 차감
      // 재고 확인은 이미 _validateStock()에서 완료했으므로 여기서는 차감만 수행
      try {
        final product = await _productHandler.queryById(productId);
        if (product != null) {
          // 재고가 부족한 경우를 대비해 한 번 더 체크
          if (product.pQuantity >= purchaseQuantity) {
            final newQuantity = product.pQuantity - purchaseQuantity;
            await _productHandler.updateQuantity(productId, newQuantity);
          } else {
            // 재고가 부족하면 에러 발생 (이론적으로는 발생하지 않아야 함)
            throw Exception(
              '재고 부족: ${product.pQuantity}개 / 구매 요청 $purchaseQuantity개',
            );
          }
        }
      } catch (e) {
        // 재고 업데이트 실패 시 에러 전파
        throw Exception('재고 업데이트 실패 (productId: $productId): $e');
      }
    }
  }

  void _openPaymentSheet() async {
    // config.dart에 정의된 서울 내 자치구 리스트 사용
    final districts = config.district;

    // LoginHistory에서 저장된 district 불러오기
    String? savedDistrict;
    final userId = UserStorage.getUserId();
    if (userId != null) {
      try {
        final histories = await _loginHistoryHandler.queryByCustomerId(userId);
        if (histories.isNotEmpty) {
          final latest = histories.first;
          if (latest.lAddress.isNotEmpty) {
            final districtValue = latest.lAddress.trim();
            if (districts.contains(districtValue)) {
              savedDistrict = districtValue;
            }
          }
        }
      } catch (e) {
        print('저장된 district 로드 실패: $e');
      }
    }

    await CustomBottomSheet.show(
      context: context,
      isScrollControlled: true,
      child: PaymentSheetContent(
        initialDistrict: savedDistrict ?? districts.first,
        districts: districts,
        totalPrice: totalPrice,
        cart: cart,
        onSavePurchase: _savePurchaseItemsToDb,
        onClearCart: _clearCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '결제',
            style: config.boldLabelStyle.copyWith(color: p.textPrimary),
          ),
        ),
        body: Center(
          child: Text(
            '구매할 상품이 없습니다',
            style: config.boldLabelStyle.copyWith(color: p.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '결제',
          style: config.boldLabelStyle.copyWith(color: p.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final e = cart[index];
                final img =
                    (e['imagePath'] as String?) ?? 'assets/images/no_image.png';
                final name = (e['name'] as String?) ?? 'NO NAME';
                final color = (e['color'] as String?) ?? '';
                final size = _asInt(e['size'], 0);
                final qty = _asInt(e['quantity'], 1);
                final unitPrice = _asInt(e['unitPrice'], 0);
                final lineTotal = unitPrice * qty;

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image.asset(
                          img,
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/no_image.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: config.boldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '색상: $color / 사이즈: $size',
                                style: config.boldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '수량: $qty',
                                style: config.boldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                              Text(
                                '합계: ${CustomCommonUtil.formatNumber(lineTotal)}원',
                                style: config.boldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '총액: ${CustomCommonUtil.formatNumber(totalPrice)}원',
                    style: config.boldLabelStyle.copyWith(color: p.textPrimary),
                  ),
                ),
                ElevatedButton(
                  onPressed: _openPaymentSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: Text(
                    '결제하기',
                    style: config.boldLabelStyle.copyWith(
                      color: p.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
