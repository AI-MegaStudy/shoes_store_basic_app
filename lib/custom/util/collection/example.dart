import 'package:flutter/material.dart';
import 'custom_collection_util.dart';

// CollectionUtil 사용 예제
void main() {
  runApp(const CollectionExampleApp());
}

class CollectionExampleApp extends StatelessWidget {
  const CollectionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollectionUtil 예제',
      home: const CollectionExamplePage(),
    );
  }
}

class CollectionExamplePage extends StatefulWidget {
  const CollectionExamplePage({super.key});

  @override
  State<CollectionExamplePage> createState() => _CollectionExamplePageState();
}

class _CollectionExamplePageState extends State<CollectionExamplePage> {
  String _result = '';

  // null-safe 체크 예제
  void _checkEmpty() {
    final emptyList = <int>[];
    List<int>? nullList;
    final filledList = [1, 2, 3];

    _result =
        '''
빈 리스트 체크:
- isEmpty([]): ${CustomCollectionUtil.isEmpty(emptyList)}
- isEmpty(null): ${CustomCollectionUtil.isEmpty(nullList)}
- isEmpty([1,2,3]): ${CustomCollectionUtil.isEmpty(filledList)}
- isNotEmpty([1,2,3]): ${CustomCollectionUtil.isNotEmpty(filledList)}
''';
    setState(() {});
  }

  // 중복 제거 예제
  void _uniqueExample() {
    final numbers = [1, 2, 2, 3, 3, 3, 4];
    final unique = CustomCollectionUtil.unique(numbers);

    final users = [
      User(id: 1, name: '홍길동'),
      User(id: 1, name: '홍길동'), // 중복
      User(id: 2, name: '김철수'),
      User(id: 3, name: '이영희'),
    ];
    final uniqueUsers = CustomCollectionUtil.uniqueBy(users, (u) => u.id);

    _result =
        '''
중복 제거:
- 원본: $numbers
- unique: $unique

키 기준 중복 제거:
- 원본: ${users.map((u) => '${u.name}(id:${u.id})').join(', ')}
- uniqueBy: ${uniqueUsers.map((u) => '${u.name}(id:${u.id})').join(', ')}
''';
    setState(() {});
  }

  // 그룹화 예제
  void _groupByExample() {
    final products = [
      Product(name: '사과', category: '과일'),
      Product(name: '바나나', category: '과일'),
      Product(name: '당근', category: '채소'),
      Product(name: '상추', category: '채소'),
      Product(name: '우유', category: '유제품'),
    ];

    final grouped = CustomCollectionUtil.groupBy(products, (p) => p.category);

    _result = '그룹화 결과:\n';
    grouped.forEach((category, items) {
      _result += '- $category: ${items.map((p) => p.name).join(', ')}\n';
    });
    setState(() {});
  }

  // 평탄화 예제
  void _flattenExample() {
    final nested = [
      [1, 2, 3],
      [4, 5],
      [6, 7, 8, 9],
    ];
    final flattened = CustomCollectionUtil.flatten(nested);

    _result =
        '''
평탄화:
- 원본: $nested
- flattened: $flattened
''';
    setState(() {});
  }

  // 필터링/매핑 예제
  void _filterMapExample() {
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final evens = CustomCollectionUtil.filter(numbers, (n) => n % 2 == 0);
    final doubled = CustomCollectionUtil.map(numbers, (n) => n * 2);

    _result =
        '''
필터링/매핑:
- 원본: $numbers
- 짝수만: $evens
- 2배: $doubled
''';
    setState(() {});
  }

  // 청크 예제
  void _chunkExample() {
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    final chunks = CustomCollectionUtil.chunk(numbers, 3);

    _result =
        '''
청크로 나누기:
- 원본: $numbers
- chunks (크기 3): $chunks
''';
    setState(() {});
  }

