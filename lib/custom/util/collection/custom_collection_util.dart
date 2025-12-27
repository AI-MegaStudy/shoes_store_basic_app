// 컬렉션(리스트) 관련 유틸리티 클래스
// 리스트와 컬렉션 처리를 위한 유틸리티 함수들을 제공합니다.
class CustomCollectionUtil {
  // ============================================
  // null-safe 체크
  // ============================================

  // 리스트가 null이거나 비어있는지 확인
  //
  // 사용 예시:
  // ```dart
  // if (CustomCollectionUtil.isEmpty(list)) {
  //   print('리스트가 비어있습니다');
  // }
  // ```
  static bool isEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  // 리스트가 비어있지 않은지 확인
  //
  // 사용 예시:
  // ```dart
  // if (CustomCollectionUtil.isNotEmpty(list)) {
  //   print('리스트에 ${list.length}개의 항목이 있습니다');
  // }
  // ```
  static bool isNotEmpty<T>(List<T>? list) {
    return !isEmpty(list);
  }

  // ============================================
  // 중복 제거
  // ============================================

  // 리스트에서 중복 요소 제거
  //
  // 사용 예시:
  // ```dart
  // final numbers = [1, 2, 2, 3, 3, 3];
  // final unique = CustomCollectionUtil.unique(numbers); // [1, 2, 3]
  // ```
  static List<T> unique<T>(List<T> list) {
    return list.toSet().toList();
  }

