import 'dart:async';
import 'package:flutter/material.dart';

// 타이머 유틸리티 클래스
// Dart의 Timer를 래핑하여 Unity 코루틴과 유사한 기능을 제공합니다.
class CustomTimerUtil {
  // ============================================
  // 기본 타이머 기능
  // ============================================

  // 일정 시간 후 실행되는 타이머 생성
  //
  // 사용 예시:
  // ```dart
  // final timer = CustomTimerUtil.delayed(
  //   Duration(seconds: 2),
  //   () => print('2초 후 실행'),
  // );
  //
  // // 나중에 취소 가능
  // timer.cancel();
  // ```
  static Timer delayed(Duration duration, VoidCallback callback) {
    return Timer(duration, callback);
  }

  // 일정 간격으로 반복 실행되는 타이머 생성
  //
  // 사용 예시:
  // ```dart
  // final timer = CustomTimerUtil.periodic(
  //   Duration(seconds: 1),
  //   (timer) => print('1초마다 실행'),
  // );
  //
  // // 나중에 취소 가능
  // timer.cancel();
  // ```
  static Timer periodic(Duration duration, void Function(Timer) callback) {
    return Timer.periodic(duration, callback);
  }

  // ============================================
  // 코루틴 유사 기능 (async/await)
  // ============================================

