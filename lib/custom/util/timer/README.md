# CustomTimerUtil

타이머 유틸리티 클래스입니다. Dart의 Timer를 래핑하여 Unity 코루틴과 유사한 기능을 제공합니다.

## 주요 기능

- 기본 타이머 (지연 실행, 반복 실행)
- 코루틴 유사 기능 (waitForSeconds, waitUntil, waitWhile 등)
- 고급 타이머 기능 (타임아웃, 재시도, 디바운싱, 스로틀링)
- 타이머 관리 (여러 타이머 일괄 취소)

## 의존성

외부 패키지 불필요 (순수 Dart)

## 기본 사용법

### 기본 타이머

```dart
// 일정 시간 후 실행
final timer = CustomTimerUtil.delayed(
  Duration(seconds: 2),
  () => print('2초 후 실행'),
);

// 나중에 취소 가능
timer.cancel();

// 반복 실행
final periodicTimer = CustomTimerUtil.periodic(
  Duration(seconds: 1),
  (timer) => print('1초마다 실행'),
);
```

### 코루틴 유사 기능

```dart
// 일정 시간 대기 (Unity의 WaitForSeconds)
await CustomTimerUtil.waitForSeconds(2.0);

// 조건 만족까지 대기 (Unity의 WaitUntil)
bool isReady = false;
await CustomTimerUtil.waitUntil(() => isReady);

// 조건 만족되는 동안 대기 (Unity의 WaitWhile)
bool isLoading = true;
await CustomTimerUtil.waitWhile(() => isLoading);

// 다음 프레임까지 대기 (Unity의 yield return null)
await CustomTimerUtil.waitForNextFrame();
```

## 고급 기능

### 타임아웃

```dart
try {
  final result = await CustomTimerUtil.withTimeout(
    someAsyncFunction(),
    Duration(seconds: 5),
    onTimeout: () => '타임아웃',
  );
} catch (e) {
  print('타임아웃 발생');
}
```

### 재시도

```dart
final result = await CustomTimerUtil.retry(
  () => apiCall(),
  maxRetries: 3,
  delay: Duration(seconds: 1),
);
```

### 디바운싱

```dart
final debounced = CustomTimerUtil.debounce(
  () => performSearch(),
  Duration(milliseconds: 500),
);

// 여러 번 호출해도 마지막 호출만 실행
debounced();
debounced();
debounced(); // 이것만 실행됨
```

### 스로틀링

```dart
final throttled = CustomTimerUtil.throttle(
  () => handleScroll(),
  Duration(milliseconds: 100),
);

// 빠르게 여러 번 호출해도 100ms마다 최대 1번만 실행
throttled();
throttled();
throttled();
```

### 순차 실행

```dart
await CustomTimerUtil.sequence([
  () => task1(),
  () => task2(),
  () => task3(),
]);
```

## Unity 코루틴과의 비교

| Unity 코루틴                                  | CustomTimerUtil                                    |
| --------------------------------------------- | -------------------------------------------------- |
| `yield return new WaitForSeconds(2)`          | `await CustomTimerUtil.waitForSeconds(2.0)`        |
| `yield return new WaitUntil(() => condition)` | `await CustomTimerUtil.waitUntil(() => condition)` |
| `yield return new WaitWhile(() => condition)` | `await CustomTimerUtil.waitWhile(() => condition)` |
| `yield return null`                           | `await CustomTimerUtil.waitForNextFrame()`         |

## 타이머 관리

### 변수 기반 관리

```dart
final manager = TimerManager();

// 타이머 추가
manager.add(timer1);
manager.add(timer2);

// 모든 타이머 취소
manager.cancelAll();
```

### ID 기반 관리

ID로 타이머를 생성하고 제어할 수 있습니다.