  // firstOrNull / lastOrNull 예제
  void _firstLastExample() {
    final numbers = [1, 2, 3, 4, 5];
    final empty = <int>[];

    _result =
        '''
첫 번째/마지막 요소:
- [1,2,3,4,5]의 첫 번째: ${CustomCollectionUtil.firstOrNull(numbers)}
- [1,2,3,4,5]의 마지막: ${CustomCollectionUtil.lastOrNull(numbers)}
- []의 첫 번째: ${CustomCollectionUtil.firstOrNull(empty)}
- []의 마지막: ${CustomCollectionUtil.lastOrNull(empty)}
''';
    setState(() {});
  }

  // 합치기/섞기/정렬 예제
  void _concatShuffleSortExample() {
    final list1 = [1, 2, 3];
    final list2 = [4, 5, 6];
    final combined = CustomCollectionUtil.concat(list1, list2);
    final shuffled = CustomCollectionUtil.shuffle([1, 2, 3, 4, 5]);
    final sorted = CustomCollectionUtil.sort([3, 1, 4, 1, 5]);

    final users = [
      User(id: 3, name: '이영희'),
      User(id: 1, name: '홍길동'),
      User(id: 2, name: '김철수'),
    ];
    final sortedUsers = CustomCollectionUtil.sortBy(users, (u) => u.id);

    _result =
        '''
합치기/섞기/정렬:
- 합치기: $list1 + $list2 = $combined
- 섞기: [1,2,3,4,5] → $shuffled
- 정렬: [3,1,4,1,5] → $sorted
- ID 기준 정렬: ${sortedUsers.map((u) => '${u.name}(id:${u.id})').join(', ')}
''';
    setState(() {});
  }

  // 딥카피 예제
  void _deepCopyExample() {
    // 리스트 딥카피
    final originalList = [User(id: 1, name: '홍길동'), User(id: 2, name: '김철수')];
    final copiedList = CustomCollectionUtil.deepCopyList(
      originalList,
      copyItem: (user) => User(id: user.id, name: user.name),
    );

    // 원본 수정
    originalList[0].name = '이영희';

    // 맵 딥카피
    final originalMap = {
      'user1': User(id: 1, name: '홍길동'),
      'user2': User(id: 2, name: '김철수'),
    };
    final copiedMap = CustomCollectionUtil.deepCopyMap(
      originalMap,
      copyValue: (user) => User(id: user.id, name: user.name),
    );

    // 원본 수정
    originalMap['user1']!.name = '박민수';

    // 중첩 리스트 딥카피
    final nestedList = [
      [User(id: 1, name: '홍길동'), User(id: 2, name: '김철수')],
      [User(id: 3, name: '이영희')],
    ];
    final copiedNestedList = CustomCollectionUtil.deepCopyNestedList(
      nestedList,
      (user) => User(id: user.id, name: user.name),
    );

    // 원본 수정
    nestedList[0][0].name = '최영희';

    // 중첩 맵 딥카피
    final nestedMap = {
      'group1': {'user1': User(id: 1, name: '홍길동')},
      'group2': {'user2': User(id: 2, name: '김철수')},
    };
    final copiedNestedMap = CustomCollectionUtil.deepCopyNestedMap(
      nestedMap,
      (user) => User(id: user.id, name: user.name),
    );

    // 원본 수정
    nestedMap['group1']!['user1']!.name = '정민수';

    _result =
        '''
딥카피 테스트:
- 리스트 딥카피:
  원본[0].name: ${originalList[0].name}
  복사본[0].name: ${copiedList[0].name} (원본 변경 후에도 유지)

- 맵 딥카피:
  원본['user1'].name: ${originalMap['user1']!.name}
  복사본['user1'].name: ${copiedMap['user1']!.name} (원본 변경 후에도 유지)

- 중첩 리스트 딥카피:
  원본[0][0].name: ${nestedList[0][0].name}
  복사본[0][0].name: ${copiedNestedList[0][0].name} (원본 변경 후에도 유지)

- 중첩 맵 딥카피:
  원본['group1']['user1'].name: ${nestedMap['group1']!['user1']!.name}
  복사본['group1']['user1'].name: ${copiedNestedMap['group1']!['user1']!.name} (원본 변경 후에도 유지)
''';
    setState(() {});
  }

