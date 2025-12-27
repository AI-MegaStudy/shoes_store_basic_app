# 데이터베이스 스키마 및 테이블 관계 문서

**작성일**: 2025-12-13  
**목적**: 데이터베이스 테이블 구조, 관계, 모델 정보를 정리한 참조 문서

---

## 📊 데이터베이스 관계도

```
Customer (고객)
  ├─ id (PK)
  ├─ cEmail
  ├─ cPhoneNumber
  ├─ cName
  └─ cPassword
  │
  ├─ Purchase (주문) - 1:N
  │   ├─ id (PK)
  │   ├─ cid (FK → Customer.id)
  │   ├─ pickupDate
  │   ├─ orderCode
  │   └─ timeStamp
  │   │
  │   └─ PurchaseItem (주문 항목) - 1:N
  │       ├─ id (PK)
  │       ├─ pid (FK → Product.id)
  │       ├─ pcid (FK → Purchase.id)
  │       ├─ pcQuantity
  │       └─ pcStatus
  │
  └─ LoginHistory (로그인 이력) - 1:N
      ├─ id (PK)
      ├─ cid (FK → Customer.id)
      ├─ loginTime
      ├─ lStatus
      ├─ lVersion
      ├─ lAddress
      └─ lPaymentMethod

Employee (직원/관리자)
  ├─ id (PK)
  ├─ eEmail
  ├─ ePhoneNumber
  ├─ eName
  ├─ ePassword
  └─ eRole

Product (제품)
  ├─ id (PK)
  ├─ pbid (FK → ProductBase.id)
  ├─ mfid (FK → Manufacturer.id)
  ├─ size
  ├─ basePrice
  └─ pQuantity
  │
  └─ PurchaseItem (주문 항목) - 1:N

ProductBase (제품 기본 정보)
  ├─ id (PK)
  ├─ pName
  ├─ pDescription
  ├─ pColor
  ├─ pGender
  ├─ pStatus
  ├─ pFeatureType
  ├─ pCategory
  └─ pModelNumber
  │
  ├─ Product (제품) - 1:N
  └─ ProductImage (제품 이미지) - 1:N
      ├─ id (PK)
      ├─ pbid (FK → ProductBase.id)
      └─ imagePath

Manufacturer (제조사)
  ├─ id (PK)
  └─ mName
  │
  └─ Product (제품) - 1:N
```

---

## 📋 테이블 상세 정보

### 1. Customer (고객)

**설명**: 고객 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 고객 ID | PRIMARY KEY, AUTOINCREMENT |
| cEmail | TEXT | 이메일 주소 | UNIQUE (비즈니스 로직) |
| cPhoneNumber | TEXT | 전화번호 | UNIQUE (비즈니스 로직) |
| cName | TEXT | 고객 이름 | |
| cPassword | TEXT | 비밀번호 (해시) | |

**관계**:
- `Purchase.cid` → `Customer.id` (1:N)
- `LoginHistory.cid` → `Customer.id` (1:N)

**인덱스**:
- `idx_customer_email`: 이메일로 빠른 조회
- `idx_customer_phone`: 전화번호로 빠른 조회

**모델**: `lib/model/customer.dart`

---

### 2. Employee (직원/관리자)

**설명**: 직원 및 관리자 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 직원 ID | PRIMARY KEY, AUTOINCREMENT |
| eEmail | TEXT | 이메일 주소 | UNIQUE (비즈니스 로직) |
| ePhoneNumber | TEXT | 전화번호 | UNIQUE (비즈니스 로직) |
| eName | TEXT | 직원 이름 | |
| ePassword | TEXT | 비밀번호 (해시) | |
| eRole | TEXT | 역할 (예: '대리점장', '본사 임원') | |

**관계**:
- 없음 (현재는 본사가 모든 재고를 관리)

**인덱스**:
- `idx_employee_email`: 이메일로 빠른 조회
- `idx_employee_phone`: 전화번호로 빠른 조회
- `idx_employee_role`: 역할별 조회

**모델**: `lib/model/employee.dart`

---

### 3. Purchase (주문)

**설명**: 고객의 주문 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 주문 ID | PRIMARY KEY, AUTOINCREMENT |
| cid | INTEGER | 고객 ID | FOREIGN KEY → Customer.id |
| pickupDate | TEXT | 픽업 날짜 (ISO8601 형식) | |
| orderCode | TEXT | 주문 코드 (고유 식별자) | UNIQUE (비즈니스 로직) |
| timeStamp | TEXT | 주문 시간 (ISO8601 형식) | |

**관계**:
- `Purchase.cid` → `Customer.id` (N:1)
- `PurchaseItem.pcid` → `Purchase.id` (1:N)

