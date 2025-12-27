import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/dummy_data/dummy_data_constants.dart';

/// 더미 데이터 세트 추상 클래스
/// 
/// 각 목적별 데이터 세트는 이 클래스를 상속받아 구현합니다.
abstract class DummyDataSet {
  /// 제조사 데이터
  List<Map<String, dynamic>> get manufacturers;

  /// 제품 기본 정보 데이터
  List<Map<String, dynamic>> get productBases;

  /// 제품 이미지 매핑 (ProductBase 인덱스 → 이미지 경로 리스트)
  Map<int, List<String>> get productImages;

  /// 제품 설정 정보 (ProductBase 인덱스 → 제품 설정)
  Map<int, Map<String, dynamic>> get productConfig;

  /// 고객 데이터
  List<Map<String, dynamic>> get customers;

  /// 직원 데이터
  List<Map<String, dynamic>> get employees;

  /// 주문 데이터
  List<Map<String, dynamic>> get purchases;

  /// 주문 항목 데이터
  List<Map<String, dynamic>> get purchaseItems;

  /// 로그인 이력 데이터
  List<Map<String, dynamic>> get loginHistories;
}

// ============================================
// 개발용 데이터 세트
// ============================================

/// 개발용 더미 데이터 세트
/// 
/// 기본 개발 및 테스트에 사용되는 데이터 세트입니다.
class DevelopmentDataSet extends DummyDataSet {
  @override
  List<Map<String, dynamic>> get manufacturers => DummyManufacturers.data;

  @override
  List<Map<String, dynamic>> get productBases => DummyProductBases.development;

  @override
  Map<int, List<String>> get productImages => DummyProductImages.imageMap;

  @override
  Map<int, Map<String, dynamic>> get productConfig => DummyProducts.productConfig;

  @override
  List<Map<String, dynamic>> get customers => DummyCustomers.development;

  @override
  List<Map<String, dynamic>> get employees => DummyEmployees.development;

  @override
  List<Map<String, dynamic>> get purchases => DummyPurchases.development;

  @override
  List<Map<String, dynamic>> get purchaseItems => DummyPurchaseItems.development;

  @override
  List<Map<String, dynamic>> get loginHistories => DummyLoginHistories.development;
}

// ============================================
// 테스트용 데이터 세트
// ============================================

/// 테스트용 더미 데이터 세트
/// 
/// 최소한의 데이터만 포함하여 빠른 테스트에 사용됩니다.
class TestDataSet extends DummyDataSet {
  @override
  List<Map<String, dynamic>> get manufacturers => DummyManufacturers.data;

  @override
  List<Map<String, dynamic>> get productBases => DummyProductBases.test;

  @override
  Map<int, List<String>> get productImages => {
    0: [
      '${config.imageAssetPath}default.png',
    ],
  };

  @override
  Map<int, Map<String, dynamic>> get productConfig => {
    0: {
      'mfid': 0, // Nike
      'sizes': [250, 260],
      'basePrices': [100000, 110000],
      'quantity': 10,
    },
  };

  @override
  List<Map<String, dynamic>> get customers => DummyCustomers.test;

  @override
  List<Map<String, dynamic>> get employees => DummyEmployees.test;

  @override
  List<Map<String, dynamic>> get purchases => [
    {
      'cid': 0,
      'pickupDate': '2025-12-13 07:20',
      'orderCode': 'TEST-001',
      'timeStamp': '2025-12-12 07:20',
    },
  ];

  @override
  List<Map<String, dynamic>> get purchaseItems => [
    {
      'pid': 0,
      'pcid': 0,
      'pcQuantity': 1,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
  ];

  @override
  List<Map<String, dynamic>> get loginHistories => [
    {
      'cid': 0,
      'loginTime': '2025-12-12 17:05',
      'lStatus': '0',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
  ];
}

// ============================================
// 데모용 데이터 세트 (향후 확장)
// ============================================

/// 데모용 더미 데이터 세트
/// 
/// 데모 및 프레젠테이션에 사용되는 풍부한 데이터 세트입니다.
/// 현재는 DevelopmentDataSet과 동일하지만 향후 확장 가능합니다.
class DemoDataSet extends DummyDataSet {
  @override
  List<Map<String, dynamic>> get manufacturers => DummyManufacturers.extended;

  @override
  List<Map<String, dynamic>> get productBases => DummyProductBases.development;

  @override
  Map<int, List<String>> get productImages => DummyProductImages.imageMap;

  @override
  Map<int, Map<String, dynamic>> get productConfig => DummyProducts.productConfig;

  @override
  List<Map<String, dynamic>> get customers => DummyCustomers.development;

  @override
  List<Map<String, dynamic>> get employees => DummyEmployees.development;

  @override
  List<Map<String, dynamic>> get purchases => DummyPurchases.development;

  @override
  List<Map<String, dynamic>> get purchaseItems => DummyPurchaseItems.development;

  @override
  List<Map<String, dynamic>> get loginHistories => DummyLoginHistories.development;
}

