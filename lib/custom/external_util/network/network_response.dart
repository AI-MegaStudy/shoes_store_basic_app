// 네트워크 응답 모델 클래스
//
// HTTP 요청의 응답을 담는 클래스입니다.
//
// 사용 예시:
// ```dart
// final response = await CustomNetworkUtil.get('/api/users');
// if (response.success) {
//   print(response.data);
// } else {
//   print('에러: ${response.error}');
// }
// ```
class NetworkResponse<T> {
  // 요청 성공 여부
  final bool success;

  // 응답 데이터 (성공 시)
  final T? data;

  // 에러 메시지 (실패 시)
  final String? error;

  // HTTP 상태 코드
  final int? statusCode;

  // 응답 헤더
  final Map<String, String>? headers;

  // 원본 응답 본문 (JSON 문자열)
  final String? rawBody;

  // 생성자
  NetworkResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.headers,
    this.rawBody,
  });

  // 성공 응답 생성
  factory NetworkResponse.success({
    T? data,
    int? statusCode,
    Map<String, String>? headers,
    String? rawBody,
  }) {
    return NetworkResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
      headers: headers,
      rawBody: rawBody,
    );
  }

  // 실패 응답 생성
  factory NetworkResponse.failure({
    String? error,
    int? statusCode,
    Map<String, String>? headers,
    String? rawBody,
  }) {
    return NetworkResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
      headers: headers,
      rawBody: rawBody,
    );
  }

  @override
  String toString() {
    return 'NetworkResponse(success: $success, data: $data, error: $error, statusCode: $statusCode)';
  }
}
