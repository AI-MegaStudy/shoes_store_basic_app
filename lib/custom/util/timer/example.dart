import 'dart:async';
import 'package:flutter/material.dart';
import 'custom_timer_util.dart';

// TimerUtil 사용 예제
void main() {
  runApp(const TimerExampleApp());
}

class TimerExampleApp extends StatelessWidget {
  const TimerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'TimerUtil 예제', home: const TimerExamplePage());
  }
}

class TimerExamplePage extends StatefulWidget {
  const TimerExamplePage({super.key});

  @override
  State<TimerExamplePage> createState() => _TimerExamplePageState();
}

class _TimerExamplePageState extends State<TimerExamplePage> {
  String _result = '';
  int _counter = 0;
  Timer? _periodicTimer;
  final TimerManager _timerManager = TimerManager();

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _timerManager.cancelAll();
    // ID 기반 타이머 모두 취소
    CustomTimerUtil.cancelAllById();
    super.dispose();
  }

  // 기본 타이머 예제
  void _basicTimerExample() {
    _result = '기본 타이머: 2초 후 실행 예정\n';
    setState(() {});

    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _result += '2초 후 실행됨!';
      });
    });
  }

  // 반복 타이머 예제
  void _periodicTimerExample() {
    _counter = 0;
    _periodicTimer?.cancel();

    _result = '반복 타이머: 1초마다 카운트\n';
    setState(() {});

    _periodicTimer = CustomTimerUtil.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _counter++;
        _result = '반복 타이머: 카운트 = $_counter\n';
        if (_counter >= 5) {
          timer.cancel();
          _result += '5회 후 자동 중지';
        }
      });
    });
  }

  // waitForSeconds 예제
  Future<void> _waitForSecondsExample() async {
    _result = 'waitForSeconds 예제:\n';
    setState(() {});

    _result += '시작...\n';
    setState(() {});

    await CustomTimerUtil.waitForSeconds(2.0);
    if (!mounted) return;
    setState(() {
      _result += '2초 후 실행됨!\n';
    });

    await CustomTimerUtil.waitForSeconds(1.5);
    if (!mounted) return;
    setState(() {
      _result += '추가 1.5초 후 실행됨!';
    });
  }

  // waitUntil 예제
  Future<void> _waitUntilExample() async {
    _result = 'waitUntil 예제:\n대기 중...\n';
    setState(() {});

    bool isReady = false;

    // 3초 후 isReady를 true로 설정
    CustomTimerUtil.delayed(Duration(seconds: 3), () {
      isReady = true;
    });

    await CustomTimerUtil.waitUntil(() => isReady);
    if (!mounted) return;
    setState(() {
      _result += '조건 만족! 준비 완료!';
    });
  }

  // waitWhile 예제
  Future<void> _waitWhileExample() async {
    _result = 'waitWhile 예제:\n로딩 중...\n';
    setState(() {});

    bool isLoading = true;

    // 2초 후 로딩 완료
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      isLoading = false;
    });

    await CustomTimerUtil.waitWhile(() => isLoading);
    if (!mounted) return;
    setState(() {
      _result += '로딩 완료!';
    });
  }

  // withTimeout 예제
  Future<void> _withTimeoutExample() async {
    _result = 'withTimeout 예제:\n';
    setState(() {});

    try {
      final result = await CustomTimerUtil.withTimeout(
        Future.delayed(Duration(seconds: 10), () => '완료'),
        Duration(seconds: 3),
        onTimeout: () => '타임아웃',
      );
      if (!mounted) return;
      setState(() {
        _result += '결과: $result';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result += '에러: $e';
      });
    }
  }

  // retry 예제
  Future<void> _retryExample() async {
    _result = 'retry 예제:\n';
    setState(() {});

    int attempts = 0;
    try {
      await CustomTimerUtil.retry(
        () async {
          attempts++;
          if (mounted) {
            setState(() {
              _result += '시도 $attempts...\n';
            });
          }
          await Future.delayed(Duration(milliseconds: 500));
          if (attempts < 3) {
            throw Exception('실패');
          }
          return '성공';
        },
        maxRetries: 3,
        delay: Duration(seconds: 1),
      );
      if (!mounted) return;
      setState(() {
        _result += '성공!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result += '최종 실패: $e';
      });
    }
  }

  // debounce 예제
  void _debounceExample() {
    _result = 'debounce 예제:\n';
    setState(() {});

    final debounced = CustomTimerUtil.debounce(() {
      if (!mounted) return;
      setState(() {
        _result += '실행됨! (마지막 호출만 실행)\n';
      });
    }, Duration(milliseconds: 500));

    // 여러 번 호출
    for (int i = 0; i < 5; i++) {
      debounced();
    }

    setState(() {
      _result += '5번 호출했지만 500ms 후 1번만 실행됩니다.';
    });
  }

  // throttle 예제
  void _throttleExample() {
    _result = 'throttle 예제:\n';
    setState(() {});

    final throttled = CustomTimerUtil.throttle(() {
      if (!mounted) return;
      setState(() {
        _result += '실행됨!\n';
      });
    }, Duration(milliseconds: 1000));

    // 빠르게 여러 번 호출
    for (int i = 0; i < 10; i++) {
      throttled();
    }

    setState(() {
      _result += '10번 호출했지만 1초마다 최대 1번만 실행됩니다.';
    });
  }

  // sequence 예제
  Future<void> _sequenceExample() async {
    _result = 'sequence 예제:\n';
    setState(() {});

    await CustomTimerUtil.sequence([
      () async {
        await CustomTimerUtil.waitForSeconds(1);
        if (!mounted) return;
        setState(() {
          _result += '작업 1 완료\n';
        });
      },
      () async {
        await CustomTimerUtil.waitForSeconds(1);
        if (!mounted) return;
        setState(() {
          _result += '작업 2 완료\n';
        });
      },
      () async {
        await CustomTimerUtil.waitForSeconds(1);
        if (!mounted) return;
        setState(() {
          _result += '작업 3 완료';
        });
      },
    ]);
  }

  // 타이머 취소 예제
  void _cancelTimerExample() {
    _periodicTimer?.cancel();
    _timerManager.cancelAll();
    setState(() {
      _result = '모든 타이머가 취소되었습니다.';
    });
  }

  // 여러 타이머 독립 실행 예제
  void _multipleTimersExample() {
    _result = '여러 타이머 독립 실행:\n';
    setState(() {});

    // 타이머 1: 1초마다 실행 (3회)
    int counter1 = 0;
    final timer1 = CustomTimerUtil.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      counter1++;
      setState(() {
        _result += '타이머 1: 카운트 $counter1\n';
      });
      if (counter1 >= 3) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _result += '타이머 1 종료\n';
        });
      }
    });

    // 타이머 2: 2초마다 실행 (2회)
    int counter2 = 0;
    final timer2 = CustomTimerUtil.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      counter2++;
      setState(() {
        _result += '타이머 2: 카운트 $counter2\n';
      });
      if (counter2 >= 2) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _result += '타이머 2 종료\n';
        });
      }
    });

    // 타이머 3: 3초 후 한 번 실행
    CustomTimerUtil.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _result += '타이머 3: 3초 후 실행됨\n';
      });
    });

    // 타이머 4: 5초 후 한 번 실행
    CustomTimerUtil.delayed(Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _result += '타이머 4: 5초 후 실행됨\n';
        _result += '\n모든 타이머가 독립적으로 실행되었습니다!';
      });
    });

    // 타이머 관리자에 추가
    _timerManager.add(timer1);
    _timerManager.add(timer2);
  }

  // async 함수 여러 개 동시 실행 예제
  Future<void> _multipleAsyncTimersExample() async {
    _result = '여러 async 타이머 동시 실행:\n';
    setState(() {});

    // 여러 async 함수를 동시에 실행 (독립적으로)
    final futures = [_asyncTimer1(), _asyncTimer2(), _asyncTimer3()];

    // 모든 타이머가 완료될 때까지 대기
    await Future.wait(futures);

    if (!mounted) return;
    setState(() {
      _result += '\n모든 async 타이머 완료!';
    });
  }

  Future<void> _asyncTimer1() async {
    for (int i = 1; i <= 3; i++) {
      await CustomTimerUtil.waitForSeconds(1.0);
      if (!mounted) return;
      setState(() {
        _result += 'Async 타이머 1: $i초\n';
      });
    }
  }

  Future<void> _asyncTimer2() async {
    for (int i = 1; i <= 2; i++) {
      await CustomTimerUtil.waitForSeconds(1.5);
      if (!mounted) return;
      setState(() {
        _result += 'Async 타이머 2: ${i * 1.5}초\n';
      });
    }
  }

  Future<void> _asyncTimer3() async {
    await CustomTimerUtil.waitForSeconds(2.0);
    if (!mounted) return;
    setState(() {
      _result += 'Async 타이머 3: 2초 후 실행\n';
    });
  }

  // ID 기반 타이머 제어 예제
  void _idBasedTimerExample() {
    _result = 'ID 기반 타이머 제어:\n';
    setState(() {});

    // ID로 타이머 생성
    CustomTimerUtil.createPeriodicWithId('counter', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('counter');
        return;
      }
      setState(() {
        _result += 'ID: counter - 실행 중...\n';
      });
    });

    CustomTimerUtil.createDelayedWithId('delayed1', Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _result += 'ID: delayed1 - 3초 후 실행됨\n';
      });
    });

    CustomTimerUtil.createDelayedWithId('delayed2', Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _result += 'ID: delayed2 - 5초 후 실행됨\n';
        _result += '\n활성 타이머 ID: ${CustomTimerUtil.getActiveTimerIds()}';
      });
    });

    setState(() {
      _result += '\n타이머 생성 완료!\n';
      _result += '활성 타이머 ID: ${CustomTimerUtil.getActiveTimerIds()}\n';
      _result += '\n3초 후 "counter" 타이머를 취소합니다.';
    });

    // 3초 후 특정 타이머 취소
    CustomTimerUtil.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      if (CustomTimerUtil.hasTimer('counter')) {
        CustomTimerUtil.cancelById('counter');
        if (!mounted) return;
        setState(() {
          _result += '\n\n"counter" 타이머 취소됨!\n';
          _result += '남은 타이머 ID: ${CustomTimerUtil.getActiveTimerIds()}';
        });
      }
    });
  }

  // ID로 타이머 취소 예제
  void _cancelByIdExample() {
    _result = 'ID로 타이머 취소:\n';
    setState(() {});

    // 여러 타이머 생성
    CustomTimerUtil.createPeriodicWithId('timer1', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer1');
        return;
      }
      setState(() {
        _result += '타이머 1 실행\n';
      });
    });

    CustomTimerUtil.createPeriodicWithId('timer2', Duration(seconds: 2), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer2');
        return;
      }
      setState(() {
        _result += '타이머 2 실행\n';
      });
    });

    setState(() {
      _result += '\n타이머 생성 완료!\n';
      _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
      _result += '\n2초 후 timer1 취소, 4초 후 timer2 취소';
    });

    // 2초 후 timer1 취소
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      CustomTimerUtil.cancelById('timer1');
      if (!mounted) return;
      setState(() {
        _result += '\n\ntimer1 취소됨!\n';
        _result += '남은 타이머: ${CustomTimerUtil.getActiveTimerIds()}';
      });
    });

    // 4초 후 timer2 취소
    CustomTimerUtil.delayed(Duration(seconds: 4), () {
      if (!mounted) return;
      CustomTimerUtil.cancelById('timer2');
      if (!mounted) return;
      setState(() {
        _result += '\n\ntimer2 취소됨!\n';
        _result += '남은 타이머: ${CustomTimerUtil.getActiveTimerIds()}';
      });
    });
  }

  // 모든 ID 기반 타이머 취소 예제
  void _cancelAllByIdExample() {
    _result = '모든 ID 기반 타이머 취소:\n';
    setState(() {});

    // 여러 타이머 생성
    CustomTimerUtil.createPeriodicWithId('timer1', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer1');
        return;
      }
      setState(() {
        _result += '타이머 1 실행\n';
      });
    });

    CustomTimerUtil.createPeriodicWithId('timer2', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer2');
        return;
      }
      setState(() {
        _result += '타이머 2 실행\n';
      });
    });

    CustomTimerUtil.createDelayedWithId('timer3', Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _result += '타이머 3 실행\n';
      });
    });

    setState(() {
      _result += '\n타이머 생성 완료!\n';
      _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
      _result += '\n2초 후 모든 타이머 취소';
    });

    // 2초 후 모든 타이머 취소
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      CustomTimerUtil.cancelAllById();
      if (!mounted) return;
      setState(() {
        _result += '\n\n모든 타이머 취소됨!\n';
        _result += '남은 타이머: ${CustomTimerUtil.getActiveTimerIds()}';
      });
    });
  }

  // ID로 타이머 일시정지/재개 예제
  void _pauseResumeExample() {
    _result = 'ID로 타이머 일시정지/재개:\n';
    setState(() {});

    // 반복 타이머 생성
    int counter = 0;
    CustomTimerUtil.createPeriodicWithId('counter', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('counter');
        return;
      }
      counter++;
      setState(() {
        _result += '카운터: $counter\n';
      });
    });

    setState(() {
      _result += '\n타이머 시작!\n';
      _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
      _result += '\n2초 후 일시정지, 4초 후 재개';
    });

    // 2초 후 일시정지
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      CustomTimerUtil.pauseById('counter');
      if (!mounted) return;
      setState(() {
        _result += '\n\n타이머 일시정지됨!\n';
        _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
        _result += '일시정지된 타이머: ${CustomTimerUtil.getPausedTimerIds()}';
      });
    });

    // 4초 후 재개
    CustomTimerUtil.delayed(Duration(seconds: 4), () {
      if (!mounted) return;
      CustomTimerUtil.resumeById('counter');
      if (!mounted) return;
      setState(() {
        _result += '\n\n타이머 재개됨!\n';
        _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
        _result += '일시정지된 타이머: ${CustomTimerUtil.getPausedTimerIds()}';
      });
    });
  }

  // 지연 타이머 일시정지/재개 예제
  void _pauseResumeDelayedExample() {
    _result = '지연 타이머 일시정지/재개:\n';
    setState(() {});

    // 5초 후 실행될 타이머 생성
    CustomTimerUtil.createDelayedWithId('delayed', Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _result += '\n\n5초 후 실행됨!';
      });
    });

    setState(() {
      _result += '5초 후 실행될 타이머 생성\n';
      _result += '\n2초 후 일시정지, 4초 후 재개';
    });

    // 2초 후 일시정지
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      CustomTimerUtil.pauseById('delayed');
      if (!mounted) return;
      setState(() {
        _result += '\n\n타이머 일시정지됨! (남은 시간 저장됨)';
      });
    });

    // 4초 후 재개 (총 7초 후 실행됨)
    CustomTimerUtil.delayed(Duration(seconds: 4), () {
      if (!mounted) return;
      CustomTimerUtil.resumeById('delayed');
      if (!mounted) return;
      setState(() {
        _result += '\n타이머 재개됨! (남은 3초 후 실행)';
      });
    });
  }

  // 모든 타이머 일시정지/재개 예제
  void _pauseResumeAllExample() {
    _result = '모든 타이머 일시정지/재개:\n';
    setState(() {});

    // 여러 타이머 생성
    CustomTimerUtil.createPeriodicWithId('timer1', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer1');
        return;
      }
      setState(() {
        _result += '타이머 1 실행\n';
      });
    });

    CustomTimerUtil.createPeriodicWithId('timer2', Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        CustomTimerUtil.cancelById('timer2');
        return;
      }
      setState(() {
        _result += '타이머 2 실행\n';
      });
    });

    setState(() {
      _result += '\n타이머 생성 완료!\n';
      _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
      _result += '\n2초 후 모든 타이머 일시정지, 4초 후 모든 타이머 재개';
    });

    // 2초 후 모든 타이머 일시정지
    CustomTimerUtil.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      CustomTimerUtil.pauseAllById();
      if (!mounted) return;
      setState(() {
        _result += '\n\n모든 타이머 일시정지됨!\n';
        _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
        _result += '일시정지된 타이머: ${CustomTimerUtil.getPausedTimerIds()}';
      });
    });

    // 4초 후 모든 타이머 재개
    CustomTimerUtil.delayed(Duration(seconds: 4), () {
      if (!mounted) return;
      CustomTimerUtil.resumeAllById();
      if (!mounted) return;
      setState(() {
        _result += '\n\n모든 타이머 재개됨!\n';
        _result += '활성 타이머: ${CustomTimerUtil.getActiveTimerIds()}\n';
        _result += '일시정지된 타이머: ${CustomTimerUtil.getPausedTimerIds()}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TimerUtil 예제')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _basicTimerExample,
                    child: const Text('기본 타이머 (2초 후 실행)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _periodicTimerExample,
                    child: const Text('반복 타이머 (1초마다)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _waitForSecondsExample,
                    child: const Text('waitForSeconds'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _waitUntilExample,
                    child: const Text('waitUntil'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _waitWhileExample,
                    child: const Text('waitWhile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _withTimeoutExample,
                    child: const Text('withTimeout'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retryExample,
                    child: const Text('retry (재시도)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _debounceExample,
                    child: const Text('debounce'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _throttleExample,
                    child: const Text('throttle'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _sequenceExample,
                    child: const Text('sequence (순차 실행)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _multipleTimersExample,
                    child: const Text('여러 타이머 독립 실행'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _multipleAsyncTimersExample,
                    child: const Text('여러 async 타이머 동시 실행'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _idBasedTimerExample,
                    child: const Text('ID 기반 타이머 제어'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _cancelByIdExample,
                    child: const Text('ID로 타이머 취소'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _cancelAllByIdExample,
                    child: const Text('모든 ID 타이머 취소'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pauseResumeExample,
                    child: const Text('ID로 일시정지/재개'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pauseResumeDelayedExample,
                    child: const Text('지연 타이머 일시정지/재개'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pauseResumeAllExample,
                    child: const Text('모든 타이머 일시정지/재개'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _cancelTimerExample,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('모든 타이머 취소'),
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
