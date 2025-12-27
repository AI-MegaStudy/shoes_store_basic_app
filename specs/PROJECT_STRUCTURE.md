# 📂 프로젝트 폴더 구조

> 📅 최종 업데이트: 2025-12-26

---

## 📁 lib/

### 루트 파일

| 파일 | 설명 |
|------|------|
| `main.dart` | 앱 진입점, DB 초기화, 테마 설정, 라우팅 |
| `config.dart` | 전역 상수 모음 (테이블명, 상태코드, 지역명 등) |

---

### lib/core/

전역 저장소 관리

| 파일 | 설명 |
|------|------|
| `core.dart` | core 패키지 export 파일 |
| `global_storage.dart` | GetStorage 기반 전역 저장소 클래스 |
| `global_storage_context.dart` | 저장소 컨텍스트 관리 |
| `core_global_storage_example.dart` | 전역 저장소 사용 예제 |

---

### lib/custom/

김택권 개인적으로 사용 중인 래핑 위젯 클래스 모음. 몇몇 파일은 전역적으로 사용 중.

---

### lib/database/

SQLite 데이터베이스

| 폴더/파일 | 설명 |
|-----------|------|
| `core/database_manager.dart` | DB 연결, 테이블 생성, 초기화 관리 |
| `handlers/` | 테이블별 CRUD 핸들러 (단일 테이블) |
| `services/` | 복합 쿼리 서비스 (여러 테이블 조인) |
| `dummy_data/` | 더미 데이터 |

#### handlers/

| 파일 | 테이블 |
|------|--------|
| `customer_handler.dart` | Customer |
| `employee_handler.dart` | Employee |
| `login_history_handler.dart` | LoginHistory |
| `manufacturer_handler.dart` | Manufacturer |
| `product_base_handler.dart` | ProductBase |
| `product_handler.dart` | Product |
| `product_image_handler.dart` | ProductImage |
| `purchase_handler.dart` | Purchase |
| `purchase_item_handler.dart` | PurchaseItem |

#### services/

| 파일 | 설명 |
|------|------|
| `purchase_service.dart` | 주문 관련 복합 JOIN 쿼리 |

---

### lib/model/

데이터 모델

| 파일/폴더 | 테이블 | 설명 |
|-----------|--------|------|
| `customer.dart` | Customer | 고객 |
| `employee.dart` | Employee | 직원/관리자 |
| `login_history.dart` | LoginHistory | 로그인 이력 |
| `product/product.dart` | Product | 제품 (사이즈, 가격, 재고) |
| `product/product_base.dart` | ProductBase | 제품 기본정보 (이름, 색상) |
| `product/product_image.dart` | ProductImage | 제품 이미지 |
| `product/manufacturer.dart` | Manufacturer | 제조사 |
| `purchase/purchase.dart` | Purchase | 주문 |
| `purchase/purchase_item.dart` | PurchaseItem | 주문 항목 |

---

### lib/theme/

테마 관리 (라이트/다크 모드)

| 파일 | 설명 |
|------|------|
| `theme_provider.dart` | 테마 상태 관리 Provider |
| `app_theme_mode.dart` | 라이트/다크 모드 정의 |
| `app_colors.dart` | 앱 색상 정의 |
| `app_color_scheme.dart` | 앱 색상 스킴 |
| `common_color_scheme.dart` | 공통 색상 스킴 |
| `daily_flow_color_scheme.dart` | 특정 테마 색상 스킴 |
| `palette_context.dart` | 팔레트 컨텍스트 |

---

### lib/utils/

공용 유틸리티

| 파일 | 설명 |
|------|------|
| `admin_tablet_utils.dart` | 태블릿 감지, 가로모드 고정 |
| `app_logger.dart` | 앱 로깅 |
| `order_status_utils.dart` | 주문 상태 결정 로직 |
| `order_status_colors.dart` | 주문 상태별 색상 |
| `order_utils.dart` | 주문코드 생성, 가격 포맷팅 |

---

### lib/view/

화면 (View)

#### lib/view/cheng/screens/auth/

인증 화면

