import 'package:shoes_store_basic_app/config.dart' as config;

/// 더미 데이터 상수 정의
/// 
/// 모든 더미 데이터를 상수로 정의하여 일괄 수정이 가능하도록 합니다.
/// 각 데이터는 Map 형태로 정의되어 있어 쉽게 수정할 수 있습니다.

// ============================================
// 제조사 데이터
// ============================================

/// 제조사 더미 데이터
/// 
/// 사용 예시:
/// ```dart
/// // 제조사 추가
/// DummyManufacturers.data.add({'mName': 'Adidas'});
/// ```
class DummyManufacturers {
  /// 기본 제조사 데이터 (개발용)
  static const List<Map<String, dynamic>> data = [
    {'mName': 'Nike'},
    {'mName': 'NewBalance'},
  ];

  /// 확장 제조사 데이터 (데모용)
  static const List<Map<String, dynamic>> extended = [
    {'mName': 'Nike'},
    {'mName': 'NewBalance'},
    {'mName': 'Adidas'},
    {'mName': 'Puma'},
  ];
}

// ============================================
// 제품 기본 정보 데이터
// ============================================

/// 제품 기본 정보 더미 데이터
class DummyProductBases {
  /// 개발용 제품 기본 정보 데이터
  static const List<Map<String, dynamic>> development = [
    // U740WN2 - Black
    {
      'pName': 'U740WN2',
      'pDescription':
          '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
      'pColor': 'Black',
      'pGender': 'Unisex',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NEW009T1',
    },
    // U740WN2 - Gray
    {
      'pName': 'U740WN2',
      'pDescription':
          '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
      'pColor': 'Gray',
      'pGender': 'Unisex',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NEW009T1',
    },
    // U740WN2 - White
    {
      'pName': 'U740WN2',
      'pDescription':
          '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
      'pColor': 'White',
      'pGender': 'Unisex',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NEW009T1',
    },
    // 나이키 샥스 TL - Black
    {
      'pName': '나이키 샥스 TL',
      'pDescription':
          '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
      'pColor': 'Black',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIK321E3',
    },
    // 나이키 샥스 TL - Gray
    {
      'pName': '나이키 샥스 TL',
      'pDescription':
          '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
      'pColor': 'Gray',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIK321E3',
    },
    // 나이키 샥스 TL - White
    {
      'pName': '나이키 샥스 TL',
      'pDescription':
          '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
      'pColor': 'White',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIK321E3',
    },
    // 나이키 에어포스 1 - Black
    {
      'pName': '나이키 에어포스 1',
      'pDescription':
          '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
      'pColor': 'Black',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Sneakers',
      'pModelNumber': 'NISK09UY',
    },
    // 나이키 에어포스 1 - Gray
    {
      'pName': '나이키 에어포스 1',
      'pDescription':
          '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
      'pColor': 'Gray',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Sneakers',
      'pModelNumber': 'NISK09UY',
    },
    // 나이키 에어포스 1 - White
    {
      'pName': '나이키 에어포스 1',
      'pDescription':
          '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
      'pColor': 'White',
      'pGender': 'Female',
      'pStatus': '',
      'pCategory': 'Sneakers',
      'pModelNumber': 'NISK09UY',
    },
    // 나이키 페가수스 플러스 - Black
    {
      'pName': '나이키 페가수스 플러스',
      'pDescription':
          '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
      'pColor': 'Black',
      'pGender': 'Male',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIKTY19Z',
    },
    // 나이키 페가수스 플러스 - Gray
    {
      'pName': '나이키 페가수스 플러스',
      'pDescription':
          '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
      'pColor': 'Gray',
      'pGender': 'Male',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIKTY19Z',
    },
    // 나이키 페가수스 플러스 - White
    {
      'pName': '나이키 페가수스 플러스',
      'pDescription':
          '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
      'pColor': 'White',
      'pGender': 'Male',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'NIKTY19Z',
    },
  ];

  /// 테스트용 최소 제품 기본 정보 데이터
  static const List<Map<String, dynamic>> test = [
    {
      'pName': 'Test Product',
      'pDescription': '테스트용 제품입니다.',
      'pColor': 'Black',
      'pGender': 'Unisex',
      'pStatus': '',
      'pCategory': 'Running',
      'pModelNumber': 'TEST001',
    },
  ];
}

