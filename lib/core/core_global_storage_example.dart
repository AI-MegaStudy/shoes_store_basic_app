import 'package:flutter/material.dart';
import 'package:shoes_store_basic_app/core/core.dart';

/// GlobalStorage 사용 예제 페이지
///
/// 전역 저장소의 모든 기능을 테스트하고 확인할 수 있는 예제 페이지입니다.
class CoreGlobalStorageExamplePage extends StatefulWidget {
  const CoreGlobalStorageExamplePage({super.key});

  @override
  State<CoreGlobalStorageExamplePage> createState() =>
      _CoreGlobalStorageExamplePageState();
}

class _CoreGlobalStorageExamplePageState
    extends State<CoreGlobalStorageExamplePage> {
  String _result = '위 버튼을 눌러 예제를 실행하세요';
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _updateResult(String message) {
    setState(() {
      _result = message;
    });
  }

  /// 예제 1: Map 저장하기
  ///
  /// 사용자 정보를 Map 형태로 저장하는 예제입니다.
  void _exampleSaveMap() {
    // Map 데이터 생성
    final userData = {
      'name': '홍길동',
      'age': 25,
      'email': 'hong@example.com',
      'city': '서울',
    };

    // 전역 저장소에 저장
    context.globalStorage.save('userData', userData);

    _updateResult(
      '✅ Map 저장 완료!\n\n'
      '키: userData\n'
      '값: $userData\n\n'
      '저장된 데이터를 확인하려면 "Map 가져오기" 버튼을 눌러주세요.',
    );
  }

  /// 예제 2: List 저장하기
  ///
  /// 숫자 리스트를 저장하는 예제입니다.
  void _exampleSaveList() {
    // List 데이터 생성
    final items = [1, 2, 3, 4, 5, 10, 20, 30];

    // 전역 저장소에 저장
    context.globalStorage.save('items', items);

    _updateResult(
      '✅ List 저장 완료!\n\n'
      '키: items\n'
      '값: $items\n\n'
      '저장된 데이터를 확인하려면 "List 가져오기" 버튼을 눌러주세요.',
    );
  }

  /// 예제 3: Map 가져오기
  ///
  /// 저장된 Map 데이터를 가져오는 예제입니다.
  void _exampleGetMap() {
    // 저장된 Map 가져오기
    final userData = context.globalStorage.get<Map>('userData');

    if (userData != null) {
      _updateResult(
        '✅ Map 가져오기 성공!\n\n'
        '키: userData\n'
        '값: $userData\n\n'
        '이름: ${userData['name']}\n'
        '나이: ${userData['age']}\n'
        '이메일: ${userData['email']}\n'
        '도시: ${userData['city']}',
      );
    } else {
      _updateResult(
        '❌ 데이터가 없습니다!\n\n'
        '먼저 "Map 저장하기" 버튼을 눌러 데이터를 저장해주세요.',
      );
    }
  }

  /// 예제 4: List 가져오기
  ///
  /// 저장된 List 데이터를 가져오는 예제입니다.
  void _exampleGetList() {
    // 저장된 List 가져오기
    final items = context.globalStorage.get<List<int>>('items');

    if (items != null) {
      // 리스트 합계 계산
      final sum = items.fold(0, (a, b) => a + b);
      final average = sum / items.length;

      _updateResult(
        '✅ List 가져오기 성공!\n\n'
        '키: items\n'
        '값: $items\n\n'
        '리스트 길이: ${items.length}\n'
        '합계: $sum\n'
        '평균: ${average.toStringAsFixed(2)}',
      );
    } else {
      _updateResult(
        '❌ 데이터가 없습니다!\n\n'
        '먼저 "List 저장하기" 버튼을 눌러 데이터를 저장해주세요.',
      );
    }
  }

  /// 예제 5: 키 중복 검사 (isKeyAvailable)
  ///
  /// 키가 사용 가능한지 확인하는 예제입니다.
  void _exampleCheckKeyAvailable() {
    const testKey = 'testKey';

    // 키 사용 가능 여부 확인
    final isAvailable = context.globalStorage.isKeyAvailable(testKey);

    if (isAvailable) {
      // 키가 사용 가능하면 저장
      context.globalStorage.save(testKey, {'test': 'value'});
      _updateResult(
        '✅ 키 사용 가능!\n\n'
        '키: $testKey\n'
        '상태: 사용 가능 (중복 없음)\n\n'
        '데이터를 저장했습니다.',
      );
    } else {
      _updateResult(
        '❌ 키 중복!\n\n'
        '키: $testKey\n'
        '상태: 이미 존재함 (중복)\n\n'
        '다른 키를 사용하거나 기존 데이터를 삭제해주세요.',
      );
    }
  }

  /// 예제 6: 키 존재 여부 확인 (containsKey)
  ///
  /// 키가 존재하는지 확인하는 예제입니다.
  void _exampleCheckKeyExists() {
    const testKey = 'userData';

    // 키 존재 여부 확인
    final exists = context.globalStorage.containsKey(testKey);

    if (exists) {
      final data = context.globalStorage.get<Map>(testKey);
      _updateResult(
        '✅ 키가 존재합니다!\n\n'
        '키: $testKey\n'
        '상태: 존재함\n'
        '값: $data',
      );
    } else {
      _updateResult(
        '❌ 키가 존재하지 않습니다!\n\n'
        '키: $testKey\n'
        '상태: 없음\n\n'
        '먼저 데이터를 저장해주세요.',
      );
    }
  }

  /// 예제 7: 모든 키 가져오기
  ///
  /// 저장소에 저장된 모든 키를 가져오는 예제입니다.
  void _exampleGetAllKeys() {
    final keys = context.globalStorage.getAllKeys();
    final count = context.globalStorage.length;

    if (keys.isNotEmpty) {
      String keysList = keys.map((key) => '- $key').join('\n');
      _updateResult(
        '✅ 모든 키 가져오기 성공!\n\n'
        '저장된 키 개수: $count\n\n'
        '저장된 키 목록:\n$keysList',
      );
    } else {
      _updateResult(
        '❌ 저장된 키가 없습니다!\n\n'
        '먼저 데이터를 저장해주세요.',
      );
    }
  }

  /// 예제 8: 키 삭제하기
  ///
  /// 저장된 키-값 쌍을 삭제하는 예제입니다.
  void _exampleRemoveKey() {
    const keyToRemove = 'testKey';

    // 키 존재 여부 확인
    if (context.globalStorage.containsKey(keyToRemove)) {
      // 삭제
      final removed = context.globalStorage.remove(keyToRemove);
      _updateResult(
        '✅ 키 삭제 완료!\n\n'
        '삭제된 키: $keyToRemove\n'
        '삭제된 값: $removed',
      );
    } else {
      _updateResult(
        '❌ 삭제할 키가 없습니다!\n\n'
        '키: $keyToRemove\n'
        '상태: 존재하지 않음',
      );
    }
  }

  /// 예제 9: 전체 삭제하기
  ///
  /// 저장소의 모든 데이터를 삭제하는 예제입니다.
  void _exampleClearAll() {
    final count = context.globalStorage.length;

    if (count > 0) {
      context.globalStorage.clear();
      _updateResult(
        '✅ 전체 삭제 완료!\n\n'
        '삭제된 항목 수: $count\n'
        '저장소가 비어있습니다.',
      );
    } else {
      _updateResult(
        '❌ 삭제할 데이터가 없습니다!\n\n'
        '저장소가 이미 비어있습니다.',
      );
    }
  }

  /// 예제 10: 사용자 입력으로 저장하기
  ///
  /// 사용자가 직접 키와 값을 입력하여 저장하는 예제입니다.
  void _exampleSaveWithInput() {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty) {
      _updateResult('❌ 키를 입력해주세요!');
      return;
    }

    if (value.isEmpty) {
      _updateResult('❌ 값을 입력해주세요!');
      return;
    }

    // 키 중복 검사
    if (!context.globalStorage.isKeyAvailable(key)) {
      _updateResult(
        '❌ 키 중복!\n\n'
        '키 "$key"는 이미 존재합니다.\n'
        '다른 키를 사용하거나 기존 데이터를 삭제해주세요.',
      );
      return;
    }

    // Map 형태로 저장 (실제로는 JSON 파싱 등으로 처리 가능)
    final data = {'value': value, 'timestamp': DateTime.now().toString()};
    context.globalStorage.save(key, data);

    _updateResult(
      '✅ 저장 완료!\n\n'
      '키: $key\n'
      '값: $data\n\n'
      '저장된 데이터를 확인하려면 "모든 키 가져오기" 버튼을 눌러주세요.',
    );

    // 입력 필드 초기화
    _keyController.clear();
    _valueController.clear();
  }

  /// 예제 11: 단일 변수 저장하기
  ///
  /// String, int, bool, double 등 단일 변수를 저장하는 예제입니다.
  void _exampleSavePrimitives() {
    // 다양한 타입의 단일 변수 저장
    context.globalStorage.save('userName', '홍길동');
    context.globalStorage.save('userAge', 25);
    context.globalStorage.save('isActive', true);
    context.globalStorage.save('userScore', 95.5);

    _updateResult(
      '✅ 단일 변수 저장 완료!\n\n'
      '저장된 데이터:\n'
      '- userName (String): 홍길동\n'
      '- userAge (int): 25\n'
      '- isActive (bool): true\n'
      '- userScore (double): 95.5\n\n'
      '타입 확인 및 가져오기를 테스트해보세요.',
    );
  }

  /// 예제 12: 단일 변수 가져오기
  ///
  /// 저장된 단일 변수를 타입별로 안전하게 가져오는 예제입니다.
  void _exampleGetPrimitives() {
    final userName = context.globalStorage.getString('userName');
    final userAge = context.globalStorage.getInt('userAge');
    final isActive = context.globalStorage.getBool('isActive');
    final userScore = context.globalStorage.getDouble('userScore');

    if (userName != null &&
        userAge != null &&
        isActive != null &&
        userScore != null) {
      _updateResult(
        '✅ 단일 변수 가져오기 성공!\n\n'
        '가져온 데이터:\n'
        '- userName: $userName (${userName.runtimeType})\n'
        '- userAge: $userAge (${userAge.runtimeType})\n'
        '- isActive: $isActive (${isActive.runtimeType})\n'
        '- userScore: $userScore (${userScore.runtimeType})',
      );
    } else {
      _updateResult(
        '❌ 데이터가 없습니다!\n\n'
        '먼저 "단일 변수 저장하기" 버튼을 눌러 데이터를 저장해주세요.',
      );
    }
  }

  /// 예제 13: 타입 확인하기
  ///
  /// 저장된 값의 타입을 확인하는 예제입니다.
  void _exampleCheckType() {
    final keys = [
      'userName',
      'userAge',
      'isActive',
      'userScore',
      'userData',
      'items',
    ];
    final results = <String>[];

    for (final key in keys) {
      if (context.globalStorage.containsKey(key)) {
        final type = context.globalStorage.getType(key);
        final isPrimitive = context.globalStorage.isPrimitiveType(key);
        results.add('$key: $type ${isPrimitive ? "(기본 타입)" : "(복합 타입)"}');
      } else {
        results.add('$key: (없음)');
      }
    }

    _updateResult(
      '📋 타입 확인 결과\n\n'
      '${results.join('\n')}\n\n'
      '기본 타입: String, int, bool, double\n'
      '복합 타입: Map, List 등',
    );
  }

  /// 예제 14: 타입별 안전하게 가져오기
  ///
  /// 타입을 확인한 후 안전하게 값을 가져오는 예제입니다.
  void _exampleGetWithTypeCheck() {
    const testKey = 'userName';

    if (!context.globalStorage.containsKey(testKey)) {
      _updateResult(
        '❌ 키가 없습니다!\n\n'
        '먼저 "단일 변수 저장하기" 버튼을 눌러 데이터를 저장해주세요.',
      );
      return;
    }

    final type = context.globalStorage.getType(testKey);
    String? value;

    switch (type) {
      case 'String':
        value = context.globalStorage.getString(testKey);
        break;
      case 'int':
        value = context.globalStorage.getInt(testKey)?.toString();
        break;
      case 'bool':
        value = context.globalStorage.getBool(testKey)?.toString();
        break;
      case 'double':
        value = context.globalStorage.getDouble(testKey)?.toString();
        break;
      default:
        value = '지원하지 않는 타입: $type';
    }

    _updateResult(
      '✅ 타입별 안전하게 가져오기\n\n'
      '키: $testKey\n'
      '타입: $type\n'
      '값: $value',
    );
  }

  /// 예제 15: 저장소 상태 확인
  ///
  /// 저장소가 비어있는지, 데이터가 있는지 확인하는 예제입니다.
  void _exampleCheckStatus() {
    final isEmpty = context.globalStorage.isEmpty;
    final isNotEmpty = context.globalStorage.isNotEmpty;
    final count = context.globalStorage.length;
    final keys = context.globalStorage.getAllKeys();

    _updateResult(
      '📊 저장소 상태\n\n'
      '비어있음: $isEmpty\n'
      '데이터 있음: $isNotEmpty\n'
      '저장된 항목 수: $count\n\n'
      '저장된 키:\n${keys.isEmpty ? '(없음)' : keys.map((k) => '- $k').join('\n')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('GlobalStorage 예제'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 설명 ExpansionTile (접을 수 있음)
            ExpansionTile(
              title: Text(
                'GlobalStorage 사용 예제',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              initiallyExpanded: false, // 기본적으로 접혀있음
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '전역 저장소의 모든 기능을 테스트하고 확인할 수 있습니다.\n'
                    'Map, List뿐만 아니라 String, int, bool, double 등 단일 변수도 저장 가능합니다.\n'
                    '타입 확인 기능을 통해 저장된 값의 타입을 확인할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 결과 표시 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '실행 결과',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _result = '아래 버튼을 눌러 예제를 실행하세요';
                    });
                  },
                  child: const Text('지우기'),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 기본 기능 섹션
            Text(
              '기본 기능',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            // Map 저장/가져오기
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleSaveMap,
                    child: const Text('Map 저장하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleGetMap,
                    child: const Text('Map 가져오기'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // List 저장/가져오기
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleSaveList,
                    child: const Text('List 저장하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleGetList,
                    child: const Text('List 가져오기'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 단일 변수 저장/가져오기
            Text(
              '단일 변수 (String, int, bool, double)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleSavePrimitives,
                    child: const Text('단일 변수 저장'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleGetPrimitives,
                    child: const Text('단일 변수 가져오기'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 타입 확인 섹션
            Text(
              '타입 확인 기능',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleCheckType,
                    child: const Text('타입 확인하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleGetWithTypeCheck,
                    child: const Text('타입별 가져오기'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 키 검사 섹션
            Text(
              '키 검사 기능',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleCheckKeyAvailable,
                    child: const Text('키 중복 검사'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleCheckKeyExists,
                    child: const Text('키 존재 확인'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 관리 기능 섹션
            Text(
              '관리 기능',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleGetAllKeys,
                    child: const Text('모든 키 가져오기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleCheckStatus,
                    child: const Text('저장소 상태'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleRemoveKey,
                    child: const Text('키 삭제하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exampleClearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('전체 삭제'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 사용자 입력 섹션
            Text(
              '사용자 입력으로 저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _keyController,
                      decoration: const InputDecoration(
                        hintText: '키를 입력하세요 (예: myData)',
                        labelText: '키',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        hintText: '값을 입력하세요',
                        labelText: '값',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _exampleSaveWithInput,
                        child: const Text('저장하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