  // Record 유틸리티 예제
  void _recordExample() {
    // Record 타입 정의 (이름 있는 필드)
    final records = [
      (id: 1, name: '홍길동', age: 25, score: 85),
      (id: 2, name: '김철수', age: 30, score: 92),
      (id: 3, name: '이영희', age: 20, score: 78),
      (id: 4, name: '박민수', age: 28, score: 88),
    ];

    // 필드 추출
    final names = CustomCollectionUtil.extractField(records, (r) => r.name);

    // 맵으로 변환
    final idToName = CustomCollectionUtil.recordListToMap(
      records,
      (r) => r.id,
      (r) => r.name,
    );

    // 키-전체 Record 맵
    final idToRecord = CustomCollectionUtil.recordListToMapByKey(
      records,
      (r) => r.id,
    );

    // 필터링 (25세 이상)
    final adults = CustomCollectionUtil.filterRecords(
      records,
      (r) => r.age >= 25,
    );

    // 매핑 (이름 대문자)
    final upperNames = CustomCollectionUtil.mapRecords(
      records,
      (r) => r.name.toUpperCase(),
    );

    // 정렬 (나이 기준)
    final sortedByAge = CustomCollectionUtil.sortRecordsBy(
      records,
      (r) => r.age,
    );

    // 최대값/최소값
    final maxScore = CustomCollectionUtil.maxBy(records, (r) => r.score);
    final minScore = CustomCollectionUtil.minBy(records, (r) => r.score);

    // 합계/평균
    final totalScore = CustomCollectionUtil.sumBy(records, (r) => r.score);
    final avgScore = CustomCollectionUtil.averageBy(records, (r) => r.score);

    _result =
        '''
Record 유틸리티 테스트:
- 필드 추출 (이름): $names
- 맵 변환 (id -> name): $idToName
- 키-전체 Record 맵: ${idToRecord.map((k, v) => MapEntry(k, '${v.name}(${v.age}세)'))}
- 필터링 (25세 이상): ${adults.map((r) => '${r.name}(${r.age}세)').join(', ')}
- 매핑 (이름 대문자): $upperNames
- 정렬 (나이 기준): ${sortedByAge.map((r) => '${r.name}(${r.age}세)').join(', ')}
- 최대 점수: ${maxScore?.name} (${maxScore?.score}점)
- 최소 점수: ${minScore?.name} (${minScore?.score}점)
- 총점: $totalScore
- 평균 점수: ${avgScore.toStringAsFixed(1)}
''';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CollectionUtil 예제')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _checkEmpty,
                    child: const Text('null-safe 체크'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _uniqueExample,
                    child: const Text('중복 제거'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _groupByExample,
                    child: const Text('그룹화'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _flattenExample,
                    child: const Text('평탄화'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _filterMapExample,
                    child: const Text('필터링/매핑'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _chunkExample,
                    child: const Text('청크로 나누기'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _firstLastExample,
                    child: const Text('첫 번째/마지막 요소'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _concatShuffleSortExample,
                    child: const Text('합치기/섞기/정렬'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _deepCopyExample,
                    child: const Text('딥카피'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _recordExample,
                    child: const Text('Record 유틸리티'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: SelectableText(
              _result.isEmpty ? '위 버튼을 눌러 예제를 실행하세요' : _result,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

// 예제용 User 클래스
class User {
  final int id;
  String name; // 딥카피 테스트를 위해 final 제거

  User({required this.id, required this.name});
}

// 예제용 Product 클래스
class Product {
  final String name;
  final String category;

  Product({required this.name, required this.category});
}