```dart
// ID로 타이머 생성 (지연 실행)
CustomTimerUtil.createDelayedWithId(
  'timer1',
  Duration(seconds: 2),
  () => print('2초 후 실행'),
);

// ID로 타이머 생성 (반복 실행)
CustomTimerUtil.createPeriodicWithId(
  'counter',
  Duration(seconds: 1),
  (timer) => print('1초마다 실행'),
);

// ID로 타이머 취소
CustomTimerUtil.cancelById('timer1');

// ID로 타이머 존재 여부 확인
if (CustomTimerUtil.hasTimer('counter')) {
  print('타이머가 활성화되어 있습니다');
}

// 모든 ID 기반 타이머 취소
CustomTimerUtil.cancelAllById();

// 활성화된 타이머 ID 목록 가져오기
final activeIds = CustomTimerUtil.getActiveTimerIds();
print('활성 타이머: $activeIds');

// 일시정지된 타이머 ID 목록 가져오기
final pausedIds = CustomTimerUtil.getPausedTimerIds();
print('일시정지된 타이머: $pausedIds');
```

### ID로 타이머 일시정지/재개

```dart
// 타이머 생성
CustomTimerUtil.createPeriodicWithId(
  'counter',
  Duration(seconds: 1),
  (timer) => print('1초마다 실행'),
);

// 일시정지
CustomTimerUtil.pauseById('counter');

// 일시정지 상태 확인
if (CustomTimerUtil.isPaused('counter')) {
  print('타이머가 일시정지되어 있습니다');
}

// 재개
CustomTimerUtil.resumeById('counter');

// 모든 타이머 일시정지
CustomTimerUtil.pauseAllById();

// 모든 타이머 재개
CustomTimerUtil.resumeAllById();
```

**일시정지/재개 동작:**

- **지연 실행 타이머**: 일시정지 시 남은 시간을 저장하고, 재개 시 남은 시간으로 새 타이머 생성
- **반복 실행 타이머**: 일시정지 시 타이머 취소, 재개 시 새 타이머 생성

**ID 기반 관리의 장점:**

- 변수를 저장하지 않아도 타이머 제어 가능
- 여러 곳에서 같은 ID로 타이머 제어 가능
- 타이머 목록 확인 및 일괄 관리 용이
- 일시정지/재개 기능으로 타이머 제어 유연성 향상

## 여러 타이머 독립 실행

타이머는 여러 개를 동시에 독립적으로 실행할 수 있습니다.

### 기본 타이머 (Timer)

```dart
// 타이머 1: 1초마다 실행
final timer1 = CustomTimerUtil.periodic(
  Duration(seconds: 1),
  (timer) => print('타이머 1'),
);

// 타이머 2: 2초마다 실행 (독립적으로 동시 실행)
final timer2 = CustomTimerUtil.periodic(
  Duration(seconds: 2),
  (timer) => print('타이머 2'),
);

// 타이머 3: 3초 후 실행 (독립적으로 동시 실행)
CustomTimerUtil.delayed(
  Duration(seconds: 3),
  () => print('타이머 3'),
);

// 각 타이머는 독립적으로 실행되며 서로 영향을 주지 않습니다
```

### async 함수 (Future)

```dart
// 여러 async 함수를 동시에 실행
Future<void> example() async {
  // 각각 독립적으로 실행
  final futures = [
    _timer1(),
    _timer2(),
    _timer3(),
  ];

  // 모든 타이머가 완료될 때까지 대기
  await Future.wait(futures);
}

Future<void> _timer1() async {
  await CustomTimerUtil.waitForSeconds(1.0);
  print('타이머 1 완료');
}

Future<void> _timer2() async {
  await CustomTimerUtil.waitForSeconds(2.0);
  print('타이머 2 완료');
}

Future<void> _timer3() async {
  await CustomTimerUtil.waitForSeconds(3.0);
  print('타이머 3 완료');
}
```

### 타이머 관리

```dart
final manager = TimerManager();

// 여러 타이머를 관리자에 추가
manager.add(timer1);
manager.add(timer2);
manager.add(timer3);

// 필요시 모든 타이머 일괄 취소
manager.cancelAll();
```

## 주요 사용 사례

- 애니메이션 시퀀스
- 게임 로직 (Unity 코루틴과 유사)
- API 호출 재시도
- 사용자 입력 디바운싱/스로틀링
- 순차적 작업 실행
- 타임아웃 처리
- 여러 독립적인 타이머 동시 실행

## 예제

자세한 사용 예제는 `example.dart` 파일을 참고하세요.