  // 특정 키 기준으로 중복 제거
  //
  // 사용 예시:
  // ```dart
  // final users = [
  //   User(id: 1, name: '홍길동'),
  //   User(id: 1, name: '홍길동'), // 중복
  //   User(id: 2, name: '김철수'),
  // ];
  // final uniqueUsers = CustomCollectionUtil.uniqueBy(users, (user) => user.id);
  // ```
  static List<T> uniqueBy<T, K>(List<T> list, K Function(T) keySelector) {
    final seen = <K>{};
    return list.where((item) {
      final key = keySelector(item);
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  // ============================================
  // 그룹화
  // ============================================

  // 리스트를 특정 키 기준으로 그룹화
  //
  // 사용 예시:
  // ```dart
  // final products = [
  //   Product(name: '사과', category: '과일'),
  //   Product(name: '바나나', category: '과일'),
  //   Product(name: '당근', category: '채소'),
  // ];
  // final grouped = CustomCollectionUtil.groupBy(products, (p) => p.category);
  // // 결과: {'과일': [사과, 바나나], '채소': [당근]}
  // ```
  static Map<K, List<T>> groupBy<T, K>(
    List<T> list,
    K Function(T) keySelector,
  ) {
    final map = <K, List<T>>{};
    for (final item in list) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  // ============================================
  // 평탄화
  // ============================================

  // 2차원 리스트를 1차원으로 평탄화
  //
  // 사용 예시:
  // ```dart
  // final nested = [[1, 2], [3, 4], [5, 6]];
  // final flattened = CustomCollectionUtil.flatten(nested); // [1, 2, 3, 4, 5, 6]
  // ```
  static List<T> flatten<T>(List<List<T>> nestedList) {
    return nestedList.expand((list) => list).toList();
  }

  // ============================================
  // 필터링/매핑
  // ============================================

  // 조건에 맞는 요소만 필터링
  //
  // 사용 예시:
  // ```dart
  // final numbers = [1, 2, 3, 4, 5, 6];
  // final evens = CustomCollectionUtil.filter(numbers, (n) => n % 2 == 0); // [2, 4, 6]
  // ```
  static List<T> filter<T>(List<T> list, bool Function(T) predicate) {
    return list.where(predicate).toList();
  }

  // 요소를 다른 형태로 변환 (매핑)
  //
  // 사용 예시:
  // ```dart
  // final names = ['홍길동', '김철수', '이영희'];
  // final upperNames = CustomCollectionUtil.map(names, (name) => name.toUpperCase());
  // // ['홍길동', '김철수', '이영희']
  // ```
  static List<R> map<T, R>(List<T> list, R Function(T) mapper) {
    return list.map(mapper).toList();
  }

  // ============================================
  // 기타 유틸리티
  // ============================================

  // 리스트를 지정된 크기의 청크로 나누기
  //
  // 사용 예시:
  // ```dart
  // final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  // final chunks = CustomCollectionUtil.chunk(numbers, 3);
  // // [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  // ```
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(
        list.sublist(i, i + size > list.length ? list.length : i + size),
      );
    }
    return chunks;
  }

  // 첫 번째 요소 가져오기 (없으면 null)
  //
  // 사용 예시:
  // ```dart
  // final first = CustomCollectionUtil.firstOrNull([1, 2, 3]); // 1
  // final empty = CustomCollectionUtil.firstOrNull([]); // null
  // ```
  static T? firstOrNull<T>(List<T> list) {
    return list.isEmpty ? null : list.first;
  }

  // 마지막 요소 가져오기 (없으면 null)
  //
  // 사용 예시:
  // ```dart
  // final last = CustomCollectionUtil.lastOrNull([1, 2, 3]); // 3
  // final empty = CustomCollectionUtil.lastOrNull([]); // null
  // ```
  static T? lastOrNull<T>(List<T> list) {
    return list.isEmpty ? null : list.last;
  }

  // 리스트 합치기
  //
  // 사용 예시:
  // ```dart
  // final combined = CustomCollectionUtil.concat([1, 2], [3, 4]); // [1, 2, 3, 4]
  // ```
  static List<T> concat<T>(List<T> list1, List<T> list2) {
    return [...list1, ...list2];
  }

  // 리스트 섞기
  //
  // 사용 예시:
  // ```dart
  // final shuffled = CustomCollectionUtil.shuffle([1, 2, 3, 4, 5]);
  // ```
  static List<T> shuffle<T>(List<T> list) {
    final result = List<T>.from(list);
    result.shuffle();
    return result;
  }

  // 리스트 정렬 (새 리스트 반환)
  //
  // 사용 예시:
  // ```dart
  // final sorted = CustomCollectionUtil.sort([3, 1, 4, 1, 5]); // [1, 1, 3, 4, 5]
  // ```
  static List<T> sort<T extends Comparable<T>>(List<T> list) {
    final result = List<T>.from(list);
    result.sort();
    return result;
  }

  // 커스텀 비교 함수로 정렬
  //
  // 사용 예시:
  // ```dart
  // final users = [User(age: 25), User(age: 30), User(age: 20)];
  // final sorted = CustomCollectionUtil.sortBy(users, (u) => u.age);
  // ```
  static List<T> sortBy<T, K extends Comparable<K>>(
    List<T> list,
    K Function(T) keySelector,
  ) {
    final result = List<T>.from(list);
    result.sort((a, b) => keySelector(a).compareTo(keySelector(b)));
    return result;
  }

  // ============================================
  // 딥카피
  // ============================================

  // 리스트 딥카피 (깊은 복사)
  //
  // 주의: Dart에서 `List.from()` 또는 `[...list]`는 얕은 복사입니다.
  // 리스트 자체는 새로 생성되지만, 리스트 안의 객체들은 같은 참조를 가집니다.
  // 이 메서드는 각 요소도 복사하는 딥카피를 수행합니다.
  //
  // 사용 예시:
  // ```dart
  // final original = [User(name: '홍길동'), User(name: '김철수')];
  // final copied = CustomCollectionUtil.deepCopyList(original, (user) => User(name: user.name));
  //
  // // 원본 수정해도 복사본에 영향 없음
  // original[0].name = '이영희';
  // print(copied[0].name); // '홍길동' (변경되지 않음)
  // ```
  //
  // [copyItem] 함수를 제공하면 각 요소를 복사합니다.
  // 제공하지 않으면 얕은 복사만 수행합니다.
  static List<T> deepCopyList<T>(List<T> list, {T Function(T)? copyItem}) {
    if (copyItem != null) {
      return list.map((item) => copyItem(item)).toList();
    } else {
      // copyItem이 없으면 얕은 복사만 수행
      return List<T>.from(list);
    }
  }

  // 맵 딥카피 (깊은 복사)
  //
  // 주의: Dart에서 `Map.from()` 또는 `{...map}`는 얕은 복사입니다.
  // 맵 자체는 새로 생성되지만, 맵 안의 값들은 같은 참조를 가집니다.
  // 이 메서드는 각 값도 복사하는 딥카피를 수행합니다.
  //
  // 사용 예시:
  // ```dart
  // final original = {
  //   'user1': User(name: '홍길동'),
  //   'user2': User(name: '김철수'),
  // };
  // final copied = CustomCollectionUtil.deepCopyMap(
  //   original,
  //   copyValue: (user) => User(name: user.name),
  // );
  //
  // // 원본 수정해도 복사본에 영향 없음
  // original['user1']!.name = '이영희';
  // print(copied['user1']!.name); // '홍길동' (변경되지 않음)
  // ```
  //
  // [copyValue] 함수를 제공하면 각 값을 복사합니다.
  // 제공하지 않으면 얕은 복사만 수행합니다.
  static Map<K, V> deepCopyMap<K, V>(
    Map<K, V> map, {
    V Function(V)? copyValue,
  }) {
    if (copyValue != null) {
      return map.map((key, value) => MapEntry(key, copyValue(value)));
    } else {
      // copyValue가 없으면 얕은 복사만 수행
      return Map<K, V>.from(map);
    }
  }

  // 중첩 리스트 딥카피 (2차원 이상)
  //
  // 사용 예시:
  // ```dart
  // final original = [
  //   [User(name: '홍길동'), User(name: '김철수')],
  //   [User(name: '이영희')],
  // ];
  // final copied = CustomCollectionUtil.deepCopyNestedList(
  //   original,
  //   (user) => User(name: user.name),
  // );
  // ```
  static List<List<T>> deepCopyNestedList<T>(
    List<List<T>> nestedList,
    T Function(T) copyItem,
  ) {
    return nestedList
        .map((list) => list.map((item) => copyItem(item)).toList())
        .toList();
  }

  // 중첩 맵 딥카피 (맵 안에 맵이 있는 경우)
  //
  // 사용 예시:
  // ```dart
  // final original = {
  //   'group1': {'user1': User(name: '홍길동')},
  //   'group2': {'user2': User(name: '김철수')},
  // };
  // final copied = CustomCollectionUtil.deepCopyNestedMap(
  //   original,
  //   (user) => User(name: user.name),
  // );
  // ```
  static Map<K, Map<K2, V>> deepCopyNestedMap<K, K2, V>(
    Map<K, Map<K2, V>> nestedMap,
    V Function(V) copyValue,
  ) {
    return nestedMap.map(
      (key, innerMap) =>
          MapEntry(key, innerMap.map((k, v) => MapEntry(k, copyValue(v)))),
    );
  }

  // ============================================
  // Record 관련 유틸리티 (Dart 3.0+)
  // ============================================

  // Record 리스트에서 특정 필드 추출
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 1, name: '홍길동', age: 25),
  //   (id: 2, name: '김철수', age: 30),
  // ];
  // final names = CustomCollectionUtil.extractField(
  //   records,
  //   (record) => record.name,
  // ); // ['홍길동', '김철수']
  // ```
  static List<R> extractField<T, R>(
    List<T> records,
    R Function(T) fieldSelector,
  ) {
    return records.map(fieldSelector).toList();
  }

  // Record 리스트를 맵으로 변환 (키-값 쌍)
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 1, name: '홍길동'),
  //   (id: 2, name: '김철수'),
  // ];
  // final map = CustomCollectionUtil.recordListToMap(
  //   records,
  //   (record) => record.id,
  //   (record) => record.name,
  // ); // {1: '홍길동', 2: '김철수'}
  // ```
  static Map<K, V> recordListToMap<T, K, V>(
    List<T> records,
    K Function(T) keySelector,
    V Function(T) valueSelector,
  ) {
    final map = <K, V>{};
    for (final record in records) {
      map[keySelector(record)] = valueSelector(record);
    }
    return map;
  }

