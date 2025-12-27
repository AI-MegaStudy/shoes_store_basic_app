import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/custom/custom_common_util.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/cart_storage.dart';
import 'package:shoes_store_basic_app/custom/custom_snack_bar.dart';
import 'package:shoes_store_basic_app/custom/custom_dialog.dart';
import 'package:shoes_store_basic_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

//  Cart page
/*
  Create: 12/12/2025 10:46, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    13/12/2025 19:14, 'Point 1, Atcual data attached', Creator: Chansol Park
  Version: 2.0
  Dependency: SQFlite, Path
  Desc: Cart page MUST have lists of Products
  Changed: GetStorage -> GlobalStorage (CartStorage)로 변경

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final _productHandler = ProductHandler();

  List<Map<String, dynamic>> cart = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  /// 장바구니 로드
  /// 
  /// GlobalStorage에서 장바구니 데이터를 불러옵니다.
  void _loadCart() {
    cart = CartStorage.getCart();
    setState(() => loading = false);
  }

  /// 장바구니 저장
  /// 
  /// GlobalStorage에 장바구니 데이터를 저장합니다.
  void _saveCart() {
    CartStorage.saveCart(cart);
    setState(() {}); // UI 갱신
  }

  int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  int get totalPrice {
    return cart.fold<int>(0, (sum, e) {
      final q = _asInt(e['quantity'], 1);
      final p = _asInt(e['unitPrice'], 0);
      return sum + (q * p);
    });
  }

  /// 장바구니에서 특정 제품의 총 수량을 계산합니다.
  /// 
  /// [productId] 확인할 제품 ID
  /// [excludeIndex] 제외할 인덱스 (현재 수정 중인 항목 제외)
  /// 반환: 장바구니에 담긴 총 수량
  int _getTotalCartQuantity(int productId, {int? excludeIndex}) {
    int total = 0;
    for (int i = 0; i < cart.length; i++) {
      if (i == excludeIndex) continue;
      if (_asInt(cart[i]['productId']) == productId) {
        total += _asInt(cart[i]['quantity'], 0);
      }
    }
    return total;
  }

  /// 수량 증가 시 최대 수량 체크 및 다이얼로그 표시
  Future<void> _inc(int index) async {
    final productId = _asInt(cart[index]['productId']);
    if (productId == 0) return;

    // DB에서 현재 재고 확인
    final product = await _productHandler.queryById(productId);
    if (product == null) {
      CustomSnackBar.showError(
        context,
        message: '제품 정보를 찾을 수 없습니다.',
      );
      return;
    }

    // 현재 장바구니에 담긴 수량 (현재 항목 제외)
    final currentCartQty = _getTotalCartQuantity(productId, excludeIndex: index);
    final newQuantity = _asInt(cart[index]['quantity'], 1) + 1;
    final totalAfterIncrease = currentCartQty + newQuantity;

    // 재고 초과 체크
    if (totalAfterIncrease > product.pQuantity) {
      final maxAvailable = product.pQuantity - currentCartQty;
      CustomDialog.show(
        context,
        title: '수량 초과',
        message: '재고가 부족합니다.\n'
            '현재 재고: ${product.pQuantity}개\n'
            '장바구니에 담긴 수량: $currentCartQty개\n'
            '구매 가능한 최대 수량: ${maxAvailable > 0 ? maxAvailable : 0}개',
        type: DialogType.single,
        confirmText: '확인',
      );
      return;
    }

    // 수량 증가
    cart[index]['quantity'] = newQuantity;
    _saveCart();
  }

  void _dec(int index) {
    final q = _asInt(cart[index]['quantity'], 1);
    if (q <= 1) return;
    cart[index]['quantity'] = q - 1;
    _saveCart();
  }

  void _remove(int index) {
    cart.removeAt(index);
    _saveCart();
  }

  void _goPurchase() {
    if (cart.isEmpty) {
      CustomSnackBar.show(context, message: '장바구니가 비어있습니다.');
      return;
    }
    // 결제 화면으로 이동 + cart 전체 넘김
    CustomNavigationUtil.toNamed(context, config.routePurchaseView, arguments: cart);
  }

  /// 장바구니 비우기
  /// 
  /// GlobalStorage에서 장바구니를 완전히 삭제합니다.
  void _clearCart() {
    CartStorage.clearCart();
    cart.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
        actions: [
          IconButton(
            onPressed: cart.isEmpty ? null : _clearCart,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '전체 삭제',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cart.isEmpty
                      ? Center(child: Text('장바구니가 비어있음', style: config.boldLabelStyle.copyWith(color: p.textPrimary)))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];

                            final img = (item['imagePath'] as String?)?.trim();
                            final name = (item['name'] as String?) ?? 'NO NAME';
                            final color = (item['color'] as String?) ?? '';
                            final size = _asInt(item['size'], 0);
                            final unitPrice = _asInt(item['unitPrice'], 0);
                            final qty = _asInt(item['quantity'], 1);
                            final lineTotal = unitPrice * qty;

                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 이미지: 없는 경로면 기본 이미지
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: (img != null && img.isNotEmpty)
                                          ? Image.asset(
                                              img,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset('assets/images/no_image.png', fit: BoxFit.contain),
                                            )
                                          : Image.asset('assets/images/no_image.png', fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: config.boldLabelStyle.copyWith(color: p.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('색상: $color / 사이즈: $size', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                                          const SizedBox(height: 6),
                                          Text('단가: ${CustomCommonUtil.formatNumber(unitPrice)}원', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                                          const SizedBox(height: 4),
                                          Text('합계: ${CustomCommonUtil.formatNumber(lineTotal)}원', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () => _dec(index),
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text('$qty', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                                            IconButton(
                                              onPressed: () => _inc(index),
                                              icon: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () => _remove(index),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 총액 + 결제 버튼
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
                        onPressed: cart.isEmpty ? null : _goPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cart.isEmpty 
                              ? p.divider
                              : p.primary,
                          foregroundColor: p.textOnPrimary,
                        ),
                        child: Text('결제 화면', style: config.boldLabelStyle.copyWith(color: p.textOnPrimary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