// ============================================
// 제품 이미지 데이터
// ============================================

/// 제품 이미지 더미 데이터
/// 
/// ProductBase ID별로 이미지 경로 리스트를 매핑합니다.
/// 인덱스는 ProductBase의 순서와 일치합니다 (0-based).
class DummyProductImages {
  /// ProductBase ID별 이미지 경로 매핑
  /// 
  /// 키: ProductBase 인덱스 (0-based)
  /// 값: 해당 ProductBase의 이미지 경로 리스트
  static const Map<int, List<String>> imageMap = {
    0: [
      '${config.imageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_02.png',
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_03.png',
    ],
    1: [
      '${config.imageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_01.png',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_02.png',
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_03.png',
    ],
    2: [
      '${config.imageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_01.png',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_02.png',
      // '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_03.png',
    ],
    3: [
      '${config.imageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_02.avif',
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_03.avif',
    ],
    4: [
      '${config.imageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_02.avif',
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_03.avif',
    ],
    5: [
      '${config.imageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_02.avif',
      // '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_03.avif',
    ],
    6: [
      '${config.imageAssetPath}Nike_Air_1/Nike_Air_1_Black_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_02.avif',
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_03.avif',
    ],
    7: [
      '${config.imageAssetPath}Nike_Air_1/Nike_Air_1_Gray_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_02.avif',
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_03.avif',
    ],
    8: [
      '${config.imageAssetPath}Nike_Air_1/Nike_Air_1_White_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_02.avif',
      // '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_03.avif',
    ],
    9: [
      '${config.imageAssetPath}Nike_Pegasus/Nike_Pegasus_Black_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_Black_02.avif',
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_Black_03.avif',
    ],
    10: [
      '${config.imageAssetPath}Nike_Pegasus/Nike_Pegasus_Gray_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_Gray_02.avif',
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_Gray_03.avif',
    ],
    11: [
      '${config.imageAssetPath}Nike_Pegasus/Nike_Pegasus_White_01.avif',
      // 현재 고객 화면에서 사용되지 않는 이미지 (향후 이미지 갤러리 기능 추가 시 사용 예정)
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_White_02.avif',
      // '${config.kImageAssetPath}Nike_Pegasus/Nike_Pegasus_White_03.avif',
    ],
  };
}

// ============================================
// 제품 데이터 (사이즈별 가격 정보)
// ============================================

/// 제품 더미 데이터 설정
/// 
/// ProductBase 인덱스별로 제조사 ID, 사이즈, 가격 정보를 정의합니다.
class DummyProducts {
  /// 제품 설정 정보
  /// 
  /// 키: ProductBase 인덱스 (0-based)
  /// 값: 제품 설정 정보
  ///   - mfid: 제조사 ID (Manufacturer 인덱스, 0-based)
  ///   - sizes: 사이즈 리스트
  ///   - basePrices: 사이즈별 기본 가격 리스트 (sizes와 순서 일치)
  ///   - quantity: 재고 수량
  static const Map<int, Map<String, dynamic>> productConfig = {
    // U740WN2 - Black (NewBalance)
    0: {
      'mfid': 1, // NewBalance
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [100000, 110000, 120000, 130000, 140000, 150000, 160000],
      'quantity': 30,
    },
    // U740WN2 - Gray (NewBalance)
    1: {
      'mfid': 1, // NewBalance
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [100500, 101500, 102500, 103500, 104500, 105500, 106500],
      'quantity': 30,
    },
    // U740WN2 - White (NewBalance)
    2: {
      'mfid': 1, // NewBalance
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [102000, 102100, 102200, 102300, 102400, 102500, 102600],
      'quantity': 30,
    },
    // 나이키 샥스 TL - Black (Nike)
    3: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [180000, 181000, 182000, 183000, 184000, 185000, 186000],
      'quantity': 30,
    },
    // 나이키 샥스 TL - Gray (Nike)
    4: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [118000, 123000, 128000, 133000, 138000, 143000, 148000],
      'quantity': 30,
    },
    // 나이키 샥스 TL - White (Nike)
    5: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [98000, 99500, 101000, 102500, 104000, 105500, 107000],
      'quantity': 30,
    },
    // 나이키 에어포스 1 - Black (Nike)
    6: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [102000, 103000, 104000, 105000, 106000, 107000, 108000],
      'quantity': 30,
    },
    // 나이키 에어포스 1 - Gray (Nike)
    7: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [175000, 178000, 181000, 184000, 187000, 190000, 193000],
      'quantity': 30,
    },
    // 나이키 에어포스 1 - White (Nike)
    8: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [135000, 140000, 145000, 150000, 155000, 160000, 165000],
      'quantity': 30,
    },
    // 나이키 페가수스 플러스 - Black (Nike)
    9: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [112000, 115000, 118000, 121000, 124000, 127000, 130000],
      'quantity': 30,
    },
    // 나이키 페가수스 플러스 - Gray (Nike)
    10: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [92000, 94000, 96000, 98000, 100000, 102000, 104000],
      'quantity': 30,
    },
    // 나이키 페가수스 플러스 - White (Nike)
    11: {
      'mfid': 0, // Nike
      'sizes': [220, 230, 240, 250, 260, 270, 280],
      'basePrices': [198000, 202000, 206000, 210000, 214000, 218000, 222000],
      'quantity': 30,
    },
  };
}

