# CustomCollectionUtil

컬렉션(리스트) 관련 유틸리티 클래스입니다. 리스트와 컬렉션 처리를 위한 유틸리티 함수들을 제공합니다.

## 주요 기능

- null-safe 체크
- 중복 제거
- 그룹화
- 평탄화
- 필터링/매핑
- 청크로 나누기
- 정렬/섞기

## 의존성

외부 패키지 불필요 (순수 Dart)

## 기본 사용법

### null-safe 체크

```dart
final list = <int>[];
final nullList = <int>?[];

// 빈 리스트 확인
if (CustomCollectionUtil.isEmpty(list)) {
  print('리스트가 비어있습니다');
}

// 비어있지 않은지 확인
if (CustomCollectionUtil.isNotEmpty(list)) {
  print('리스트에 ${list.length}개의 항목이 있습니다');
}
```

### 중복 제거

```dart
// 기본 중복 제거
final numbers = [1, 2, 2, 3, 3, 3];
final unique = CustomCollectionUtil.unique(numbers); // [1, 2, 3]

// 키 기준 중복 제거
final users = [
  User(id: 1, name: '홍길동'),
  User(id: 1, name: '홍길동'), // 중복
  User(id: 2, name: '김철수'),
];
final uniqueUsers = CustomCollectionUtil.uniqueBy(users, (user) => user.id);
```

### 그룹화

```dart
final products = [
  Product(name: '사과', category: '과일'),
  Product(name: '바나나', category: '과일'),
  Product(name: '당근', category: '채소'),
];

final grouped = CustomCollectionUtil.groupBy(products, (p) => p.category);
// 결과: {'과일': [사과, 바나나], '채소': [당근]}
```

### 평탄화

```dart
final nested = [[1, 2], [3, 4], [5, 6]];
final flattened = CustomCollectionUtil.flatten(nested); // [1, 2, 3, 4, 5, 6]
```

### 필터링/매핑

```dart
final numbers = [1, 2, 3, 4, 5, 6];

// 필터링 (조건에 맞는 요소만)
final evens = CustomCollectionUtil.filter(numbers, (n) => n % 2 == 0); // [2, 4, 6]

// 매핑 (요소 변환)
final doubled = CustomCollectionUtil.map(numbers, (n) => n * 2); // [2, 4, 6, 8, 10, 12]
```

### 청크로 나누기

```dart
final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
final chunks = CustomCollectionUtil.chunk(numbers, 3);
// 결과: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
```

### 첫 번째/마지막 요소

```dart
final numbers = [1, 2, 3, 4, 5];
final empty = <int>[];

final first = CustomCollectionUtil.firstOrNull(numbers); // 1
final last = CustomCollectionUtil.lastOrNull(numbers); // 5
final emptyFirst = CustomCollectionUtil.firstOrNull(empty); // null
```

### 합치기/섞기/정렬

```dart
// 합치기
final list1 = [1, 2, 3];
final list2 = [4, 5, 6];
final combined = CustomCollectionUtil.concat(list1, list2); // [1, 2, 3, 4, 5, 6]

// 섞기
final shuffled = CustomCollectionUtil.shuffle([1, 2, 3, 4, 5]);

// 정렬
final sorted = CustomCollectionUtil.sort([3, 1, 4, 1, 5]); // [1, 1, 3, 4, 5]

// 커스텀 정렬
final users = [
  User(id: 3, name: '이영희'),
  User(id: 1, name: '홍길동'),
  User(id: 2, name: '김철수'),
];
final sortedUsers = CustomCollectionUtil.sortBy(users, (u) => u.id);
```

### 딥카피 (깊은 복사)

**중요**: Dart에서 `List.from()` 또는 `[...list]`는 **얕은 복사(shallow copy)**입니다.
리스트 자체는 새로 생성되지만, 리스트 안의 객체들은 같은 참조를 가집니다.
딥카피를 하려면 각 요소도 복사해야 합니다.

