# 데이터베이스 가이드

**작성일**: 2025-12-17  
**목적**: 데이터베이스 구조, 핸들러 사용법, 쿼리 작성 가이드를 통합한 실용 가이드

---

## 📋 목차

1. [데이터베이스 구조](#데이터베이스-구조)
2. [초기 설정](#초기-설정)
3. [핸들러 사용법](#핸들러-사용법)
4. [쿼리 작성 가이드](#쿼리-작성-가이드)
5. [더미 데이터 사용법](#더미-데이터-사용법)
6. [베스트 프랙티스](#베스트-프랙티스)

---

## 데이터베이스 구조

### 테이블 관계도

```
Customer (고객)
  ├─ Purchase (주문) - 1:N
  │   └─ PurchaseItem (주문 항목) - 1:N
  │       └─ Product (제품) - N:1
  │           ├─ ProductBase (제품 기본 정보) - N:1
  │           │   └─ ProductImage (제품 이미지) - 1:N
  │           └─ Manufacturer (제조사) - N:1
  └─ LoginHistory (로그인 이력) - 1:N

Employee (직원/관리자)
  (재고 관리는 Product.pQuantity로 본사가 중앙 관리)
```

### 주요 테이블

| 테이블 | 설명 | 핸들러 |
|--------|------|--------|
| Customer | 고객 정보 | CustomerHandler |
| Employee | 직원/관리자 정보 | EmployeeHandler |
| Purchase | 주문 정보 | PurchaseHandler |
| PurchaseItem | 주문 항목 | PurchaseItemHandler |
| Product | 제품 (사이즈, 가격) | ProductHandler |
| ProductBase | 제품 기본 정보 | ProductBaseHandler |
| Manufacturer | 제조사 | ManufacturerHandler |
| ProductImage | 제품 이미지 | ProductImageHandler |
| LoginHistory | 로그인 이력 | LoginHistoryHandler |

**참고**: 
- 재고 관리는 `Product.pQuantity`로 본사가 중앙 관리합니다.
- 대리점별 재고 관리 기능은 현재 미구현입니다.

### 주요 관계

- **Customer → Purchase**: 한 고객이 여러 주문 가능 (1:N)
- **Purchase → PurchaseItem**: 한 주문에 여러 항목 가능 (1:N)
- **ProductBase → Product**: 한 제품 기본 정보에 여러 사이즈 가능 (1:N)
- **Product → PurchaseItem**: 한 제품이 여러 주문에 포함 가능 (1:N)

---

## 초기 설정

### main.dart에서 DB 초기화

```dart
Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage로 초기화 완료 여부 확인
  final storage = GetStorage();
  final isDBInitialized = storage.read<bool>(config.kStorageKeyDBInitialized) ?? false;

  if (!isDBInitialized) {
    // DatabaseManager 인스턴스
    final dbManager = DatabaseManager();
    
    // 기존 DB 연결 닫기 및 리셋
    await dbManager.closeAndReset();
    
    // 기존 DB 삭제 (개발 환경)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '${config.kDBName}${config.kDBFileExt}');
    await deleteDatabase(path);
    
    // DB 초기화
    await dbManager.initializeDB();

    // 더미 데이터 삽입
    final dummyDataSetting = DummyDataSetting();
    await dummyDataSetting.insertAllDummyData();
    
    // 초기화 완료 플래그 저장
    await storage.write(config.kStorageKeyDBInitialized, true);
  }
  
  runApp(const MyApp());
}
```

**중요 사항**:
- `DatabaseManager.initializeDB()`는 앱 시작 시 한 번만 호출
- GetStorage로 중복 초기화 방지
- 모든 테이블과 인덱스를 자동으로 생성
- 싱글톤 패턴으로 동일한 DB 인스턴스 반환

---

## 핸들러 사용법

### 기본 구조

```dart
class _MyScreenState extends State<MyScreen> {
  // 핸들러는 클래스 필드로 선언 (권장)
  final CustomerHandler _customerHandler = CustomerHandler();
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // 핸들러 사용
    final customers = await _customerHandler.queryAll();
  }
}
```

### CRUD 작업

#### Create (생성)

```dart
final customerHandler = CustomerHandler();

final newCustomer = Customer(
  cName: '홍길동',
  cEmail: 'hong@example.com',
  cPhoneNumber: '010-1234-5678',
  cPassword: 'password123',
);

// 생성된 ID 반환 (0이면 실패)
final customerId = await customerHandler.insertData(newCustomer);
```

#### Read (조회)

```dart
// 전체 조회
final customers = await customerHandler.queryAll();

// ID로 조회
final customer = await customerHandler.queryById(1);

// 조건부 조회
final customer = await customerHandler.queryByEmail('hong@example.com');
final orders = await purchaseHandler.queryByCustomerId(customerId);
```

#### Update (수정)

```dart
// 1. 먼저 조회
final customer = await customerHandler.queryById(1);
if (customer == null) return;

// 2. 수정할 내용 반영 (id 필수!)
final updatedCustomer = Customer(
  id: customer.id,  // 필수!
  cName: '홍길동 (수정됨)',
  cEmail: customer.cEmail,
  cPhoneNumber: customer.cPhoneNumber,
  cPassword: customer.cPassword,
);

// 3. 업데이트 (영향받은 행 수 반환, 0이면 실패)
final affectedRows = await customerHandler.updateData(updatedCustomer);
```

#### Delete (삭제)

```dart
// 삭제된 행 수 반환 (0이면 실패)
final deletedRows = await customerHandler.deleteData(customerId);
```

### 조인 쿼리

#### PurchaseHandler 조인 쿼리

```dart
// 주문 + 고객 정보
final purchaseWithCustomer = await purchaseHandler.queryWithCustomer(purchaseId);

// 고객별 주문 목록 + 고객 정보
final ordersWithCustomer = await purchaseHandler.queryListWithCustomer(customerId);
```

#### PurchaseItemHandler 조인 쿼리

```dart
// 주문 항목 + 제품 정보
final itemsWithProduct = await purchaseItemHandler.queryItemsWithProductDetails(purchaseId);
```

#### PurchaseService (복합 조인 쿼리)

```dart
final purchaseService = PurchaseService();

// 주문 상세 정보 (전체 조인)
final orderDetail = await purchaseService.queryOrderListWithItems(purchaseId);
// 반환: { 'purchase': {...}, 'items': [...] }

// 반품 가능한 주문 목록
final returnableOrders = await purchaseService.queryReturnableOrders(customerId);
```

---

## 쿼리 작성 가이드

### db.query vs db.rawQuery

| 항목 | `db.query` | `db.rawQuery` |
|------|-----------|---------------|
| **사용 시기** | 단일 테이블 조회 | 조인, 복잡한 쿼리 |
| **SQL Injection 방지** | 자동 | 수동 (`?` 플레이스홀더) |
| **가독성** | 높음 | 중간 |
| **유연성** | 제한적 | 매우 높음 |

### db.query 사용 예시

```dart
// ✅ 단일 테이블 조회 (권장)
final results = await db.query(
  'Customer',
  where: 'cEmail = ?',
  whereArgs: [email],
  orderBy: 'id ASC',
  limit: 10,
);
```

### db.rawQuery 사용 예시

```dart
// ✅ 조인 쿼리 (필수)
final results = await db.rawQuery('''
  SELECT 
    Purchase.*,
    Customer.cName,
    Customer.cEmail
  FROM Purchase
  JOIN Customer ON Purchase.cid = Customer.id
  WHERE Purchase.id = ?
''', [purchaseId]);  // ? 플레이스홀더로 SQL Injection 방지
```

**중요**: `rawQuery` 사용 시 반드시 `?` 플레이스홀더를 사용하여 SQL Injection을 방지해야 합니다.

---

## 더미 데이터 사용법

### 기본 사용

```dart
final dummyDataSetting = DummyDataSetting();
await dummyDataSetting.insertAllDummyData(); // DevelopmentDataSet 사용
```

### 특정 데이터 세트 사용

```dart
// 테스트용 데이터
await dummyDataSetting.insertDataSet(TestDataSet());

// 데모용 데이터
await dummyDataSetting.insertDataSet(DemoDataSet());
```

### 개별 데이터 삽입

```dart
// 제조사만 삽입
final manufacturerIds = await dummyDataSetting.insertManufacturers([
  {'mName': 'Nike'},
  {'mName': 'Adidas'},
]);
```

### 데이터 수정

더미 데이터는 `lib/database/dummy_data/dummy_data_constants.dart`에서 수정:

```dart
class DummyManufacturers {
  static List<Map<String, dynamic>> get data => [
    {'mName': 'Nike'},
    {'mName': 'NewBalance'},
    // 여기서 수정하면 전체에 반영
  ];
}
```

---

## 베스트 프랙티스

### 1. 핸들러 인스턴스 관리

```dart
// ✅ 권장: StatefulWidget에서 클래스 필드로 선언
class _MyScreenState extends State<MyScreen> {
  final CustomerHandler _customerHandler = CustomerHandler();
  
  // 재사용 가능
  Future<void> _loadData() async {
    final customers = await _customerHandler.queryAll();
  }
}
```

### 2. 에러 처리

```dart
// ✅ 좋은 예: 최상위 레벨 try-catch
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  try {
    final data = await _handler.queryAll();
    
    // 명시적 조건 체크
    if (data.isEmpty) {
      setState(() {
        _dataList = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _dataList = data;
      _isLoading = false;
    });
  } catch (e, stackTrace) {
    AppLogger.e('데이터 로드 실패', error: e, stackTrace: stackTrace);
    setState(() {
      _dataList = [];
      _isLoading = false;
    });
  }
}
```

### 3. null 체크

```dart
// ✅ 좋은 예: 명시적 null 체크
final customer = await customerHandler.queryById(id);
if (customer == null) {
  AppLogger.w('고객을 찾을 수 없습니다. ID: $id');
  return;
}

// ❌ 나쁜 예: 강제 언래핑
final name = customer!.cName; // 위험
```

### 4. 조인 쿼리 활용

```dart
// ✅ 좋은 예: 서비스 활용
final purchaseService = PurchaseService();
final orderDetail = await purchaseService.queryOrderListWithItems(purchaseId);
// 한 번의 조회로 모든 필요한 데이터 수집

// ❌ 나쁜 예: 여러 번 조회
final purchase = await purchaseHandler.queryById(purchaseId);
final items = await purchaseItemHandler.queryByPurchaseId(purchaseId);
final customer = await customerHandler.queryById(purchase.cid);
// 비효율적
```

### 5. Map 활용 (데이터 캐싱)

```dart
// ✅ 좋은 예: Map으로 효율적 관리
final statusMap = <int, String>{};
final customerMap = <int, String>{};

for (final purchase in purchases) {
  if (purchase.id == null) continue;
  
  // 상태 결정
  final items = await purchaseItemHandler.queryByPurchaseId(purchase.id!);
  final status = OrderStatusUtils.determineOrderStatusForAdmin(items, purchase);
  statusMap[purchase.id!] = status;
  
  // 고객명 캐싱
  if (purchase.cid != null) {
    final customer = await customerHandler.queryById(purchase.cid!);
    if (customer != null) {
      customerMap[purchase.id!] = customer.cName;
    }
  }
}
```

---

## 주요 인덱스

성능 향상을 위해 다음 인덱스가 자동으로 생성됩니다:

- `idx_purchase_cid`: 고객별 주문 조회
- `idx_purchase_item_pcid`: 주문별 항목 조회
- `idx_purchase_item_status`: 상태별 조회
- `idx_product_pbid`: ProductBase별 제품 조회
- `idx_customer_email`: 이메일로 빠른 조회
- `idx_customer_phone`: 전화번호로 빠른 조회

---

## 참고 문서

- 상세한 핸들러 사용법: `HANDLER_USAGE_GUIDE.md`
- 상세한 스키마 정보: `DATABASE_SCHEMA.md`
- 쿼리 비교 가이드: `DB_QUERY_COMPARISON.md`

---

**문서 버전**: 1.1  
**최종 수정일**: 2025-12-17

---

## 📝 변경 이력

### 2025-12-17
- **Retail 테이블 제거**: 현재 로직에서는 사용되지 않음
  - 재고 관리는 `Product.pQuantity`로 본사가 중앙 관리
  - 대리점별 재고 관리 기능은 미구현