  // Record 리스트를 맵으로 변환 (키-전체 Record)
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 1, name: '홍길동', age: 25),
  //   (id: 2, name: '김철수', age: 30),
  // ];
  // final map = CustomCollectionUtil.recordListToMapByKey(
  //   records,
  //   (record) => record.id,
  // ); // {1: (id: 1, name: '홍길동', age: 25), 2: (id: 2, name: '김철수', age: 30)}
  // ```
  static Map<K, T> recordListToMapByKey<T, K>(
    List<T> records,
    K Function(T) keySelector,
  ) {
    final map = <K, T>{};
    for (final record in records) {
      map[keySelector(record)] = record;
    }
    return map;
  }

  // Record 리스트 필터링
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 1, name: '홍길동', age: 25),
  //   (id: 2, name: '김철수', age: 30),
  //   (id: 3, name: '이영희', age: 20),
  // ];
  // final adults = CustomCollectionUtil.filterRecords(
  //   records,
  //   (record) => record.age >= 25,
  // );
  // ```
  static List<T> filterRecords<T>(List<T> records, bool Function(T) predicate) {
    return records.where(predicate).toList();
  }

  // Record 리스트 매핑
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 1, name: '홍길동'),
  //   (id: 2, name: '김철수'),
  // ];
  // final names = CustomCollectionUtil.mapRecords(
  //   records,
  //   (record) => record.name.toUpperCase(),
  // ); // ['홍길동', '김철수']
  // ```
  static List<R> mapRecords<T, R>(List<T> records, R Function(T) mapper) {
    return records.map(mapper).toList();
  }

  // Record 리스트 그룹화
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (category: '과일', name: '사과', price: 1000),
  //   (category: '과일', name: '바나나', price: 2000),
  //   (category: '채소', name: '당근', price: 1500),
  // ];
  // final grouped = CustomCollectionUtil.groupRecordsBy(
  //   records,
  //   (record) => record.category,
  // );
  // ```
  static Map<K, List<T>> groupRecordsBy<T, K>(
    List<T> records,
    K Function(T) keySelector,
  ) {
    return groupBy(records, keySelector);
  }

  // Record 리스트 정렬
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (id: 3, name: '이영희', age: 20),
  //   (id: 1, name: '홍길동', age: 25),
  //   (id: 2, name: '김철수', age: 30),
  // ];
  // final sorted = CustomCollectionUtil.sortRecordsBy(
  //   records,
  //   (record) => record.age,
  // );
  // ```
  static List<T> sortRecordsBy<T, K extends Comparable<K>>(
    List<T> records,
    K Function(T) keySelector,
  ) {
    return sortBy(records, keySelector);
  }

  // Record 리스트에서 최대값 찾기
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (name: '홍길동', score: 85),
  //   (name: '김철수', score: 92),
  //   (name: '이영희', score: 78),
  // ];
  // final maxRecord = CustomCollectionUtil.maxBy(
  //   records,
  //   (record) => record.score,
  // ); // (name: '김철수', score: 92)
  // ```
  static T? maxBy<T, K extends Comparable<K>>(
    List<T> records,
    K Function(T) keySelector,
  ) {
    if (records.isEmpty) return null;
    return records.reduce(
      (a, b) => keySelector(a).compareTo(keySelector(b)) > 0 ? a : b,
    );
  }

  // Record 리스트에서 최소값 찾기
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (name: '홍길동', score: 85),
  //   (name: '김철수', score: 92),
  //   (name: '이영희', score: 78),
  // ];
  // final minRecord = CustomCollectionUtil.minBy(
  //   records,
  //   (record) => record.score,
  // ); // (name: '이영희', score: 78)
  // ```
  static T? minBy<T, K extends Comparable<K>>(
    List<T> records,
    K Function(T) keySelector,
  ) {
    if (records.isEmpty) return null;
    return records.reduce(
      (a, b) => keySelector(a).compareTo(keySelector(b)) < 0 ? a : b,
    );
  }

  // Record 리스트에서 합계 계산
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (name: '사과', price: 1000),
  //   (name: '바나나', price: 2000),
  //   (name: '오렌지', price: 1500),
  // ];
  // final total = CustomCollectionUtil.sumBy(
  //   records,
  //   (record) => record.price,
  // ); // 4500
  // ```
  static num sumBy<T>(List<T> records, num Function(T) valueSelector) {
    return records.fold(0, (sum, record) => sum + valueSelector(record));
  }

  // Record 리스트에서 평균 계산
  //
  // 사용 예시:
  // ```dart
  // final records = [
  //   (name: '홍길동', score: 85),
  //   (name: '김철수', score: 92),
  //   (name: '이영희', score: 78),
  // ];
  // final average = CustomCollectionUtil.averageBy(
  //   records,
  //   (record) => record.score,
  // ); // 85.0
  // ```
  static double averageBy<T>(List<T> records, num Function(T) valueSelector) {
    if (records.isEmpty) return 0.0;
    final sum = sumBy(records, valueSelector);
    return sum / records.length;
  }
}
