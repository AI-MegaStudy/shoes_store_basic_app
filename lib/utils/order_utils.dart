import 'package:shoes_store_basic_app/custom/custom_common_util.dart';

/// 주문 관련 유틸리티
class OrderUtils {
  /// 주문 코드 생성 (userId_yyyyMMddHHmmss)
  static String generateOrderCode(int userId) {
    final now = DateTime.now();
    final dateTimeStr = CustomCommonUtil.formatDate(now, 'yyyyMMddHHmmss');
    return '${userId}_$dateTimeStr';
  }

  /// 가격에 천 단위 콤마 추가
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

