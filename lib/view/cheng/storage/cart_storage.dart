import 'package:shoes_store_basic_app/core/global_storage.dart';

/// 장바구니 저장소 클래스
class CartStorage {
  static GlobalStorage get _storage => GlobalStorage.instance;
  static const String _keyCart = 'cart';

  /// 장바구니 저장
  static void saveCart(List<Map<String, dynamic>> cart) {
    _storage.save(_keyCart, cart);
  }

  /// 장바구니 가져오기
  static List<Map<String, dynamic>> getCart() {
    final cart = _storage.get<List>(_keyCart);
    if (cart == null) return [];

    return cart.map<Map<String, dynamic>>((e) {
      if (e is Map<String, dynamic>) return e;
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  /// 장바구니 비우기
  static void clearCart() {
    _storage.remove(_keyCart);
  }

  /// 장바구니에 항목 추가 (같은 제품이 있으면 수량 누적)
  static void addToCart(Map<String, dynamic> item) {
    final cart = getCart();
    final productId = item['productId'];

    final idx = cart.indexWhere(
      (e) => e['productId'] == productId,
    );

    if (idx >= 0) {
      final currentQty = _asInt(cart[idx]['quantity'], 0);
      final newQty = _asInt(item['quantity'], 0);
      cart[idx]['quantity'] = currentQty + newQty;
    } else {
      cart.add(item);
    }

    saveCart(cart);
  }

  /// 장바구니에서 항목 제거
  static void removeFromCart(int index) {
    final cart = getCart();
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      saveCart(cart);
    }
  }

  /// 장바구니 항목 수량 업데이트
  static void updateQuantity(int index, int quantity) {
    final cart = getCart();
    if (index >= 0 && index < cart.length && quantity > 0) {
      cart[index]['quantity'] = quantity;
      saveCart(cart);
    }
  }

  /// 장바구니가 비어있는지 확인
  static bool isEmpty() {
    return getCart().isEmpty;
  }

  /// 장바구니 항목 개수 가져오기
  static int getItemCount() {
    return getCart().length;
  }

  static int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }
}