| 파일 | 설명 |
|------|------|
| `login_view.dart` | 고객 로그인 |
| `signup_view.dart` | 고객 회원가입 |
| `admin_login_view.dart` | 관리자 로그인 (태블릿 전용) |

#### lib/view/cheng/screens/customer/

고객 화면

| 파일 | 설명 |
|------|------|
| `search_view.dart` | 제품 검색 |
| `order_list_view.dart` | 주문 목록 |
| `order_detail_view.dart` | 주문 상세 |
| `return_list_view.dart` | 반품 목록 |
| `return_detail_view.dart` | 반품 상세 |
| `user_profile_edit_view.dart` | 프로필 수정 |

#### lib/view/cheng/screens/admin/

관리자 화면

| 파일 | 설명 |
|------|------|
| `admin_order_view.dart` | 주문 관리 |
| `admin_order_detail_view.dart` | 주문 상세 |
| `admin_return_order_view.dart` | 반품 관리 |
| `admin_return_order_detail_view.dart` | 반품 상세 |
| `admin_profile_edit_view.dart` | 프로필 수정 |
| `admin_mobile_block_view.dart` | 모바일 접근 차단 안내 |

#### lib/view/cheng/widgets/

공용 위젯

| 파일 | 설명 |
|------|------|
| `admin/admin_drawer.dart` | 관리자 Drawer 메뉴 |
| `admin/base_order_card.dart` | 주문 카드 베이스 |
| `admin/order_card.dart` | 주문 카드 |
| `admin/return_order_card.dart` | 반품 카드 |
| `admin/order_detail_view.dart` | 주문 상세 뷰 |
| `customer/customer_info_card.dart` | 고객 정보 카드 |
| `customer/customer_order_card.dart` | 고객 주문 카드 |
| `customer/customer_return_card.dart` | 고객 반품 카드 |

#### lib/view/cheng/storage/

세션 저장소 (GetStorage)

| 파일 | 설명 |
|------|------|
| `user_storage.dart` | 로그인한 고객 정보 |
| `admin_storage.dart` | 로그인한 관리자 정보 |
| `cart_storage.dart` | 장바구니 정보 |

#### lib/view/customer/

구매 관련 화면

| 파일 | 설명 |
|------|------|
| `cart.dart` | 장바구니 |
| `detail_view.dart` | 제품 상세 |
| `purchase_view.dart` | 구매/결제 |
| `address_payment_view.dart` | 주소/결제 정보 입력 |
| `payment_sheet_content.dart` | 결제 시트 콘텐츠 |

---

## 📁 specs/

프로젝트 문서

| 파일 | 설명 |
|------|------|
| `PROJECT_STRUCTURE.md` | 폴더 구조 (이 문서) |
| `REFERENCE.md` | 개발 규칙, 참고 자료 |
| `DATABASE_GUIDE.md` | DB 사용법 가이드 |
| `DATABASE_SCHEMA.md` | DB 스키마 상세 |
| `HANDLER_USAGE_GUIDE.md` | 핸들러 사용법 |
| `database_schema.dbml` | DB 스키마 DBML |
| `shoes_store_app_DBML.png` | DB ERD 이미지 |

### specs/Ref_Image/

디자인 레퍼런스 폴더

---

## 🗂️ 폴더 구조 트리

```
lib/
├── main.dart
├── config.dart
├── core/                        # 전역 저장소
├── custom/                      # 커스텀 위젯 라이브러리
├── database/
│   ├── core/                    # DB 매니저
│   ├── handlers/                # 테이블별 핸들러
│   ├── services/                # 복합 쿼리 서비스
│   └── dummy_data/
├── model/
│   ├── product/
│   └── purchase/
├── theme/
├── utils/
└── view/
    ├── cheng/
    │   ├── screens/
    │   │   ├── auth/
    │   │   ├── customer/
    │   │   └── admin/
    │   ├── widgets/
    │   └── storage/
    └── customer/

specs/
├── PROJECT_STRUCTURE.md
├── DATABASE_GUIDE.md
├── DATABASE_SCHEMA.md
├── HANDLER_USAGE_GUIDE.md
└── Ref_Image/
```