**인덱스**:
- `idx_purchase_cid`: 고객별 주문 조회
- `idx_purchase_order_code`: 주문 코드로 빠른 조회

**모델**: `lib/model/sale/purchase.dart`

---

### 4. PurchaseItem (주문 항목)

**설명**: 주문에 포함된 각 제품의 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 주문 항목 ID | PRIMARY KEY, AUTOINCREMENT |
| pid | INTEGER | 제품 ID | FOREIGN KEY → Product.id |
| pcid | INTEGER | 주문 ID | FOREIGN KEY → Purchase.id |
| pcQuantity | INTEGER | 구매 수량 | |
| pcStatus | TEXT | 주문 상태 | |

**상태값 (pcStatus)**:
- `'결제 대기'`: 결제 대기 중
- `'Onway'`: 배송 중
- `'Waiting for transaction'`: 거래 대기 중
- `'complete'`: 완료 (픽업 가능)
- `'return request'`: 반품 신청
- `'return done'`: 반품 완료

**관계**:
- `PurchaseItem.pid` → `Product.id` (N:1)
- `PurchaseItem.pcid` → `Purchase.id` (N:1)

**인덱스**:
- `idx_purchase_item_pcid`: 주문별 항목 조회
- `idx_purchase_item_pid`: 제품별 주문 항목 조회
- `idx_purchase_item_status`: 상태별 조회

**모델**: `lib/model/sale/purchase_item.dart`

---

### 5. Product (제품)

**설명**: 제품의 사이즈, 가격, 재고 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 제품 ID | PRIMARY KEY, AUTOINCREMENT |
| pbid | INTEGER | ProductBase ID | FOREIGN KEY → ProductBase.id |
| mfid | INTEGER | 제조사 ID | FOREIGN KEY → Manufacturer.id |
| size | INTEGER | 사이즈 (220, 230, 240 등) | |
| basePrice | INTEGER | 기본 가격 | |
| pQuantity | INTEGER | 재고 수량 | |

**관계**:
- `Product.pbid` → `ProductBase.id` (N:1)
- `Product.mfid` → `Manufacturer.id` (N:1)
- `PurchaseItem.pid` → `Product.id` (1:N)

**인덱스**:
- `idx_product_pbid`: ProductBase별 제품 조회
- `idx_product_mfid`: 제조사별 제품 조회

**모델**: `lib/model/product/product.dart`

---

### 6. ProductBase (제품 기본 정보)

**설명**: 제품의 기본 정보(이름, 색상, 카테고리 등)를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | ProductBase ID | PRIMARY KEY, AUTOINCREMENT |
| pName | TEXT | 제품명 (예: 'U740WN2', '나이키 샥스 TL') | |
| pDescription | TEXT | 제품 설명 | |
| pColor | TEXT | 색상 (예: 'Black', 'Gray', 'White') | |
| pGender | TEXT | 성별 (예: 'Unisex', 'Male', 'Female') | |
| pStatus | TEXT | 상태 (예: 'active', 'coming soon', 'inactive') | |
| pFeatureType | TEXT | 특징 타입 | |
| pCategory | TEXT | 카테고리 (예: 'Running', 'Sneakers') | |
| pModelNumber | TEXT | 모델 번호 | |

**관계**:
- `Product.pbid` → `ProductBase.id` (1:N)
- `ProductImage.pbid` → `ProductBase.id` (1:N)

**모델**: `lib/model/product/product_base.dart`

---

### 7. Manufacturer (제조사)

**설명**: 제조사 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 제조사 ID | PRIMARY KEY, AUTOINCREMENT |
| mName | TEXT | 제조사명 (예: '나이키', '뉴발란스') | |

**관계**:
- `Product.mfid` → `Manufacturer.id` (1:N)

**모델**: `lib/model/product/manufacturer.dart`

---

### 8. ProductImage (제품 이미지)

**설명**: 제품의 이미지 경로를 저장하는 테이블입니다. 하나의 ProductBase에 여러 이미지를 저장할 수 있습니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 이미지 ID | PRIMARY KEY, AUTOINCREMENT |
| pbid | INTEGER | ProductBase ID | FOREIGN KEY → ProductBase.id |
| imagePath | TEXT | 이미지 경로 (assets 경로) | |

**관계**:
- `ProductImage.pbid` → `ProductBase.id` (N:1)

**인덱스**:
- `idx_product_image_pbid`: ProductBase별 이미지 조회

**모델**: `lib/model/product/product_image.dart`

---

### 9. LoginHistory (로그인 이력)

