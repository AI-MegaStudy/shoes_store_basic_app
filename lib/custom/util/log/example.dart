import 'package:flutter/material.dart';
import 'custom_log_util.dart';

// AppLogger 사용 예제
void main() {
  runApp(const LogExampleApp());
}

class LogExampleApp extends StatelessWidget {
  const LogExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppLogger 예제',
      home: const LogExamplePage(),
    );
  }
}

class LogExamplePage extends StatefulWidget {
  const LogExamplePage({super.key});

  @override
  State<LogExamplePage> createState() => _LogExamplePageState();
}

class _LogExamplePageState extends State<LogExamplePage> {
  final List<String> _logHistory = [];

  void _addLog(String message) {
    setState(() {
      _logHistory.add('${DateTime.now().toString().substring(11, 19)} - $message');
      if (_logHistory.length > 20) {
        _logHistory.removeAt(0);
      }
    });
  }

  // 디버그 로그 예제
  void _testDebug() {
    AppLogger.d('디버그 메시지입니다');
    _addLog('디버그 로그 출력됨 (콘솔 확인)');
  }

  // 태그가 있는 디버그 로그 예제
  void _testDebugWithTag() {
    AppLogger.d('API 요청 시작', tag: 'API');
    _addLog('태그가 있는 디버그 로그 출력됨 (콘솔 확인)');
  }

  // 정보 로그 예제
  void _testInfo() {
    AppLogger.i('정보 메시지입니다');
    _addLog('정보 로그 출력됨 (콘솔 확인)');
  }

  // 태그가 있는 정보 로그 예제
  void _testInfoWithTag() {
    AppLogger.i('사용자 로그인 성공', tag: 'Auth');
    _addLog('태그가 있는 정보 로그 출력됨 (콘솔 확인)');
  }

  // 경고 로그 예제
  void _testWarning() {
    AppLogger.w('경고 메시지입니다');
    _addLog('경고 로그 출력됨 (콘솔 확인)');
  }

  // 에러가 있는 경고 로그 예제
  void _testWarningWithError() {
    try {
      throw Exception('테스트 예외');
    } catch (e) {
      AppLogger.w('경고: 예외 발생', tag: 'Test', error: e);
      _addLog('에러가 있는 경고 로그 출력됨 (콘솔 확인)');
    }
  }

  // 에러 로그 예제
  void _testError() {
    AppLogger.e('에러 메시지입니다');
    _addLog('에러 로그 출력됨 (콘솔 확인)');
  }

  // 스택 트레이스가 있는 에러 로그 예제
  void _testErrorWithStackTrace() {
    try {
      throw Exception('테스트 예외');
    } catch (e, stackTrace) {
      AppLogger.e(
        '에러 발생',
        tag: 'Error',
        error: e,
        stackTrace: stackTrace,
      );
      _addLog('스택 트레이스가 있는 에러 로그 출력됨 (콘솔 확인)');
    }
  }

  // 성공 로그 예제
  void _testSuccess() {
    AppLogger.s('작업이 성공적으로 완료되었습니다');
    _addLog('성공 로그 출력됨 (콘솔 확인)');
  }

  // 태그가 있는 성공 로그 예제
  void _testSuccessWithTag() {
    AppLogger.s('데이터 저장 완료', tag: 'Storage');
    _addLog('태그가 있는 성공 로그 출력됨 (콘솔 확인)');
  }

  // 모든 로그 타입 테스트
  void _testAll() {
    AppLogger.d('디버그 메시지', tag: 'Test');
    AppLogger.i('정보 메시지', tag: 'Test');
    AppLogger.w('경고 메시지', tag: 'Test');
    AppLogger.e('에러 메시지', tag: 'Test');
    AppLogger.s('성공 메시지', tag: 'Test');
    _addLog('모든 로그 타입 출력됨 (콘솔 확인)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppLogger 예제'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 설명
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AppLogger',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '앱 전역 로깅 유틸리티 클래스입니다.\n'
                      '디버그 모드에서는 모든 로그가 출력되고,\n'
                      '릴리즈 모드에서는 에러 로그만 출력됩니다.\n\n'
                      '콘솔을 확인하여 로그 출력을 확인하세요.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_logHistory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '로그 히스토리:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._logHistory.map(
                              (log) => Text(
                                log,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 디버그 로그
            ElevatedButton(
              onPressed: _testDebug,
              child: const Text('디버그 로그 (d)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testDebugWithTag,
              child: const Text('디버그 로그 (태그 포함)'),
            ),
            const SizedBox(height: 16),

            // 정보 로그
            ElevatedButton(
              onPressed: _testInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('정보 로그 (i)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testInfoWithTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('정보 로그 (태그 포함)'),
            ),
            const SizedBox(height: 16),

            // 경고 로그
            ElevatedButton(
              onPressed: _testWarning,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('경고 로그 (w)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testWarningWithError,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('경고 로그 (에러 포함)'),
            ),
            const SizedBox(height: 16),

            // 에러 로그
            ElevatedButton(
              onPressed: _testError,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('에러 로그 (e)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testErrorWithStackTrace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('에러 로그 (스택 트레이스 포함)'),
            ),
            const SizedBox(height: 16),

            // 성공 로그
            ElevatedButton(
              onPressed: _testSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('성공 로그 (s)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSuccessWithTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('성공 로그 (태그 포함)'),
            ),
            const SizedBox(height: 16),

            // 모든 로그 타입 테스트
            ElevatedButton(
              onPressed: _testAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('모든 로그 타입 테스트'),
            ),
            const SizedBox(height: 16),

            // 사용법 안내
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사용법:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'import \'package:custom_test_app/custom/util/log/custom_log_util.dart\';\n\n'
                      'AppLogger.d(\'디버그 메시지\');\n'
                      'AppLogger.i(\'정보 메시지\');\n'
                      'AppLogger.w(\'경고 메시지\');\n'
                      'AppLogger.e(\'에러 메시지\');\n'
                      'AppLogger.s(\'성공 메시지\');\n\n'
                      '// 태그와 함께 사용\n'
                      'AppLogger.d(\'메시지\', tag: \'API\');\n\n'
                      '// 에러와 함께 사용\n'
                      'AppLogger.e(\'에러 발생\', error: exception, stackTrace: stackTrace);',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
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