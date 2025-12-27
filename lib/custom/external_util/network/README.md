# CustomNetworkUtil

HTTP 통신을 위한 네트워크 유틸리티 클래스입니다.

## 주요 기능

- GET, POST, PUT, DELETE, PATCH 요청
- JsonUtil과 연동하여 요청/응답 JSON 변환
- 헤더 관리 (기본 헤더, 인증 토큰)
- 에러 처리 (네트워크 에러, HTTP 에러, JSON 파싱 에러)
- 타임아웃 설정
- 쿼리 파라미터 자동 변환

## 기본 설정

```dart
// 기본 URL 설정
CustomNetworkUtil.setBaseUrl('https://api.example.com');

// 기본 헤더 설정
CustomNetworkUtil.setDefaultHeaders({
  'Content-Type': 'application/json',
  'Accept': 'application/json',
});

// 인증 토큰 설정
CustomNetworkUtil.setAuthToken('Bearer token123');

// 타임아웃 설정
CustomNetworkUtil.setTimeout(Duration(seconds: 60));
```

## 사용 예시

### GET 요청

```dart
// 기본 GET 요청
final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
  '/api/users',
);

if (response.success) {
  print(response.data);
} else {
  print('에러: ${response.error}');
}

// 객체로 변환
final response = await CustomNetworkUtil.get<User>(
  '/api/users/1',
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  final user = response.data;
  print('사용자: ${user?.name}');
}
```

### POST 요청

```dart
final response = await CustomNetworkUtil.post<User>(
  '/api/users',
  body: {
    'name': '홍길동',
    'age': 25,
  },
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  print('생성된 사용자: ${response.data?.name}');
}
```

### PUT 요청

```dart
final response = await CustomNetworkUtil.put<User>(
  '/api/users/1',
  body: {
    'name': '김철수',
    'age': 30,
  },
  fromJson: (json) => User.fromJson(json),
);
```

### DELETE 요청

```dart
final response = await CustomNetworkUtil.delete('/api/users/1');

if (response.success) {
  print('삭제 완료');
}
```

### PATCH 요청

```dart
final response = await CustomNetworkUtil.patch<User>(
  '/api/users/1',
  body: {
    'age': 30,
  },
  fromJson: (json) => User.fromJson(json),
);
```

### 쿼리 파라미터

```dart
final response = await CustomNetworkUtil.get(
  '/api/users',
  queryParams: {
    'page': '1',
    'limit': '10',
  },
);
```

### 커스텀 헤더

```dart
final response = await CustomNetworkUtil.get(
  '/api/users',
  headers: {
    'Custom-Header': 'value',
  },
);
```

### 타임아웃 설정

```dart
final response = await CustomNetworkUtil.get(
  '/api/users',
  timeout: Duration(seconds: 60),
);
```

## NetworkResponse

모든 요청은 `NetworkResponse<T>` 객체를 반환합니다.

```dart
class NetworkResponse<T> {
  final bool success;        // 성공 여부
  final T? data;             // 응답 데이터
  final String? error;       // 에러 메시지
  final int? statusCode;     // HTTP 상태 코드
  final Map<String, String>? headers;  // 응답 헤더
  final String? rawBody;     // 원본 응답 본문
}
```

## 에러 처리

```dart
final response = await CustomNetworkUtil.get('/api/users');

if (response.success) {
  // 성공 처리
  print(response.data);
} else {
  // 에러 처리
  print('에러: ${response.error}');
  print('상태 코드: ${response.statusCode}');
}
```

## JsonUtil 연동

NetworkUtil은 내부적으로 JsonUtil을 사용하여 JSON 변환을 처리합니다.

- **요청 데이터**: 객체 → JSON (JsonUtil.encode)
- **응답 데이터**: JSON → 객체 (JsonUtil.fromJson)

## 의존성

- `http: ^1.1.0` 패키지 필요
- `custom_json_util` (프로젝트 내부)

## 참고

- 기본 타임아웃: 30초
- 기본 Content-Type: application/json
- 모든 요청은 비동기로 처리됩니다.