```dart
// 리스트 딥카피
final original = [User(name: '홍길동'), User(name: '김철수')];
final copied = CustomCollectionUtil.deepCopyList(
  original,
  copyItem: (user) => User(name: user.name),
);

// 원본 수정해도 복사본에 영향 없음
original[0].name = '이영희';
print(copied[0].name); // '홍길동' (변경되지 않음)

// 맵 딥카피
final originalMap = {
  'user1': User(name: '홍길동'),
  'user2': User(name: '김철수'),
};
final copiedMap = CustomCollectionUtil.deepCopyMap(
  originalMap,
  copyValue: (user) => User(name: user.name),
);

// 원본 수정해도 복사본에 영향 없음
originalMap['user1']!.name = '박민수';
print(copiedMap['user1']!.name); // '홍길동' (변경되지 않음)

// 중첩 리스트 딥카피
final nestedList = [
  [User(name: '홍길동'), User(name: '김철수')],
  [User(name: '이영희')],
];
final copiedNestedList = CustomCollectionUtil.deepCopyNestedList(
  nestedList,
  (user) => User(name: user.name),
);

// 중첩 맵 딥카피
final nestedMap = {
  'group1': {'user1': User(name: '홍길동')},
  'group2': {'user2': User(name: '김철수')},
};
final copiedNestedMap = CustomCollectionUtil.deepCopyNestedMap(
  nestedMap,
  (user) => User(name: user.name),
);
```

### Record 관련 유틸리티 (Dart 3.0+)

**Record란?**
Dart의 Record는 파이썬의 튜플과 비슷한 개념입니다. 여러 값을 하나로 묶을 수 있으며, 타입 안전합니다.

```dart
// 이름 있는 필드 Record
final user = (id: 1, name: '홍길동', age: 25);
print(user.name); // '홍길동'

// 위치 기반 Record
final point = (10, 20);
print(point.$1); // 10
```

#### 필드 추출

```dart
final records = [
  (id: 1, name: '홍길동', age: 25),
  (id: 2, name: '김철수', age: 30),
];
final names = CustomCollectionUtil.extractField(records, (r) => r.name);
// ['홍길동', '김철수']
```

#### 맵으로 변환

```dart
// 키-값 쌍으로 변환
final idToName = CustomCollectionUtil.recordListToMap(
  records,
  (r) => r.id,
  (r) => r.name,
); // {1: '홍길동', 2: '김철수'}

// 키-전체 Record로 변환
final idToRecord = CustomCollectionUtil.recordListToMapByKey(
  records,
  (r) => r.id,
);
```

#### 필터링/매핑

```dart
// 필터링
final adults = CustomCollectionUtil.filterRecords(
  records,
  (r) => r.age >= 25,
);

// 매핑
final upperNames = CustomCollectionUtil.mapRecords(
  records,
  (r) => r.name.toUpperCase(),
);
```

#### 정렬

```dart
final sorted = CustomCollectionUtil.sortRecordsBy(
  records,
  (r) => r.age,
);
```

#### 최대값/최소값

```dart
final records = [
  (name: '홍길동', score: 85),
  (name: '김철수', score: 92),
  (name: '이영희', score: 78),
];

final maxRecord = CustomCollectionUtil.maxBy(records, (r) => r.score);
// (name: '김철수', score: 92)

final minRecord = CustomCollectionUtil.minBy(records, (r) => r.score);
// (name: '이영희', score: 78)
```

#### 합계/평균

```dart
final total = CustomCollectionUtil.sumBy(records, (r) => r.score); // 255
final average = CustomCollectionUtil.averageBy(records, (r) => r.score); // 85.0
```

## 주요 사용 사례

- 리스트 데이터 처리 및 변환
- 중복 데이터 제거
- 데이터 그룹화 및 분류
- 복잡한 리스트 연산 간소화
- 원본 데이터 보호가 필요한 경우 (딥카피)
- Record 데이터 처리 (Dart 3.0+)

## 예제

자세한 사용 예제는 `example.dart` 파일을 참고하세요.
