import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase_item.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';

/// 주문 상태 관련 유틸리티
class OrderStatusUtils {
  /// 상태 문자열을 숫자로 변환 (0~5)
  /// 파싱 실패 시 0 반환
  static int parseStatusToNumber(String pcStatus) {
    // pickupStatus의 value(한글 문자열)와 직접 비교
    for (var entry in config.pickupStatus.entries) {
      if (pcStatus == entry.value) {
        return entry.key;
      }
    }

    AppLogger.w('알 수 없는 상태 문자열: "$pcStatus"', tag: 'OrderStatusUtils');
    return 0;
  }

  /// 날짜 문자열에서 날짜만 추출 (YYYY-MM-DD)
  static String? extractDateOnly(String dateTimeString) {
    if (dateTimeString.isEmpty) {
      AppLogger.w('빈 날짜 문자열이 전달됨', tag: 'OrderStatusUtils');
      return null;
    }

    final dateTime = DateTime.tryParse(dateTimeString);
    if (dateTime == null) {
      AppLogger.w('날짜 파싱 실패: "$dateTimeString"', tag: 'OrderStatusUtils');
      return null;
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDate(String dateString1, String dateString2) {
    final date1 = extractDateOnly(dateString1);
    final date2 = extractDateOnly(dateString2);
    if (date1 == null || date2 == null) return false;
    return date1 == date2;
  }

  /// 구매 당일인지 확인
  static bool isPurchaseDateToday(Purchase purchase, DateTime now) {
    return isSameDate(purchase.timeStamp, now.toIso8601String());
  }

  /// 픽업 날짜로부터 30일 이상 경과했는지 확인
  static bool isPickupDatePassed30Days(Purchase purchase, DateTime now) {
    if (purchase.pickupDate.isEmpty) {
      AppLogger.w(
        'pickupDate가 비어있음 - Purchase ID: ${purchase.id}',
        tag: 'OrderStatusUtils',
      );
      return false;
    }

    final pickupDate = DateTime.tryParse(purchase.pickupDate);
    if (pickupDate == null) {
      AppLogger.w(
        'pickupDate 파싱 실패: "${purchase.pickupDate}" - Purchase ID: ${purchase.id}',
        tag: 'OrderStatusUtils',
      );
      return false;
    }

    final daysDifference = now.difference(pickupDate).inDays;
    return daysDifference >= config.autoCompleteOrderDays;
  }

  /// 반품 상태(3 이상)가 있는지 확인
  static bool hasReturnStatus(List<PurchaseItem> items) {
    return items.any((item) {
      final statusNum = parseStatusToNumber(item.pcStatus);
      return statusNum >= 3;
    });
  }

  /// 고객 화면용 주문 상태 결정
  /// 반품 상태 > 날짜 기반 자동 변경 > 실제 아이템 상태 순서
  static String determineOrderStatusForCustomer(
    List<PurchaseItem> items,
    Purchase purchase, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    // 1단계: 빈 아이템 목록 체크
    if (items.isEmpty) {
      AppLogger.e(
        '주문 상태 결정 실패: PurchaseItem 목록이 비어있음 - Purchase ID: ${purchase.id}, OrderCode: ${purchase.orderCode}',
        tag: 'OrderStatusUtils',
      );
      return config.pickupStatus[0]!;
    }

    // 2단계: 반품 상태 체크 (최우선)
    final returnStatus = _getReturnStatusIfExists(items, purchase);
    if (returnStatus != null) {
      return returnStatus;
    }

    // 3단계: 날짜 기반 자동 상태 변경 체크
    // pickupDate 파싱을 한 번만 수행 (중복 체크 제거)
    final parsedPickupDate = _parsePickupDate(purchase);
    final dateBasedStatus = _getDateBasedStatusWithParsedDate(
      purchase,
      parsedPickupDate,
      currentTime,
    );
    if (dateBasedStatus != null) {
      return dateBasedStatus;
    }

    return _getStatusFromItems(items, purchase, isCustomerView: true);
  }

  /// 관리자 화면용 주문 상태 결정
  /// showActualStatus가 false면 고객 화면과 동일하게 표시
  static String determineOrderStatusForAdmin(
    List<PurchaseItem> items,
    Purchase purchase, {
    DateTime? now,
    bool showActualStatus = true,
  }) {
    final currentTime = now ?? DateTime.now();

    if (items.isEmpty) {
      AppLogger.e(
        '주문 상태 결정 실패(관리자): PurchaseItem 목록이 비어있음 - Purchase ID: ${purchase.id}, OrderCode: ${purchase.orderCode}',
        tag: 'OrderStatusUtils',
      );
      return config.pickupStatus[0]!;
    }

    final returnStatus = _getReturnStatusIfExists(items, purchase);
    if (returnStatus != null) {
      return returnStatus;
    }

    final parsedPickupDate = _parsePickupDate(purchase);
    final dateBasedStatus = _getDateBasedStatusWithParsedDate(
      purchase,
      parsedPickupDate,
      currentTime,
    );
    if (dateBasedStatus != null) {
      return dateBasedStatus;
    }

    return _getStatusFromItems(
      items,
      purchase,
      isCustomerView: !showActualStatus,
    );
  }

  /// 주문 관리 화면용 주문 상태 결정
  /// 반품 상태를 무시하고, status 2 이상이면 "제품 수령 완료"로 표시
  static String determineOrderStatusForOrderManagement(
    List<PurchaseItem> items,
    Purchase purchase,
  ) {
    if (items.isEmpty) {
      AppLogger.e(
        '주문 상태 결정 실패(주문 관리): PurchaseItem 목록이 비어있음 - Purchase ID: ${purchase.id}, OrderCode: ${purchase.orderCode}',
        tag: 'OrderStatusUtils',
      );
      return config.pickupStatus[0]!; // '제품 준비 중'
    }

    final statusNumbers = items
        .map((item) => parseStatusToNumber(item.pcStatus))
        .toList();

    // 최소 status 계산
    final minStatus = statusNumbers.reduce((a, b) => a < b ? a : b);

    // status 2 이상이면 "제품 수령 완료"로 표시 (반품 상태 무시)
    if (minStatus >= 2) {
      return config.pickupStatus[2]!; // '제품 수령 완료'
    } else {
      return config.pickupStatus[minStatus]!;
    }
  }

  /// 30일 경과로 인한 자동 수령 완료 처리 필요 여부
  static bool shouldAutoUpdateToCompleted(
    List<PurchaseItem> items,
    Purchase purchase, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    if (hasReturnStatus(items)) {
      return false;
    }

    if (!isPickupDatePassed30Days(purchase, currentTime)) {
      return false;
    }

    // status 2 미만인 아이템이 하나라도 있으면 업데이트 필요
    return items.any((item) {
      final statusNum = parseStatusToNumber(item.pcStatus);
      return statusNum < 2;
    });
  }

  /// 반품 상태가 있으면 가장 높은 반품 상태 반환, 없으면 null
  static String? _getReturnStatusIfExists(
    List<PurchaseItem> items,
    Purchase purchase,
  ) {
    if (!hasReturnStatus(items)) {
      return null;
    }

    final statusNumbers = items
        .map((item) => parseStatusToNumber(item.pcStatus))
        .where((status) => status >= 3)
        .toList();

    final maxReturnStatus = statusNumbers.reduce((a, b) => a > b ? a : b);
    return config.pickupStatus[maxReturnStatus]!;
  }

  /// pickupDate 파싱
  static DateTime? _parsePickupDate(Purchase purchase) {
    if (purchase.pickupDate.isEmpty) {
      AppLogger.w(
        'pickupDate가 비어있음 - Purchase ID: ${purchase.id}',
        tag: 'OrderStatusUtils',
      );
      return null;
    }

    final pickupDate = DateTime.tryParse(purchase.pickupDate);
    if (pickupDate == null) {
      AppLogger.w(
        'pickupDate 파싱 실패: "${purchase.pickupDate}" - Purchase ID: ${purchase.id}',
        tag: 'OrderStatusUtils',
      );
      return null;
    }

    return pickupDate;
  }

  /// 날짜 기반 자동 상태 변경 체크
  /// 30일 경과 > 픽업 날짜 경과 > 구매 당일 순서
  static String? _getDateBasedStatusWithParsedDate(
    Purchase purchase,
    DateTime? parsedPickupDate,
    DateTime now,
  ) {
    if (parsedPickupDate != null) {
      final daysDifference = now.difference(parsedPickupDate).inDays;
      if (daysDifference >= config.autoCompleteOrderDays) {
        return config.pickupStatus[2]!;
      }

      final pickupDateOnly = DateTime(
        parsedPickupDate.year,
        parsedPickupDate.month,
        parsedPickupDate.day,
      );
      final nowDateOnly = DateTime(now.year, now.month, now.day);

      if (pickupDateOnly.isBefore(nowDateOnly) ||
          pickupDateOnly.isAtSameMomentAs(nowDateOnly)) {
        return config.pickupStatus[1]!;
      }
    }

    if (isPurchaseDateToday(purchase, now)) {
      return config.pickupStatus[0]!;
    }

    return null;
  }

  /// PurchaseItem의 pcStatus 기반 상태 결정
  /// 모든 아이템이 같으면 그 상태, 다르면 가장 낮은 상태 사용
  /// isCustomerView가 true면 status 2 이상은 모두 "제품 수령 완료"로 표시
  static String _getStatusFromItems(
    List<PurchaseItem> items,
    Purchase purchase, {
    required bool isCustomerView,
  }) {
    final statusNumbers = items
        .map((item) => parseStatusToNumber(item.pcStatus))
        .toList();

    final firstStatus = statusNumbers.first;
    final allSameStatus = statusNumbers.every(
      (status) => status == firstStatus,
    );

    final displayStatus = allSameStatus
        ? firstStatus
        : statusNumbers.reduce((a, b) => a < b ? a : b);

    if (isCustomerView) {
      if (displayStatus >= 2) {
        return config.pickupStatus[2]!;
      } else {
        return config.pickupStatus[displayStatus]!;
      }
    }

    return config.pickupStatus[displayStatus]!;
  }

  /// 반품 가능 여부 결정
  /// 상태가 2이고 30일이 지나지 않았으면 반품 가능
  static String determineReturnStatus(
    List<PurchaseItem> items,
    Purchase purchase, {
    DateTime? now,
  }) {
    if (items.isEmpty) {
      AppLogger.e(
        '반품 상태 결정 실패: PurchaseItem 목록이 비어있음 - Purchase ID: ${purchase.id}, OrderCode: ${purchase.orderCode}',
        tag: 'OrderStatusUtils',
      );
      return '반품 불가';
    }

    final currentTime = now ?? DateTime.now();
    bool hasReturnableItem = false;
    bool allReturnCompleted = true;

    for (final item in items) {
      final statusNum = parseStatusToNumber(item.pcStatus);

      if (statusNum == 5) {
        continue;
      } else {
        allReturnCompleted = false;
      }

      if (statusNum == 2) {
        final is30DaysPassed = isPickupDatePassed30Days(purchase, currentTime);
        if (!is30DaysPassed) {
          hasReturnableItem = true;
        }
      }
    }

    if (allReturnCompleted) {
      return '반품 불가';
    }

    if (hasReturnableItem) {
      return '반품 가능';
    }

    return '반품 불가';
  }
}
