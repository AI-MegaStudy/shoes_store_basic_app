# 데이터베이스 핸들러 사용 가이드

**작성일**: 2025-12-17  
**목적**: 데이터베이스 핸들러 시스템의 사용법과 베스트 프랙티스를 제공

---

## 📋 목차

1. [개요](#개요)
2. [시스템 아키텍처](#시스템-아키텍처)
3. [초기 설정](#초기-설정)
4. [기본 사용법](#기본-사용법)
5. [CRUD 작업](#crud-작업)
6. [조인 쿼리](#조인-쿼리)
7. [PurchaseService 사용](#purchaseservice-사용)
8. [에러 처리](#에러-처리)
9. [베스트 프랙티스](#베스트-프랙티스)
10. [실제 사용 예제](#실제-사용-예제)

---

## 개요

데이터베이스 핸들러 시스템은 SQLite 데이터베이스와의 상호작용을 위한 구조화된 접근 방식을 제공합니다.

### 주요 특징

- ✅ **테이블별 핸들러**: 각 테이블에 전용 핸들러 클래스
- ✅ **타입 안정성**: Dart 타입 시스템 활용
- ✅ **조인 쿼리 지원**: 복잡한 관계형 데이터 조회
- ✅ **에러 처리**: 명확한 에러 핸들링
- ✅ **한글 주석**: 모든 메서드와 로직에 상세한 한글 주석

---

## 시스템 아키텍처

```
DatabaseManager (DB 초기화 및 관리)
    ↓
Handler (테이블별 CRUD 작업)
    ↓
Service (복합 조인 쿼리)
```

### 핸들러 목록

다음 10개의 핸들러가 제공됩니다:

1. **CustomerHandler** - 고객 정보 관리
2. **EmployeeHandler** - 직원/관리자 정보 관리
3. **ProductHandler** - 제품 정보 관리
4. **ProductBaseHandler** - 제품 기본 정보 관리
5. **ManufacturerHandler** - 제조사 정보 관리
6. **ProductImageHandler** - 제품 이미지 관리
7. **PurchaseHandler** - 주문 정보 관리
8. **PurchaseItemHandler** - 주문 항목 관리
9. **LoginHistoryHandler** - 로그인 이력 관리

**참고**: 
- 재고 관리는 `Product.pQuantity`로 본사가 중앙 관리합니다.
- `RetailHandler`는 현재 미사용입니다 (대리점별 재고 관리 기능 미구현).

---

## 초기 설정

### 1. main.dart에서 데이터베이스 초기화

```dart
Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 초기화
  final dbManager = DatabaseManager();
  await dbManager.initializeDB();

  // 더미 데이터 삽입 (선택사항)
  final dummyDataSetting = DummyDataSetting();
  await dummyDataSetting.insertAllDummyData();
  
  runApp(const MyApp());
}
```

**중요 사항**:
- `DatabaseManager.initializeDB()`는 앱 시작 시 한 번만 호출
- 모든 테이블과 인덱스를 자동으로 생성
- 싱글톤 패턴으로 동일한 DB 인스턴스 반환

---

## 기본 사용법

### 핸들러 인스턴스 생성

각 핸들러는 독립적으로 사용 가능합니다:

```dart
// 방법 1: 클래스 필드로 선언 (권장)
class _MyWidgetState extends State<MyWidget> {
  final CustomerHandler _customerHandler = CustomerHandler();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final customers = await _customerHandler.queryAll();
    // ...
  }
}

// 방법 2: 필요할 때마다 생성
Future<void> loadCustomer(int id) async {
  final handler = CustomerHandler();
  final customer = await handler.queryById(id);
  // ...
}
```

**권장**: StatefulWidget에서는 클래스 필드로 선언하여 재사용하는 것이 효율적입니다.

---

## CRUD 작업

### Create (생성)

```dart
final customerHandler = CustomerHandler();

// Customer 객체 생성
final newCustomer = Customer(
  cName: '홍길동',
  cEmail: 'hong@example.com',
  cPhoneNumber: '010-1234-5678',
  cPassword: 'password123',
);

// DB에 저장 (생성된 ID 반환)
final customerId = await customerHandler.insertData(newCustomer);
print('생성된 고객 ID: $customerId');
```

**주의사항**:
- `insertData`는 생성된 레코드의 ID를 반환합니다 (0이면 실패)
- 모델 객체의 `id` 필드는 자동 생성되므로 설정하지 않아도 됩니다

### Read (조회)

#### 전체 조회

```dart
final customerHandler = CustomerHandler();

// 모든 고객 조회
final allCustomers = await customerHandler.queryAll();
for (final customer in allCustomers) {
  print('고객명: ${customer.cName}, 이메일: ${customer.cEmail}');
}
```

#### ID로 조회

```dart
final customerHandler = CustomerHandler();

// 특정 ID의 고객 조회
final customer = await customerHandler.queryById(1);
if (customer != null) {
  print('고객명: ${customer.cName}');
} else {
  print('고객을 찾을 수 없습니다.');
}
```

#### 조건부 조회

각 핸들러는 테이블 특성에 맞는 조회 메서드를 제공합니다:

```dart
final customerHandler = CustomerHandler();

// 이메일로 조회
final customer = await customerHandler.queryByEmail('hong@example.com');

// 전화번호로 조회
final customer = await customerHandler.queryByPhoneNumber('010-1234-5678');
```

#### 고객별 주문 조회 예제

```dart
final purchaseHandler = PurchaseHandler();

// 특정 고객의 모든 주문 조회
final orders = await purchaseHandler.queryByCustomerId(customerId);
for (final order in orders) {
  print('주문 코드: ${order.orderCode}');
  print('주문 날짜: ${order.timeStamp}');
}
```

### Update (수정)

```dart
final customerHandler = CustomerHandler();

// 1. 먼저 조회
final customer = await customerHandler.queryById(1);
if (customer == null) {
  print('고객을 찾을 수 없습니다.');
  return;
}

// 2. 수정할 내용 반영
final updatedCustomer = Customer(
  id: customer.id,  // ID는 필수!
  cName: '홍길동 (수정됨)',
  cEmail: customer.cEmail,
  cPhoneNumber: customer.cPhoneNumber,
  cPassword: customer.cPassword,
);

// 3. DB 업데이트 (영향받은 행 수 반환, 0이면 실패)
final affectedRows = await customerHandler.updateData(updatedCustomer);
if (affectedRows > 0) {
  print('고객 정보가 수정되었습니다.');
}
```

**중요**: `updateData`는 `id` 필드가 필수입니다. ID가 없으면 업데이트할 레코드를 찾을 수 없습니다.

### Delete (삭제)

```dart
final customerHandler = CustomerHandler();

// ID로 삭제 (삭제된 행 수 반환, 0이면 실패)
final deletedRows = await customerHandler.deleteData(1);
if (deletedRows > 0) {
  print('고객이 삭제되었습니다.');
}
```

---

## 조인 쿼리

여러 테이블의 데이터를 함께 조회할 때는 조인 쿼리 메서드를 사용합니다.

### PurchaseHandler의 조인 쿼리

```dart
final purchaseHandler = PurchaseHandler();

// 주문 + 고객 정보 조회
final purchaseWithCustomer = await purchaseHandler.queryWithCustomer(purchaseId);
if (purchaseWithCustomer != null) {
  print('주문 코드: ${purchaseWithCustomer['orderCode']}');
  print('고객명: ${purchaseWithCustomer['cName']}');
  print('고객 이메일: ${purchaseWithCustomer['cEmail']}');
  print('고객 전화번호: ${purchaseWithCustomer['cPhoneNumber']}');
}

// 고객별 주문 목록 + 고객 정보 조회
final ordersWithCustomer = await purchaseHandler.queryListWithCustomer(customerId);
for (final order in ordersWithCustomer) {
  print('주문 코드: ${order['orderCode']}');
  print('고객명: ${order['cName']}');
}
```

### PurchaseItemHandler의 조인 쿼리

```dart
final purchaseItemHandler = PurchaseItemHandler();

// 주문 항목 + 제품 정보 조회
final itemsWithProduct = await purchaseItemHandler.queryItemsWithProductDetails(purchaseId);
for (final item in itemsWithProduct) {
  print('제품명: ${item['pName']}');
  print('수량: ${item['pcQuantity']}');
  print('상태: ${item['pcStatus']}');
}
```

### ProductHandler의 조인 쿼리

```dart
final productHandler = ProductHandler();

// 제품 + 제품 기본 정보 + 제조사 정보 조회
final productsWithDetails = await productHandler.queryWithDetails(productBaseId);
for (final product in productsWithDetails) {
  print('제품명: ${product['pName']}');
  print('제조사: ${product['mName']}');
  print('사이즈: ${product['size']}');
  print('색상: ${product['pColor']}');
}
```

---

## PurchaseService 사용

복잡한 다중 테이블 조인 쿼리는 `PurchaseService`를 사용합니다.

### 주문 상세 정보 조회 (전체 조인)

```dart
final purchaseService = PurchaseService();

// Purchase + Customer + PurchaseItem + Product + ProductBase + Manufacturer + 이미지
final orderDetail = await purchaseService.queryOrderDetail(purchaseId);

if (orderDetail == null) {
  print('주문을 찾을 수 없습니다.');
  return;
}

// Purchase 정보
final purchase = orderDetail['purchase'] as Map<String, dynamic>;
print('주문 코드: ${purchase['orderCode']}');
print('주문 날짜: ${purchase['timeStamp']}');
print('픽업 날짜: ${purchase['pickupDate']}');

// Customer 정보
final customer = orderDetail['customer'] as Map<String, dynamic>;
print('고객명: ${customer['cName']}');
print('이메일: ${customer['cEmail']}');

// 주문 항목 리스트
final items = orderDetail['items'] as List<Map<String, dynamic>>;
for (final item in items) {
  final purchaseItem = item['purchaseItem'] as Map<String, dynamic>;
  final productBase = item['productBase'] as Map<String, dynamic>;
  final manufacturer = item['manufacturer'] as Map<String, dynamic>;
  
  print('제품명: ${productBase['pName']}');
  print('제조사: ${manufacturer['mName']}');
  print('수량: ${purchaseItem['pcQuantity']}');
  print('상태: ${purchaseItem['pcStatus']}');
  print('이미지: ${item['imagePath']}');
}
```

### 고객별 주문 목록 조회

```dart
final purchaseService = PurchaseService();

// 고객의 모든 주문을 항목 정보와 함께 조회
final orders = await purchaseService.queryOrderListByCustomer(customerId);

for (final order in orders) {
  final purchase = order['purchase'] as Purchase;
  final items = order['items'] as List<Map<String, dynamic>>;
  
  print('주문 코드: ${purchase.orderCode}');
  print('주문 항목 수: ${items.length}');
  
  for (final item in items) {
    final productBase = item['productBase'] as Map<String, dynamic>;
    print('  - ${productBase['pName']}');
  }
}
```

### 반품 가능한 주문 조회

```dart
final purchaseService = PurchaseService();

// 반품 가능한 주문 목록 조회 (30일 이내, 제품 수령 완료 상태)
final returnableOrders = await purchaseService.queryReturnableOrders(customerId);

for (final order in returnableOrders) {
  final purchase = order['purchase'] as Purchase;
  final items = order['items'] as List<PurchaseItem>;
  
  print('주문 코드: ${purchase.orderCode}');
  print('반품 가능 항목 수: ${items.length}');
}
```

---

## 에러 처리

### 기본 패턴

```dart
Future<void> loadCustomer(int id) async {
  try {
    final customerHandler = CustomerHandler();
    final customer = await customerHandler.queryById(id);
    
    if (customer == null) {
      // 데이터가 없는 경우
      AppLogger.w('고객을 찾을 수 없습니다. ID: $id', tag: 'CustomerHandler');
      // 사용자에게 메시지 표시
      Get.snackbar(
        '오류',
        '고객 정보를 찾을 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // 정상 처리
    print('고객명: ${customer.cName}');
    
  } catch (e, stackTrace) {
    // 예외 처리 (네트워크, DB 연결 오류 등)
    AppLogger.e(
      '고객 조회 실패',
      error: e,
      stackTrace: stackTrace,
      tag: 'CustomerHandler',
    );
    
    Get.snackbar(
      '오류',
      '고객 정보를 불러오는 중 오류가 발생했습니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
    );
  }
}
```

### Insert/Update/Delete 결과 확인

```dart
// Insert
final customerId = await customerHandler.insertData(newCustomer);
if (customerId == 0) {
  AppLogger.e('고객 생성 실패', tag: 'CustomerHandler');
  // 에러 처리
  return;
}

// Update
final affectedRows = await customerHandler.updateData(updatedCustomer);
if (affectedRows == 0) {
  AppLogger.w('고객 정보가 업데이트되지 않았습니다. ID가 올바른지 확인하세요.', tag: 'CustomerHandler');
  // 에러 처리
  return;
}

// Delete
final deletedRows = await customerHandler.deleteData(customerId);
if (deletedRows == 0) {
  AppLogger.w('고객이 삭제되지 않았습니다. ID가 올바른지 확인하세요.', tag: 'CustomerHandler');
  // 에러 처리
  return;
}
```

### 명시적 조건 체크 (try-catch 대신)

```dart
// ❌ 나쁜 예: try-catch로 모든 것을 감싸기
try {
  final customer = await customerHandler.queryById(id);
  if (customer == null) {
    // 데이터가 없는 것은 예외가 아님
  }
} catch (e) {
  // 불필요한 try-catch
}

// ✅ 좋은 예: 명시적 조건 체크
final customer = await customerHandler.queryById(id);
if (customer == null) {
  AppLogger.w('고객을 찾을 수 없습니다. ID: $id', tag: 'CustomerHandler');
  // 데이터가 없는 경우 처리
  return;
}
// 정상 처리
```

**원칙**:
- `try-catch`는 네트워크나 DB 연결 오류 같은 **진짜 예외**에만 사용
- 데이터가 없는 경우는 `null` 체크로 처리
- 예상 가능한 조건은 `if-else`로 명시적으로 처리

---

## 베스트 프랙티스

### 1. 핸들러 인스턴스 관리

```dart
// ✅ 권장: StatefulWidget에서 클래스 필드로 선언
class _OrderListViewState extends State<OrderListView> {
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();
  
  // 재사용 가능
}

// ❌ 비권장: 매번 새로 생성
Future<void> loadOrder() async {
  final handler = PurchaseHandler(); // 매번 새 인스턴스 생성
  // ...
}
```

### 2. 비동기 작업 처리

```dart
// ✅ 권장: setState와 함께 사용
Future<void> _loadOrders() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final orders = await _purchaseHandler.queryAll();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    // 에러 처리
  }
}

// ❌ 주의: mounted 체크 (dispose 후 호출 방지)
Future<void> _loadData() async {
  final data = await _handler.queryAll();
  
  if (!mounted) return; // 위젯이 dispose된 경우
  
  setState(() {
    _data = data;
  });
}
```

### 3. 로깅 활용

```dart
// 개발 중 디버깅용
AppLogger.d('주문 목록 조회 시작', tag: 'OrderListView');
AppLogger.d('조회된 주문 수: ${orders.length}', tag: 'OrderListView');

// 경고 (예상 가능한 문제)
AppLogger.w('고객 정보를 찾을 수 없습니다. ID: $id', tag: 'CustomerHandler');

// 에러 (치명적인 문제)
AppLogger.e(
  '주문 조회 실패',
  error: e,
  stackTrace: stackTrace,
  tag: 'OrderListView',
);
```

### 4. 데이터 검증

```dart
// ✅ Insert 전 데이터 검증
final customer = Customer(
  cName: nameController.text.trim(),
  cEmail: emailController.text.trim(),
  cPhoneNumber: phoneController.text.trim(),
  cPassword: passwordController.text,
);

// 필수 필드 검증
if (customer.cName.isEmpty || customer.cEmail.isEmpty) {
  Get.snackbar('오류', '필수 정보를 모두 입력해주세요.');
  return;
}

// 이메일 형식 검증
if (!CustomCommonUtil.isEmail(customer.cEmail)) {
  Get.snackbar('오류', '올바른 이메일 형식이 아닙니다.');
  return;
}

// 중복 확인
final existing = await customerHandler.queryByEmail(customer.cEmail);
if (existing != null) {
  Get.snackbar('오류', '이미 등록된 이메일입니다.');
  return;
}

// 검증 통과 후 Insert
final customerId = await customerHandler.insertData(customer);
```

### 5. 트랜잭션 처리 (필요한 경우)

일반적인 CRUD 작업은 각 핸들러 메서드가 자동으로 처리하지만, 여러 작업을 하나의 트랜잭션으로 묶어야 할 때:

```dart
// 직접 DB 접근이 필요한 경우 (고급)
final db = await DatabaseManager().getDatabase();

await db.transaction((txn) async {
  // 여러 작업을 하나의 트랜잭션으로 실행
  await txn.insert('Purchase', purchase.toMap());
  for (final item in items) {
    await txn.insert('PurchaseItem', item.toMap());
  }
});
```

**주의**: 가능하면 핸들러 메서드를 사용하는 것이 권장됩니다.

---

## 실제 사용 예제

### 예제 1: 로그인 화면

```dart
class _LoginViewState extends State<LoginView> {
  final CustomerHandler _customerHandler = CustomerHandler();
  final LoginHistoryHandler _loginHistoryHandler = LoginHistoryHandler();
  
  Future<void> _handleLogin() async {
    final input = _idController.text.trim();
    final password = _passwordController.text.trim();
    
    try {
      Customer? customer;
      
      // 이메일 또는 전화번호로 조회
      if (CustomCommonUtil.isEmail(input)) {
        customer = await _customerHandler.queryByEmail(input);
      } else {
        customer = await _customerHandler.queryByPhoneNumber(input);
      }
      
      // 로그인 검증
      if (customer == null || customer.cPassword != password) {
        Get.snackbar('로그인 실패', '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.');
        return;
      }
      
      if (customer.id == null) {
        AppLogger.e('Customer ID가 null입니다', tag: 'Login');
        return;
      }
      
      // 로그인 성공 - 로그인 이력 저장
      final loginHistory = LoginHistory(
        cid: customer.id!,
        loginTime: DateTime.now().toIso8601String(),
      );
      await _loginHistoryHandler.insertData(loginHistory);
      
      // 사용자 정보 저장 및 화면 이동
      UserStorage.saveUserId(customer.id!);
      Get.offNamed('/searchview');
      
    } catch (e, stackTrace) {
      AppLogger.e('로그인 처리 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '로그인 처리 중 오류가 발생했습니다.');
    }
  }
}
```

### 예제 2: 주문 목록 화면

```dart
class _OrderListViewState extends State<OrderListView> {
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();
  
  List<Purchase> _orders = [];
  Map<int, String> _orderStatusMap = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }
  
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = UserStorage.getUserId();
      if (userId == null) {
        AppLogger.w('사용자 정보가 없습니다', tag: 'OrderListView');
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }
      
      // 고객별 주문 목록 조회
      final purchases = await _purchaseHandler.queryByCustomerId(userId);
      
      // 시간순 정렬
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      
      // 각 주문의 상태 계산
      final statusMap = <int, String>{};
      for (final purchase in purchases) {
        final items = await _purchaseItemHandler.queryByPurchaseId(purchase.id!);
        final status = OrderStatusUtils.determineOrderStatusForCustomer(
          items,
          purchase,
        );
        statusMap[purchase.id!] = status;
      }
      
      setState(() {
        _orders = purchases;
        _orderStatusMap = statusMap;
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      AppLogger.e('주문 목록 조회 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('오류', '주문 목록을 불러오는 중 오류가 발생했습니다.');
    }
  }
}
```

### 예제 3: 주문 상세 화면 (PurchaseService 사용)

```dart
class _OrderDetailViewState extends State<OrderDetailView> {
  final PurchaseService _purchaseService = PurchaseService();
  
  Map<String, dynamic>? _orderDetail;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }
  
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // PurchaseService로 전체 조인 조회
      final orderDetail = await _purchaseService.queryOrderDetail(purchaseId);
      
      if (orderDetail == null) {
        AppLogger.w('주문을 찾을 수 없습니다. ID: $purchaseId', tag: 'OrderDetailView');
        Get.snackbar('오류', '주문 정보를 찾을 수 없습니다.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _orderDetail = orderDetail;
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      AppLogger.e('주문 상세 조회 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('오류', '주문 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_orderDetail == null) {
      return const Center(child: Text('주문 정보를 찾을 수 없습니다.'));
    }
    
    final purchase = _orderDetail!['purchase'] as Map<String, dynamic>;
    final customer = _orderDetail!['customer'] as Map<String, dynamic>;
    final items = _orderDetail!['items'] as List<Map<String, dynamic>>;
    
    return ListView(
      children: [
        // 주문 정보 표시
        Text('주문 코드: ${purchase['orderCode']}'),
        Text('고객명: ${customer['cName']}'),
        
        // 주문 항목 표시
        ...items.map((item) {
          final productBase = item['productBase'] as Map<String, dynamic>;
          final purchaseItem = item['purchaseItem'] as Map<String, dynamic>;
          
          return ListTile(
            title: Text(productBase['pName']),
            subtitle: Text('수량: ${purchaseItem['pcQuantity']}'),
            leading: Image.asset(item['imagePath'] ?? ''),
          );
        }),
      ],
    );
  }
}
```

### 예제 4: 결제 화면 (Purchase 생성)

```dart
class _PurchaseViewState extends State<PurchaseView> {
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  final PurchaseItemHandler _purchaseItemHandler = PurchaseItemHandler();
  
  Future<void> _savePurchaseItemsToDb() async {
    // 현재 로그인한 사용자 ID 가져오기
    final userId = UserStorage.getUserId();
    if (userId == null) {
      AppLogger.e('로그인된 사용자 정보가 없습니다', tag: 'PurchaseView');
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }
    
    try {
      // 현재 시간과 다음날 계산
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      // Purchase 객체 생성
      final purchase = Purchase(
        cid: userId,
        timeStamp: now.toIso8601String(),
        pickupDate: tomorrow.toIso8601String().split('T').first,
        orderCode: OrderUtils.generateOrderCode(userId),
      );
      
      // Purchase를 DB에 저장
      final purchaseId = await _purchaseHandler.insertData(purchase);
      if (purchaseId == 0) {
        AppLogger.e('Purchase 저장 실패', tag: 'PurchaseView');
        throw Exception('주문 저장에 실패했습니다.');
      }
      
      // 장바구니의 모든 상품을 PurchaseItem으로 저장
      for (final cartItem in cart) {
        final item = PurchaseItem(
          pid: cartItem['productId'] as int,
          pcid: purchaseId,
          pcQuantity: cartItem['quantity'] as int,
          pcStatus: config.pickupStatus[0] ?? '제품 준비 중',
        );
        
        await _purchaseItemHandler.insertData(item);
      }
      
      AppLogger.d('주문 저장 완료. Purchase ID: $purchaseId', tag: 'PurchaseView');
      
      // 성공 메시지 및 화면 이동
      Get.snackbar('성공', '주문이 완료되었습니다.');
      Get.offNamed('/searchview');
      
    } catch (e, stackTrace) {
      AppLogger.e('주문 저장 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '주문 처리 중 오류가 발생했습니다.');
    }
  }
}
```

---

## 참고 자료

- **데이터베이스 스키마**: `specs/DATABASE_SCHEMA.md`
- **데이터베이스 가이드**: `specs/DATABASE_GUIDE.md`
- **쿼리 비교 가이드**: `specs/DB_QUERY_COMPARISON.md`

---

## 문의 및 지원

핸들러 사용 중 문제가 발생하거나 추가 기능이 필요한 경우, 다음을 확인하세요:

1. 각 핸들러 클래스의 한글 주석 확인
2. 모델 클래스의 `fromMap`/`toMap` 메서드 확인
3. 데이터베이스 스키마 문서 확인

---

**문서 버전**: 1.1  
**최종 수정일**: 2025-12-17

---

## 📝 변경 이력

### 2025-12-17
- **RetailHandler 제거**: 대리점별 재고 관리 기능이 미구현이므로 RetailHandler 관련 내용 제거
- **참고 자료 업데이트**: 삭제된 문서 참조 제거 및 현재 문서로 업데이트

