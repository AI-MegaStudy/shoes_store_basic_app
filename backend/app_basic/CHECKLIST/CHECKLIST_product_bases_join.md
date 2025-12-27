# ProductBase JOIN API 체크리스트

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

## 관련 테이블

| 테이블 | 역할 |
|--------|------|
| ProductBase | 메인 테이블 |
| ProductImage | 이미지 |
| Product | 사이즈/가격 |
| Manufacturer | 제조사 |

## API 목록

| API | 조인 테이블 | 완료 |
|-----|------------|------|
| ProductBase + 첫번째 이미지 | ProductImage | [ ] |
| ProductBase + 전체 이미지 | ProductImage | [ ] |
| ProductBase + Product 목록 | Product | [ ] |
| ProductBase 전체 상세 (4테이블) | ProductImage + Product + Manufacturer | [ ] |

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| | | |