// ============================================
// 고객 데이터
// ============================================

/// 고객 더미 데이터
class DummyCustomers {
  /// 개발용 고객 데이터
  static const List<Map<String, dynamic>> development = [
    {
      'cEmail': 'jojo@han.com',
      'cPhoneNumber': '222-9898-1212',
      'cName': '조조',
      'cPassword': 'qwer1234',
    },
    {
      'cEmail': 'handbook@han.com',
      'cPhoneNumber': '999-7676-1987',
      'cName': '손책',
      'cPassword': 'qwer1234',
    },
    {
      'cEmail': 'bigear@han.com',
      'cPhoneNumber': '000-1234-5678',
      'cName': '유비',
      'cPassword': 'qwer1234',
    },
    {
      'cEmail': 'jangryo@han.com',
      'cPhoneNumber': '222-3452-7665',
      'cName': '장료',
      'cPassword': 'qwer1234',
    },
    {
      'cEmail': 'sixhand@han.com',
      'cPhoneNumber': '999-1010-2929',
      'cName': '육손',
      'cPassword': 'qwer1234',
    },
    {
      'cEmail': 'purpledraong@han.com',
      'cPhoneNumber': '000-0987-6543',
      'cName': '조자룡',
      'cPassword': 'qwer1234',
    },
  ];

  /// 테스트용 최소 고객 데이터
  static const List<Map<String, dynamic>> test = [
    {
      'cEmail': 'test@test.com',
      'cPhoneNumber': '010-1234-5678',
      'cName': '테스트 사용자',
      'cPassword': 'test1234',
    },
  ];
}

// ============================================
// 직원 데이터
// ============================================

/// 직원 더미 데이터
class DummyEmployees {
  /// 개발용 직원 데이터
  static const List<Map<String, dynamic>> development = [
    {
      'eEmail': 'ma@han.com',
      'ePhoneNumber': '222-6789-5432',
      'eName': '사마의',
      'ePassword': 'qwer1234',
      'eRole': '1',
    },
    {
      'eEmail': 'oiling@han.com',
      'ePhoneNumber': '999-3211-0987',
      'eName': '주유',
      'ePassword': 'qwer1234',
      'eRole': '2',
    },
    {
      'eEmail': 'gongmyeong@han.com',
      'ePhoneNumber': '000-0987-6543',
      'eName': '제갈공명',
      'ePassword': 'qwer1234',
      'eRole': '3',
    },
  ];

  /// 테스트용 최소 직원 데이터
  static const List<Map<String, dynamic>> test = [
    {
      'eEmail': 'admin@test.com',
      'ePhoneNumber': '010-9999-9999',
      'eName': '테스트 관리자',
      'ePassword': 'admin1234',
      'eRole': '1',
    },
  ];
}

// ============================================
// 주문 데이터
// ============================================

