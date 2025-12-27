import 'package:flutter/material.dart';
import 'custom_network_util.dart';

// NetworkUtil 사용 예제 페이지
class NetworkUtilExamplePage extends StatefulWidget {
  const NetworkUtilExamplePage({super.key});

  @override
  State<NetworkUtilExamplePage> createState() => _NetworkUtilExamplePageState();
}

class _NetworkUtilExamplePageState extends State<NetworkUtilExamplePage> {
  String _result = '';

  @override
  void initState() {
    super.initState();
    // 예제용 기본 URL 설정 (실제 API는 사용 불가)
    // CustomNetworkUtil.setBaseUrl('https://api.example.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NetworkUtil 예제')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _getExample,
              child: const Text('GET 요청 예제'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _postExample,
              child: const Text('POST 요청 예제'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _putExample,
              child: const Text('PUT 요청 예제'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _deleteExample,
              child: const Text('DELETE 요청 예제'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _queryParamsExample,
              child: const Text('쿼리 파라미터 예제'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _errorHandlingExample,
              child: const Text('에러 처리 예제'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result.isEmpty
                    ? '위 버튼을 눌러 예제를 실행하세요\n\n주의: 실제 API 서버가 필요합니다'
                    : _result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GET 요청 예제
  void _getExample() async {
    setState(() {
      _result = '=== GET 요청 예제 ===\n\n';
      _result += '요청 중...\n';
    });

    // 실제 API 예제 (JSONPlaceholder 사용)
    final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
      'https://jsonplaceholder.typicode.com/posts/1',
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '상태 코드: ${response.statusCode}\n';
        _result += '데이터: ${response.data}\n';
      } else {
        _result += '❌ 실패!\n';
        _result += '에러: ${response.error}\n';
        _result += '상태 코드: ${response.statusCode}\n';
      }
    });
  }

  // POST 요청 예제
  void _postExample() async {
    setState(() {
      _result = '=== POST 요청 예제 ===\n\n';
      _result += '요청 중...\n';
    });

    // 실제 API 예제 (JSONPlaceholder 사용)
    final response = await CustomNetworkUtil.post<Map<String, dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      body: {'title': '테스트 제목', 'body': '테스트 내용', 'userId': 1},
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '상태 코드: ${response.statusCode}\n';
        _result += '생성된 데이터:\n';
        _result += 'ID: ${response.data?['id']}\n';
        _result += '제목: ${response.data?['title']}\n';
        _result += '내용: ${response.data?['body']}\n';
      } else {
        _result += '❌ 실패!\n';
        _result += '에러: ${response.error}\n';
      }
    });
  }

  // PUT 요청 예제
  void _putExample() async {
    setState(() {
      _result = '=== PUT 요청 예제 ===\n\n';
      _result += '요청 중...\n';
    });

    // 실제 API 예제 (JSONPlaceholder 사용)
    final response = await CustomNetworkUtil.put<Map<String, dynamic>>(
      'https://jsonplaceholder.typicode.com/posts/1',
      body: {'id': 1, 'title': '수정된 제목', 'body': '수정된 내용', 'userId': 1},
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '상태 코드: ${response.statusCode}\n';
        _result += '수정된 데이터:\n';
        _result += '제목: ${response.data?['title']}\n';
        _result += '내용: ${response.data?['body']}\n';
      } else {
        _result += '❌ 실패!\n';
        _result += '에러: ${response.error}\n';
      }
    });
  }

  // DELETE 요청 예제
  void _deleteExample() async {
    setState(() {
      _result = '=== DELETE 요청 예제 ===\n\n';
      _result += '요청 중...\n';
    });

    // 실제 API 예제 (JSONPlaceholder 사용)
    final response = await CustomNetworkUtil.delete(
      'https://jsonplaceholder.typicode.com/posts/1',
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '상태 코드: ${response.statusCode}\n';
        _result += '데이터가 삭제되었습니다.\n';
      } else {
        _result += '❌ 실패!\n';
        _result += '에러: ${response.error}\n';
      }
    });
  }

  // 쿼리 파라미터 예제
  void _queryParamsExample() async {
    setState(() {
      _result = '=== 쿼리 파라미터 예제 ===\n\n';
      _result += '요청 중...\n';
    });

    // 실제 API 예제 (JSONPlaceholder 사용)
    final response = await CustomNetworkUtil.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParams: {'userId': '1', '_limit': '5'},
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '상태 코드: ${response.statusCode}\n';
        final dataList = response.data;
        _result += '받은 데이터 개수: ${dataList is List ? dataList.length : 0}\n';
        if (dataList is List && dataList.isNotEmpty) {
          _result += '\n첫 번째 항목:\n';
          _result += 'ID: ${dataList[0]['id']}\n';
          _result += '제목: ${dataList[0]['title']}\n';
        }
      } else {
        _result += '❌ 실패!\n';
        _result += '에러: ${response.error}\n';
      }
    });
  }

  // 에러 처리 예제
  void _errorHandlingExample() async {
    setState(() {
      _result = '=== 에러 처리 예제 ===\n\n';
      _result += '잘못된 URL로 요청 중...\n';
    });

    // 존재하지 않는 URL로 요청 (에러 발생)
    final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
      'https://invalid-url-that-does-not-exist.com/api',
    );

    setState(() {
      if (response.success) {
        _result += '✅ 성공!\n';
        _result += '데이터: ${response.data}\n';
      } else {
        _result += '❌ 실패 (예상된 동작)\n';
        _result += '에러: ${response.error}\n';
        _result += '상태 코드: ${response.statusCode}\n';
        _result += '\n에러 처리가 정상적으로 작동합니다!\n';
      }
    });
  }
}