  // 일정 시간 대기 (Unity의 WaitForSeconds와 유사)
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.waitForSeconds(2.0);
  // print('2초 후 실행');
  // ```
  static Future<void> waitForSeconds(double seconds) async {
    await Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));
  }

  // 조건이 만족될 때까지 대기 (Unity의 WaitUntil과 유사)
  //
  // 사용 예시:
  // ```dart
  // bool isReady = false;
  // await CustomTimerUtil.waitUntil(() => isReady);
  // print('준비 완료!');
  // ```
  static Future<void> waitUntil(
    bool Function() condition, {
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    while (!condition()) {
      await Future.delayed(checkInterval);
    }
  }

  // 조건이 만족되는 동안 대기 (Unity의 WaitWhile과 유사)
  //
  // 사용 예시:
  // ```dart
  // bool isLoading = true;
  // await CustomTimerUtil.waitWhile(() => isLoading);
  // print('로딩 완료!');
  // ```
  static Future<void> waitWhile(
    bool Function() condition, {
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    while (condition()) {
      await Future.delayed(checkInterval);
    }
  }

  // 여러 조건 중 하나가 만족될 때까지 대기
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.waitUntilAny([
  //   () => condition1,
  //   () => condition2,
  // ]);
  // ```
  static Future<void> waitUntilAny(
    List<bool Function()> conditions, {
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    while (true) {
      for (final condition in conditions) {
        if (condition()) {
          return;
        }
      }
      await Future.delayed(checkInterval);
    }
  }

  // 모든 조건이 만족될 때까지 대기
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.waitUntilAll([
  //   () => condition1,
  //   () => condition2,
  // ]);
  // ```
  static Future<void> waitUntilAll(
    List<bool Function()> conditions, {
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    while (true) {
      bool allSatisfied = true;
      for (final condition in conditions) {
        if (!condition()) {
          allSatisfied = false;
          break;
        }
      }
      if (allSatisfied) return;
      await Future.delayed(checkInterval);
    }
  }

  // 다음 프레임까지 대기 (Unity의 yield return null과 유사)
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.waitForNextFrame();
  // ```
  static Future<void> waitForNextFrame() async {
    await Future.delayed(Duration.zero);
  }

  // ============================================
  // 고급 타이머 기능
  // ============================================

  // 일정 시간 후 실행되는 Future 반환
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.delayedFuture(Duration(seconds: 2));
  // print('2초 후 실행');
  // ```
  static Future<void> delayedFuture(Duration duration) async {
    await Future.delayed(duration);
  }

  // 타임아웃이 있는 Future 실행
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final result = await CustomTimerUtil.withTimeout(
  //     someAsyncFunction(),
  //     Duration(seconds: 5),
  //   );
  // } catch (e) {
  //   print('타임아웃 발생');
  // }
  // ```
  static Future<T> withTimeout<T>(
    Future<T> future,
    Duration timeout, {
    T Function()? onTimeout,
  }) async {
    try {
      return await future.timeout(timeout);
    } on TimeoutException {
      if (onTimeout != null) {
        return onTimeout();
      }
      rethrow;
    }
  }

  // 여러 Future 중 가장 먼저 완료되는 것 반환
  //
  // 사용 예시:
  // ```dart
  // final result = await CustomTimerUtil.race([
  //   slowOperation(),
  //   fastOperation(),
  // ]);
  // ```
  static Future<T> race<T>(List<Future<T>> futures) {
    return Future.any(futures);
  }

  // 여러 Future를 순차적으로 실행
  //
  // 사용 예시:
  // ```dart
  // await CustomTimerUtil.sequence([
  //   () => task1(),
  //   () => task2(),
  //   () => task3(),
  // ]);
  // ```
  static Future<void> sequence(List<Future<void> Function()> tasks) async {
    for (final task in tasks) {
      await task();
    }
  }

  // 여러 Future를 순차적으로 실행하고 결과 수집
  //
  // 사용 예시:
  // ```dart
  // final results = await CustomTimerUtil.sequenceWithResults([
  //   () => task1(),
  //   () => task2(),
  // ]);
  // ```
  static Future<List<T>> sequenceWithResults<T>(
    List<Future<T> Function()> tasks,
  ) async {
    final results = <T>[];
    for (final task in tasks) {
      results.add(await task());
    }
    return results;
  }

  // 재시도 로직이 있는 Future 실행
  //
  // 사용 예시:
  // ```dart
  // final result = await CustomTimerUtil.retry(
  //   () => apiCall(),
  //   maxRetries: 3,
  //   delay: Duration(seconds: 1),
  // );
  // ```
  static Future<T> retry<T>(
    Future<T> Function() task, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Object)? shouldRetry,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await task();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  // 지연 실행이 가능한 작업 실행
  //
  // 사용 예시:
  // ```dart
  // final debounced = CustomTimerUtil.debounce(
  //   () => performSearch(),
  //   Duration(milliseconds: 500),
  // );
  //
  // // 여러 번 호출해도 마지막 호출만 실행
  // debounced();
  // debounced();
  // debounced(); // 이것만 실행됨
  // ```
  static VoidCallback debounce(VoidCallback callback, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, callback);
    };
  }

  // 스로틀링된 함수 반환 (일정 시간 간격으로만 실행)
  //
  // 사용 예시:
  // ```dart
  // final throttled = CustomTimerUtil.throttle(
  //   () => handleScroll(),
  //   Duration(milliseconds: 100),
  // );
  //
  // // 빠르게 여러 번 호출해도 100ms마다 최대 1번만 실행
  // throttled();
  // throttled();
  // throttled();
  // ```
  static VoidCallback throttle(VoidCallback callback, Duration delay) {
    Timer? timer;
    bool isThrottled = false;

    return () {
      if (isThrottled) return;

      isThrottled = true;
      callback();

      timer?.cancel();
      timer = Timer(delay, () {
        isThrottled = false;
      });
    };
  }
  // ============================================
  // ID 기반 타이머 관리
  // ============================================

  // ID로 타이머를 관리하는 매니저 인스턴스
  static final TimerIdManager idManager = TimerIdManager();

  // ID로 타이머 생성 (지연 실행)
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.createDelayedWithId(
  //   'timer1',
  //   Duration(seconds: 2),
  //   () => print('2초 후 실행'),
  // );
  //
  // // 나중에 ID로 취소
  // CustomTimerUtil.cancelById('timer1');
  //
  // // 일시정지/재개
  // CustomTimerUtil.pauseById('timer1');
  // CustomTimerUtil.resumeById('timer1');
  // ```
  static void createDelayedWithId(
    String id,
    Duration duration,
    VoidCallback callback,
  ) {
    final timer = delayed(duration, callback);
    idManager.addDelayed(id, timer, duration, callback);
  }

  // ID로 타이머 생성 (반복 실행)
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.createPeriodicWithId(
  //   'timer1',
  //   Duration(seconds: 1),
  //   (timer) => print('1초마다 실행'),
  // );
  //
  // // 나중에 ID로 취소
  // CustomTimerUtil.cancelById('timer1');
  //
  // // 일시정지/재개
  // CustomTimerUtil.pauseById('timer1');
  // CustomTimerUtil.resumeById('timer1');
  // ```
  static void createPeriodicWithId(
    String id,
    Duration duration,
    void Function(Timer) callback,
  ) {
    final timer = periodic(duration, callback);
    idManager.addPeriodic(id, timer, duration, callback);
  }

  // ID로 타이머 취소
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.cancelById('timer1');
  // ```
  static bool cancelById(String id) {
    return idManager.cancel(id);
  }

  // ID로 타이머 존재 여부 확인
  //
  // 사용 예시:
  // ```dart
  // if (CustomTimerUtil.hasTimer('timer1')) {
  //   print('타이머가 활성화되어 있습니다');
  // }
  // ```
  static bool hasTimer(String id) {
    return idManager.hasTimer(id);
  }

  // 모든 ID 기반 타이머 취소
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.cancelAllById();
  // ```
  static void cancelAllById() {
    idManager.cancelAll();
  }

  // 활성화된 타이머 ID 목록 가져오기
  //
  // 사용 예시:
  // ```dart
  // final activeIds = CustomTimerUtil.getActiveTimerIds();
  // print('활성 타이머: $activeIds');
  // ```
  static List<String> getActiveTimerIds() {
    return idManager.getActiveIds();
  }

  // ID로 타이머 일시정지
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.pauseById('timer1');
  // ```
  static bool pauseById(String id) {
    return idManager.pause(id);
  }

  // ID로 타이머 재개
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.resumeById('timer1');
  // ```
  static bool resumeById(String id) {
    return idManager.resume(id);
  }

  // ID로 타이머 일시정지 상태 확인
  //
  // 사용 예시:
  // ```dart
  // if (CustomTimerUtil.isPaused('timer1')) {
  //   print('타이머가 일시정지되어 있습니다');
  // }
  // ```
  static bool isPaused(String id) {
    return idManager.isPaused(id);
  }

  // 모든 ID 기반 타이머 일시정지
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.pauseAllById();
  // ```
  static void pauseAllById() {
    idManager.pauseAll();
  }

  // 모든 ID 기반 타이머 재개
  //
  // 사용 예시:
  // ```dart
  // CustomTimerUtil.resumeAllById();
  // ```
  static void resumeAllById() {
    idManager.resumeAll();
  }

  // 일시정지된 타이머 ID 목록 가져오기
  //
  // 사용 예시:
  // ```dart
  // final pausedIds = CustomTimerUtil.getPausedTimerIds();
  // print('일시정지된 타이머: $pausedIds');
  // ```
  static List<String> getPausedTimerIds() {
    return idManager.getPausedIds();
  }
}

// 여러 타이머를 관리하는 클래스
class TimerManager {
  final List<Timer> _timers = [];

  // 타이머 추가
  void add(Timer timer) {
    _timers.add(timer);
  }

  // 모든 타이머 취소
  void cancelAll() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  // 활성 타이머 개수
  int get activeCount => _timers.length;

  // 모든 타이머가 활성화되어 있는지 확인
  bool get hasActiveTimers => _timers.isNotEmpty;
}

// 타이머 정보를 저장하는 클래스
class _TimerInfo {
  Timer timer;
  DateTime? startTime;
  Duration? remainingDuration;
  Duration? interval;
  VoidCallback? delayedCallback;
  void Function(Timer)? periodicCallback;
  bool isPaused;

  _TimerInfo({
    required this.timer,
    this.startTime,
    this.remainingDuration,
    this.interval,
    this.delayedCallback,
    this.periodicCallback,
  }) : isPaused = false;
}

// ID 기반 타이머 관리 클래스
class TimerIdManager {
  final Map<String, _TimerInfo> _timers = {};
  final Map<String, DateTime> _pauseTimes = {};

  // ID로 타이머 추가 (지연 실행)
  void addDelayed(
    String id,
    Timer timer,
    Duration duration,
    VoidCallback callback,
  ) {
    // 기존 타이머가 있으면 취소
    _timers[id]?.timer.cancel();
    _timers[id] = _TimerInfo(
      timer: timer,
      startTime: DateTime.now(),
      remainingDuration: duration,
      delayedCallback: callback,
    );
  }

  // ID로 타이머 추가 (반복 실행)
  void addPeriodic(
    String id,
    Timer timer,
    Duration interval,
    void Function(Timer) callback,
  ) {
    // 기존 타이머가 있으면 취소
    _timers[id]?.timer.cancel();
    _timers[id] = _TimerInfo(
      timer: timer,
      startTime: DateTime.now(),
      interval: interval,
      periodicCallback: callback,
    );
  }

  // ID로 타이머 추가 (내부 사용)
  void add(String id, Timer timer) {
    // 기존 타이머가 있으면 취소
    _timers[id]?.timer.cancel();
    _timers[id] = _TimerInfo(timer: timer);
  }

  // ID로 타이머 취소
  bool cancel(String id) {
    final info = _timers.remove(id);
    _pauseTimes.remove(id);
    if (info != null) {
      info.timer.cancel();
      return true;
    }
    return false;
  }

  // ID로 타이머 존재 여부 확인
  bool hasTimer(String id) {
    return _timers.containsKey(id);
  }

  // ID로 타이머 일시정지
  bool pause(String id) {
    final info = _timers[id];
    if (info == null || info.isPaused) return false;

    info.isPaused = true;
    _pauseTimes[id] = DateTime.now();

    // 타이머 취소
    info.timer.cancel();

    // 남은 시간 계산 (지연 실행 타이머인 경우)
    if (info.remainingDuration != null && info.startTime != null) {
      final elapsed = DateTime.now().difference(info.startTime!);
      final remaining = info.remainingDuration! - elapsed;
      if (remaining.isNegative) {
        info.remainingDuration = Duration.zero;
      } else {
        info.remainingDuration = remaining;
      }
    }

    return true;
  }

  // ID로 타이머 재개
  bool resume(String id) {
    final info = _timers[id];
    if (info == null || !info.isPaused) return false;

    final pauseTime = _pauseTimes.remove(id);
    if (pauseTime == null) return false;

    info.isPaused = false;

    // 지연 실행 타이머 재개
    if (info.delayedCallback != null && info.remainingDuration != null) {
      final newTimer = Timer(info.remainingDuration!, info.delayedCallback!);
      info.timer = newTimer;
      info.startTime = DateTime.now();
      return true;
    }

    // 반복 실행 타이머 재개
    if (info.periodicCallback != null && info.interval != null) {
      final newTimer = Timer.periodic(info.interval!, info.periodicCallback!);
      info.timer = newTimer;
      info.startTime = DateTime.now();
      return true;
    }

    return false;
  }

  // ID로 타이머 일시정지 상태 확인
  bool isPaused(String id) {
    return _timers[id]?.isPaused ?? false;
  }

  // 모든 타이머 일시정지
  void pauseAll() {
    final ids = _timers.keys.toList();
    for (final id in ids) {
      pause(id);
    }
  }

  // 모든 타이머 재개
  void resumeAll() {
    final ids = _timers.keys.toList();
    for (final id in ids) {
      resume(id);
    }
  }

  // 모든 타이머 취소
  void cancelAll() {
    for (final info in _timers.values) {
      info.timer.cancel();
    }
    _timers.clear();
    _pauseTimes.clear();
  }

  // 활성화된 타이머 ID 목록
  List<String> getActiveIds() {
    return _timers.keys
        .where((id) => !(_timers[id]?.isPaused ?? true))
        .toList();
  }

  // 일시정지된 타이머 ID 목록
  List<String> getPausedIds() {
    return _timers.keys.where((id) => _timers[id]?.isPaused ?? false).toList();
  }

  // 활성 타이머 개수
  int get activeCount => _timers.values.where((info) => !info.isPaused).length;

  // 일시정지된 타이머 개수
  int get pausedCount => _timers.values.where((info) => info.isPaused).length;

  // 모든 타이머가 활성화되어 있는지 확인
  bool get hasActiveTimers => activeCount > 0;
}
