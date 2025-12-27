# Purchase JOIN API 체크리스트

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

## 관련 테이블

| 테이블 | 역할 |
|--------|------|
| Purchase | 메인 테이블 |
| Customer | 고객 정보 |
| PurchaseItem | 주문 항목 |

## API 목록

| API | 조인 테이블 | 완료 |
|-----|------------|------|
| Purchase + Customer (단일) | Customer | [ ] |
| Purchase 목록 + Customer | Customer | [ ] |
| Purchase + PurchaseItem 목록 (단일) | PurchaseItem | [ ] |
| Purchase 목록 + PurchaseItem 목록 | PurchaseItem | [ ] |
| Purchase 전체 상세 (Customer + Items) | Customer + PurchaseItem | [ ] |

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| | | |

