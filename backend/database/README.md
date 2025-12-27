# MySQL Database 초기화 및 관리

이 폴더에는 MySQL 8.0.44용 데이터베이스 초기화 스크립트와 관련 파일이 포함되어 있습니다.

## 📁 파일 구조

| 파일 | 설명 |
|------|------|
| **`init.sql`** ⭐ | 전체 초기화 스크립트 (DB 생성 + 테이블 생성 + 더미 데이터) |
| `dummy_data.sql` | 더미 데이터만 별도 참조용 |
| `add_profile_image_columns.py` | 프로필 이미지 컬럼 추가 스크립트 |
| `dummy-profile-pic.png` | 테스트용 더미 프로필 이미지 |
| `README.md` | 이 문서 |

## 🚀 사용 방법

### 방법 1: MySQL Workbench (권장)

1. MySQL Workbench 실행
2. `File` > `Open SQL Script...` 선택
3. `backend/database/init.sql` 파일 선택
4. **번개 아이콘(Execute) 클릭** 또는 `Ctrl+Shift+Enter`

> ⚠️ **중요**: 특정 라인을 선택하지 않고 실행하면 **전체 파일이 순차 실행**됩니다.

### 방법 2: 명령줄

```bash
mysql -u root -p < backend/database/init.sql
```

### 방법 3: Python (pymysql)

```bash
cd backend
source venv/bin/activate
python3 << 'EOF'
import pymysql

with open('database/init.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

conn = pymysql.connect(
    host='cheng80.myqnapcloud.com',  # 또는 'localhost'
    port=13306,                       # 기본값: 3306
    user='team0101',
    password='qwer1234',
    charset='utf8mb4',
    autocommit=True,
    client_flag=pymysql.constants.CLIENT.MULTI_STATEMENTS
)
conn.cursor().execute(sql)
print("✅ DB 초기화 완료!")
conn.close()
EOF
```

## 📊 init.sql 실행 흐름

```
1. 데이터베이스 생성 (CREATE DATABASE IF NOT EXISTS)
       ↓
2. 기존 테이블 삭제 (DROP TABLE IF EXISTS)
       ↓
3. 테이블 생성 (CREATE TABLE) - 9개
       ↓
4. 더미 데이터 삽입 (INSERT INTO)
       ↓
5. 완료!
```

> 💡 **리셋**: `init.sql`을 다시 실행하면 기존 데이터가 삭제되고 초기 상태로 복원됩니다.

## 📋 테이블 목록

| # | 테이블 | 설명 |
|---|--------|------|
| 1 | **Manufacturer** | 제조사 |
| 2 | **ProductBase** | 제품 기본 정보 |
| 3 | **ProductImage** | 제품 이미지 |
| 4 | **Product** | 제품 (사이즈별 가격/재고) |
| 5 | **Customer** | 고객 |
| 6 | **Employee** | 직원/관리자 |
| 7 | **Purchase** | 주문 |
| 8 | **PurchaseItem** | 주문 항목 |
| 9 | **LoginHistory** | 로그인 이력 |

## 🔑 주요 특징

- **외래키**: `ON DELETE CASCADE` - 부모 삭제 시 자식도 자동 삭제
- **문자 인코딩**: `utf8mb4` - 한글 및 이모지 지원
- **인덱스**: 조인 쿼리 성능 최적화

## ⚠️ UNIQUE 제약조건

| 테이블 | 컬럼 | 설명 |
|--------|------|------|
| Customer | `cEmail` | 이메일 중복 방지 |
| Customer | `cPhoneNumber` | 전화번호 중복 방지 |
| Employee | `eEmail` | 이메일 중복 방지 |
| Employee | `ePhoneNumber` | 전화번호 중복 방지 |
| Purchase | `orderCode` | 주문 코드 중복 방지 |
| Manufacturer | `mName` | 제조사명 중복 방지 |
| Product | `(pbid, size)` | 동일 제품+사이즈 중복 방지 |
| ProductBase | `(pModelNumber, pColor)` | 동일 모델+색상 중복 방지 |

> 중복 데이터 삽입 시 `Duplicate entry` 오류 발생

## 📦 더미 데이터 (init.sql 포함)

| 테이블 | 데이터 수 |
|--------|----------|
| Manufacturer | 2개 (Nike, NewBalance) |
| ProductBase | 12개 (4종류 × 3색상) |
| Product | 84개 (12 × 7사이즈) |
| Customer | 6명 |
| Employee | 3명 |
| Purchase | 5건 |
| PurchaseItem | 6개 |
| LoginHistory | 6건 |

## 🖼️ 프로필 이미지 추가

Customer와 Employee 테이블에 프로필 이미지 추가:

```bash
cd backend
./venv/bin/python database/add_profile_image_columns.py
```

> 다른 서버에서 사용 시 `add_profile_image_columns.py` 상단의 `DB_CONFIG` 수정

## 🔧 문제 해결

### 외래키 제약조건 오류

```sql
SET FOREIGN_KEY_CHECKS = 0;
-- 쿼리 실행
SET FOREIGN_KEY_CHECKS = 1;
```

### 문자 인코딩 확인

```sql
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

## 🔗 연결 설정

FastAPI 연결: `app_basic_form/database/connection.py`

```python
DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'port': 13306,
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'shoes_store_db',
    'charset': 'utf8mb4'
}
```