**설명**: 고객의 로그인 이력을 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INTEGER | 로그인 이력 ID | PRIMARY KEY, AUTOINCREMENT |
| cid | INTEGER | 고객 ID | FOREIGN KEY → Customer.id |
| loginTime | TEXT | 로그인 시간 (ISO8601 형식) | |
| lStatus | TEXT | 회원 상태 (예: '활동 회원', '휴면 회원') | |
| lVersion | REAL | 앱 버전 | |
| lAddress | TEXT | 주소 | |
| lPaymentMethod | TEXT | 결제 수단 | |

**관계**:
- `LoginHistory.cid` → `Customer.id` (N:1)

**인덱스**:
- `idx_login_history_cid`: 고객별 로그인 이력 조회

**모델**: `lib/model/login_history.dart`

---

---

## 🔗 주요 조인 패턴

### 1. 주문 상세 정보 조회

```sql
SELECT 
  Purchase.*,
  Customer.cName,
  Customer.cEmail,
  Customer.cPhoneNumber,
  PurchaseItem.*,
  Product.size,
  Product.basePrice,
  ProductBase.pName,
  ProductBase.pColor,
  Manufacturer.mName,
  ProductImage.imagePath
FROM Purchase
JOIN Customer ON Purchase.cid = Customer.id
JOIN PurchaseItem ON Purchase.id = PurchaseItem.pcid
JOIN Product ON PurchaseItem.pid = Product.id
JOIN ProductBase ON Product.pbid = ProductBase.id
JOIN Manufacturer ON Product.mfid = Manufacturer.id
LEFT JOIN ProductImage ON ProductBase.id = ProductImage.pbid
WHERE Purchase.id = ?
```

### 2. 고객별 주문 목록 조회

```sql
SELECT 
  Purchase.*,
  COUNT(PurchaseItem.id) as itemCount,
  SUM(Product.basePrice * PurchaseItem.pcQuantity) as totalPrice
FROM Purchase
JOIN Customer ON Purchase.cid = Customer.id
LEFT JOIN PurchaseItem ON Purchase.id = PurchaseItem.pcid
LEFT JOIN Product ON PurchaseItem.pid = Product.id
WHERE Purchase.cid = ?
GROUP BY Purchase.id
ORDER BY Purchase.timeStamp DESC
```

### 3. 제품 상세 정보 조회

```sql
SELECT 
  Product.*,
  ProductBase.pName,
  ProductBase.pDescription,
  ProductBase.pColor,
  ProductBase.pCategory,
  Manufacturer.mName,
  ProductImage.imagePath
FROM Product
JOIN ProductBase ON Product.pbid = ProductBase.id
JOIN Manufacturer ON Product.mfid = Manufacturer.id
LEFT JOIN ProductImage ON ProductBase.id = ProductImage.pbid
WHERE Product.id = ?
```

---

## 📌 핸들러 사용 가이드

### 기본 CRUD 작업

각 테이블별 핸들러는 `lib/database/` 폴더에 있습니다:

- `CustomerHandler`: 고객 정보 관리
- `EmployeeHandler`: 직원 정보 관리
- `PurchaseHandler`: 주문 정보 관리
- `PurchaseItemHandler`: 주문 항목 관리
- `ProductHandler`: 제품 정보 관리
- `ProductBaseHandler`: 제품 기본 정보 관리
- `ManufacturerHandler`: 제조사 정보 관리
- `ProductImageHandler`: 제품 이미지 관리
- `LoginHistoryHandler`: 로그인 이력 관리

**참고**: 
- 재고 관리는 `Product.pQuantity`로 본사가 중앙 관리합니다.
- 대리점별 재고 관리 기능은 현재 미구현입니다.

### 복합 조인 쿼리

복잡한 조인 쿼리는 `PurchaseService`를 사용합니다:

- `queryOrderDetail()`: 주문 상세 정보 (전체 조인)
- `queryOrderListByCustomer()`: 고객별 주문 목록
- `queryOrderListWithItems()`: 주문 + 모든 항목
- `queryReturnableOrders()`: 반품 가능한 주문 목록

---

## 🔍 인덱스 활용

모든 인덱스는 조인 쿼리 성능 향상을 위해 자동으로 활용됩니다:

- **고객별 조회**: `idx_purchase_cid`, `idx_customer_email`
- **주문별 항목 조회**: `idx_purchase_item_pcid`
- **제품별 조회**: `idx_product_pbid`, `idx_product_mfid`
- **상태별 조회**: `idx_purchase_item_status`

---

**문서 버전**: 1.1  
**최종 수정일**: 2025-12-17

---

## 📝 변경 이력

### 2025-12-17
- **Retail 테이블 제거**: 현재 로직에서는 사용되지 않음
  - 재고 관리는 `Product.pQuantity`로 본사가 중앙 관리
  - 대리점별 재고 관리 기능은 미구현
  - 관련 관계도 및 테이블 설명 제거