/// 주문 더미 데이터
/// 
/// 주의: cid는 Customer 인덱스(0-based)를 사용합니다.
/// 실제 삽입 시 Customer ID로 변환됩니다.
class DummyPurchases {
  /// 개발용 주문 데이터
  /// 
  /// cid: Customer 인덱스 (0-based)
  static const List<Map<String, dynamic>> development = [
    {
      'cid': 0, // 조조
      'pickupDate': '2025-12-13 07:20',
      'orderCode': 'ORDER-001',
      'timeStamp': '2025-12-12 07:20',
    },
    {
      'cid': 0, // 조조
      'pickupDate': '2025-12-13 07:20',
      'orderCode': 'ORDER-002',
      'timeStamp': '2025-12-12 07:20',
    },
    {
      'cid': 0, // 조조
      'pickupDate': '2025-12-13 07:20',
      'orderCode': 'ORDER-003',
      'timeStamp': '2025-12-12 07:20',
    },
    {
      'cid': 0, // 조조
      'pickupDate': '2025-12-13 07:20',
      'orderCode': 'ORDER-004',
      'timeStamp': '2025-12-12 07:20',
    },
    {
      'cid': 0, // 조조
      'pickupDate': '2023-12-13 07:20',
      'orderCode': 'ORDER-005',
      'timeStamp': '2023-12-12 07:20',
    },
  ];
}

// ============================================
// 주문 항목 데이터
// ============================================

/// 주문 항목 더미 데이터
/// 
/// 주의: 
/// - pid: Product 인덱스 (0-based, ProductBase별 사이즈 순서)
/// - pcid: Purchase 인덱스 (0-based)
/// 실제 삽입 시 ID로 변환됩니다.
class DummyPurchaseItems {
  /// 개발용 주문 항목 데이터
  /// 
  /// pid: Product 인덱스 (0-based)
  /// pcid: Purchase 인덱스 (0-based)
  static List<Map<String, dynamic>> get development => [
    {
      'pid': 0, // ProductBase 0의 첫 번째 사이즈 (220)
      'pcid': 0, // ORDER-001
      'pcQuantity': 10,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
    {
      'pid': 1, // ProductBase 0의 두 번째 사이즈 (230)
      'pcid': 1, // ORDER-002
      'pcQuantity': 3,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
    {
      'pid': 2, // ProductBase 0의 세 번째 사이즈 (240)
      'pcid': 1, // ORDER-002
      'pcQuantity': 6,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
    {
      'pid': 7, // ProductBase 1의 첫 번째 사이즈 (220)
      'pcid': 2, // ORDER-003
      'pcQuantity': 1,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
    {
      'pid': 8, // ProductBase 1의 두 번째 사이즈 (230)
      'pcid': 3, // ORDER-004
      'pcQuantity': 9,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
    {
      'pid': 9, // ProductBase 1의 세 번째 사이즈 (240)
      'pcid': 4, // ORDER-005
      'pcQuantity': 11,
      'pcStatus': config.pickupStatus[1], // 제품 준비 완료
    },
  ];
}

// ============================================
// 로그인 이력 데이터
// ============================================

/// 로그인 이력 더미 데이터
/// 
/// 주의: cid는 Customer 인덱스(0-based)를 사용합니다.
class DummyLoginHistories {
  /// 개발용 로그인 이력 데이터
  /// 
  /// cid: Customer 인덱스 (0-based)
  static List<Map<String, dynamic>> get development => [
    {
      'cid': 0, // 조조
      'loginTime': '2025-12-12 17:05',
      'lStatus': '0',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
    {
      'cid': 1, // 손책
      'loginTime': '2025-12-12 19:05',
      'lStatus': '0',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
    {
      'cid': 2, // 유비
      'loginTime': '2025-12-12 19:20',
      'lStatus': '0',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
    {
      'cid': 3, // 장료
      'loginTime': '2023-12-12 19:20',
      'lStatus': '0',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
    {
      'cid': 4, // 육손
      'loginTime': '2025-12-12 07:20',
      'lStatus': '2',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
    {
      'cid': 5, // 조자룡
      'loginTime': '2023-12-12 07:20',
      'lStatus': '1',
      'lAddress': config.district[0], // 강남구
      'lPaymentMethod': 'KaKaoPay',
    },
  ];
}

