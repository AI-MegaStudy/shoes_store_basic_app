# PurchaseItem JOIN API 체크리스트

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

## 관련 테이블

| 테이블 | 역할 |
|--------|------|
| PurchaseItem | 메인 테이블 |
| Product | 상품 |
| ProductBase | 제품 기본 정보 |
| Manufacturer | 제조사 |
| ProductImage | 이미지 |

## API 목록

| API | 조인 테이블 | 완료 |
|-----|------------|------|
| PurchaseItem + Product | Product | [ ] |
| PurchaseItem 목록 + Product (주문별) | Product | [ ] |
| PurchaseItem 전체 상세 (4테이블) | Product + ProductBase + Manufacturer | [ ] |
| PurchaseItem 목록 전체 상세 (주문별) | Product + ProductBase + Manufacturer + ProductImage | [ ] |
| 주문 요약 정보 (집계) | Product | [ ] |

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| | | |

