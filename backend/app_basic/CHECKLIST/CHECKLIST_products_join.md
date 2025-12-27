# Product JOIN API 체크리스트

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

## 관련 테이블

| 테이블 | 역할 |
|--------|------|
| Product | 메인 테이블 |
| ProductBase | 제품 기본 정보 |
| Manufacturer | 제조사 |
| ProductImage | 이미지 |

## API 목록

| API | 조인 테이블 | 완료 |
|-----|------------|------|
| Product + ProductBase | ProductBase | [ ] |
| Product + ProductBase + Manufacturer (3테이블) | ProductBase + Manufacturer | [ ] |
| ProductBase별 Product 목록 | ProductBase | [ ] |
| Product 전체 상세 (이미지 포함) | ProductBase + Manufacturer + ProductImage | [ ] |

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| | | |

