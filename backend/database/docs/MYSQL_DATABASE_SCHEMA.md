# MySQL 데이터베이스 스키마 및 테이블 관계 문서

**작성일**: 2025-12-28  
**기반**: `backend/database/schema.sql` (MySQL 8.0)  
**목적**: 데이터베이스 테이블 구조, 관계, 모델 정보를 정리한 참조 문서

---

## 📊 데이터베이스 관계도

```
Customer (고객)
  ├─ id (PK)
  ├─ cEmail
  ├─ cPhoneNumber
  ├─ cName
  ├─ cPassword
  └─ cProfileImage (MEDIUMBLOB) ← 추가됨
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
  ├─ eRole
  └─ eProfileImage (MEDIUMBLOB) ← 추가됨

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
| id | INT | 고객 ID | PRIMARY KEY, AUTO_INCREMENT |
| cEmail | VARCHAR(255) | 이메일 주소 | NOT NULL, UNIQUE |
| cPhoneNumber | VARCHAR(50) | 전화번호 | NOT NULL, UNIQUE |
| cName | VARCHAR(255) | 고객 이름 | NOT NULL |
| cPassword | VARCHAR(255) | 비밀번호 (해시) | NOT NULL |
| cProfileImage | MEDIUMBLOB | 프로필 이미지 | NULL |

**관계**:
- `Purchase.cid` → `Customer.id` (1:N, ON DELETE CASCADE)
- `LoginHistory.cid` → `Customer.id` (1:N, ON DELETE CASCADE)

**인덱스**:
- `idx_customer_email`: 이메일로 빠른 조회 (UNIQUE)
- `idx_customer_phone`: 전화번호로 빠른 조회 (UNIQUE)

---

### 2. Employee (직원/관리자)

**설명**: 직원 및 관리자 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 직원 ID | PRIMARY KEY, AUTO_INCREMENT |
| eEmail | VARCHAR(255) | 이메일 주소 | NOT NULL, UNIQUE |
| ePhoneNumber | VARCHAR(50) | 전화번호 | NOT NULL, UNIQUE |
| eName | VARCHAR(255) | 직원 이름 | NOT NULL |
| ePassword | VARCHAR(255) | 비밀번호 (해시) | NOT NULL |
| eRole | VARCHAR(100) | 역할 (예: '대리점장', '본사 임원') | |
| eProfileImage | MEDIUMBLOB | 프로필 이미지 | NULL |

**관계**:
- 없음 (현재는 본사가 모든 재고를 관리)
- 비즈니스 로직으로 Purchase/PurchaseItem 조회 가능

**인덱스**:
- `idx_employee_email`: 이메일로 빠른 조회 (UNIQUE)
- `idx_employee_phone`: 전화번호로 빠른 조회 (UNIQUE)
- `idx_employee_role`: 역할별 조회

---

### 3. Manufacturer (제조사)

**설명**: 제조사 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 제조사 ID | PRIMARY KEY, AUTO_INCREMENT |
| mName | VARCHAR(255) | 제조사명 (예: '나이키', '뉴발란스') | NOT NULL, UNIQUE |

**관계**:
- `Product.mfid` → `Manufacturer.id` (1:N, ON DELETE CASCADE)

**인덱스**:
- `idx_manufacturer_name`: 제조사명으로 빠른 조회 (UNIQUE)

---

### 4. ProductBase (제품 기본 정보)

**설명**: 제품의 기본 정보(이름, 색상, 카테고리 등)를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | ProductBase ID | PRIMARY KEY, AUTO_INCREMENT |
| pName | VARCHAR(255) | 제품명 (예: 'U740WN2', '나이키 샥스 TL') | NOT NULL |
| pDescription | TEXT | 제품 설명 | |
| pColor | VARCHAR(100) | 색상 (예: 'Black', 'Gray', 'White') | |
| pGender | VARCHAR(50) | 성별 (예: 'Unisex', 'Male', 'Female') | |
| pStatus | VARCHAR(100) | 상태 (예: 'active', 'coming soon', 'inactive') | |
| pFeatureType | VARCHAR(100) | 특징 타입 | |
| pCategory | VARCHAR(100) | 카테고리 (예: 'Running', 'Sneakers') | |
| pModelNumber | VARCHAR(100) | 모델 번호 | |

**관계**:
- `Product.pbid` → `ProductBase.id` (1:N, ON DELETE CASCADE)
- `ProductImage.pbid` → `ProductBase.id` (1:N, ON DELETE CASCADE)

**인덱스**:
- `idx_productbase_model_color`: (pModelNumber, pColor) 복합 UNIQUE

---

### 5. ProductImage (제품 이미지)

**설명**: 제품의 이미지 경로를 저장하는 테이블입니다. 하나의 ProductBase에 여러 이미지를 저장할 수 있습니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 이미지 ID | PRIMARY KEY, AUTO_INCREMENT |
| pbid | INT | ProductBase ID | NOT NULL, FOREIGN KEY |
| imagePath | VARCHAR(500) | 이미지 경로 (assets 경로) | NOT NULL |

**관계**:
- `ProductImage.pbid` → `ProductBase.id` (N:1, ON DELETE CASCADE)

**인덱스**:
- `idx_product_image_pbid`: ProductBase별 이미지 조회

---

### 6. Product (제품)

**설명**: 제품의 사이즈, 가격, 재고 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 제품 ID | PRIMARY KEY, AUTO_INCREMENT |
| pbid | INT | ProductBase ID | NOT NULL, FOREIGN KEY |
| mfid | INT | 제조사 ID | NOT NULL, FOREIGN KEY |
| size | INT | 사이즈 (220, 230, 240 등) | NOT NULL |
| basePrice | INT | 기본 가격 | NOT NULL |
| pQuantity | INT | 재고 수량 | NOT NULL, DEFAULT 0 |

**관계**:
- `Product.pbid` → `ProductBase.id` (N:1, ON DELETE CASCADE)
- `Product.mfid` → `Manufacturer.id` (N:1, ON DELETE CASCADE)
- `PurchaseItem.pid` → `Product.id` (1:N, ON DELETE CASCADE)

**인덱스**:
- `idx_product_pbid`: ProductBase별 제품 조회
- `idx_product_mfid`: 제조사별 제품 조회
- `idx_product_pbid_size`: (pbid, size) 복합 UNIQUE

---

### 7. Purchase (주문)

**설명**: 고객의 주문 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 주문 ID | PRIMARY KEY, AUTO_INCREMENT |
| cid | INT | 고객 ID | NOT NULL, FOREIGN KEY |
| pickupDate | VARCHAR(50) | 픽업 날짜 | |
| orderCode | VARCHAR(100) | 주문 코드 (고유 식별자) | NOT NULL, UNIQUE |
| timeStamp | VARCHAR(50) | 주문 시간 | |

**관계**:
- `Purchase.cid` → `Customer.id` (N:1, ON DELETE CASCADE)
- `PurchaseItem.pcid` → `Purchase.id` (1:N, ON DELETE CASCADE)

**인덱스**:
- `idx_purchase_cid`: 고객별 주문 조회
- `idx_purchase_order_code`: 주문 코드로 빠른 조회 (UNIQUE)

---

### 8. PurchaseItem (주문 항목)

**설명**: 주문에 포함된 각 제품의 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 주문 항목 ID | PRIMARY KEY, AUTO_INCREMENT |
| pid | INT | 제품 ID | NOT NULL, FOREIGN KEY |
| pcid | INT | 주문 ID | NOT NULL, FOREIGN KEY |
| pcQuantity | INT | 구매 수량 | NOT NULL |
| pcStatus | VARCHAR(100) | 주문 상태 | NOT NULL |

**상태값 (pcStatus)**:
- `'결제 대기'`: 결제 대기 중
- `'Onway'`: 배송 중
- `'Waiting for transaction'`: 거래 대기 중
- `'complete'`: 완료 (픽업 가능)
- `'return request'`: 반품 신청
- `'return done'`: 반품 완료

**관계**:
- `PurchaseItem.pid` → `Product.id` (N:1, ON DELETE CASCADE)
- `PurchaseItem.pcid` → `Purchase.id` (N:1, ON DELETE CASCADE)

**인덱스**:
- `idx_purchase_item_pcid`: 주문별 항목 조회
- `idx_purchase_item_pid`: 제품별 주문 항목 조회
- `idx_purchase_item_status`: 상태별 조회

---

### 9. LoginHistory (로그인 이력)

**설명**: 고객의 로그인 이력을 저장하는 테이블입니다.

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | INT | 로그인 이력 ID | PRIMARY KEY, AUTO_INCREMENT |
| cid | INT | 고객 ID | NOT NULL, FOREIGN KEY |
| loginTime | VARCHAR(50) | 로그인 시간 | |
| lStatus | VARCHAR(50) | 회원 상태 (예: '활동 회원', '휴면 회원') | |
| lVersion | DECIMAL(5,2) | 앱 버전 | |
| lAddress | VARCHAR(255) | 주소 | |
| lPaymentMethod | VARCHAR(100) | 결제 수단 | |

**관계**:
- `LoginHistory.cid` → `Customer.id` (N:1, ON DELETE CASCADE)

**인덱스**:
- `idx_login_history_cid`: 고객별 로그인 이력 조회

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

## 🖼️ 프로필 이미지 처리 (BLOB)

### Customer/Employee 프로필 이미지 API

**이미지 조회**:
```python
@app.get("/view_customer_profile_image/{customer_id}")
async def view_customer_profile_image(customer_id: int):
    # SELECT cProfileImage FROM Customer WHERE id = %s
    # Response(content=row[0], media_type="image/jpeg")
```

**이미지 업데이트**:
```python
@app.post("/update_customer_profile_image")
async def update_customer_profile_image(
    customer_id: int = Form(...),
    file: UploadFile = File(...)
):
    # UPDATE Customer SET cProfileImage=%s WHERE id=%s
```

---

## 📌 SQLite vs MySQL 차이점

| 항목 | SQLite | MySQL |
|------|--------|-------|
| 데이터 타입 | INTEGER, TEXT, REAL | INT, VARCHAR, MEDIUMBLOB, DECIMAL |
| 자동 증가 | AUTOINCREMENT | AUTO_INCREMENT |
| 프로필 이미지 | ❌ 없음 | ✅ MEDIUMBLOB |
| FK 제약 | 수동 설정 필요 | ON DELETE CASCADE 지원 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2025-12-28

---

## 📝 변경 이력

### 2025-12-28
- **MySQL 스키마 기반 문서 신규 작성**
- **Customer.cProfileImage** 컬럼 추가 (MEDIUMBLOB)
- **Employee.eProfileImage** 컬럼 추가 (MEDIUMBLOB)
- MySQL 데이터 타입으로 변경 (INT, VARCHAR, MEDIUMBLOB 등)
- ON DELETE CASCADE 관계 명시

