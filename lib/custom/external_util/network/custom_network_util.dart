import 'package:http/http.dart' as http;
import '../../util/json/custom_json_util.dart';
import 'network_response.dart';

// 네트워크 통신 유틸리티 클래스
// HTTP 통신을 위한 유틸리티 클래스입니다.
//
// 주요 기능:
// - GET, POST, PUT, DELETE, PATCH 요청
// - JsonUtil과 연동하여 요청/응답 JSON 변환
// - 헤더 관리 (기본 헤더, 인증 토큰)
// - 에러 처리
// - 타임아웃 설정
class CustomNetworkUtil {
  // 기본 URL (선택적)
  static String? baseUrl;

  // 기본 헤더
  static Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  // 기본 타임아웃 (30초)
  static Duration timeout = const Duration(seconds: 30);

  // 인증 토큰
  static String? authToken;

  // ============================================
  // 설정 메서드
  // ============================================

  // 기본 URL 설정
  //
  // 사용 예시:
  // ```dart
  // CustomNetworkUtil.setBaseUrl('https://api.example.com');
  // ```
  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // 기본 헤더 설정
  //
  // 사용 예시:
  // ```dart
  // CustomNetworkUtil.setDefaultHeaders({
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  // });
  // ```
  static void setDefaultHeaders(Map<String, String> headers) {
    defaultHeaders = headers;
  }

  // 인증 토큰 설정
  //
  // 사용 예시:
  // ```dart
  // CustomNetworkUtil.setAuthToken('Bearer token123');
  // ```
  static void setAuthToken(String token) {
    authToken = token;
    defaultHeaders['Authorization'] = token;
  }

  // 타임아웃 설정
  //
  // 사용 예시:
  // ```dart
  // CustomNetworkUtil.setTimeout(Duration(seconds: 60));
  // ```
  static void setTimeout(Duration duration) {
    timeout = duration;
  }

  // ============================================
  // 헬퍼 메서드
  // ============================================

  // 전체 URL 생성
  static String _buildUrl(String endpoint) {
    if (baseUrl == null) {
      return endpoint;
    }
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$cleanEndpoint';
  }

  // 헤더 병합
  static Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final merged = Map<String, String>.from(defaultHeaders);
    if (headers != null) {
      merged.addAll(headers);
    }
    return merged;
  }

  // 쿼리 파라미터를 URL에 추가
  static String _addQueryParams(String url, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return url;
    }

    final uri = Uri.parse(url);
    final queryMap = Map<String, String>.from(uri.queryParameters);
    queryParams.forEach((key, value) {
      queryMap[key] = value.toString();
    });

    return uri.replace(queryParameters: queryMap).toString();
  }

  // 응답 처리
  static NetworkResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 성공
        T? data;
        if (fromJson != null && response.body.isNotEmpty) {
          final json = CustomJsonUtil.decode(response.body);
          if (json is Map<String, dynamic>) {
            data = fromJson(json);
          }
        } else if (response.body.isNotEmpty) {
          // fromJson이 없으면 원본 데이터 반환
          final json = CustomJsonUtil.decode(response.body);
          data = json as T?;
        }

        return NetworkResponse<T>.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
          rawBody: response.body,
        );
      } else {
        // HTTP 에러
        return NetworkResponse<T>.failure(
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
          headers: response.headers,
          rawBody: response.body,
        );
      }
    } catch (e) {
      // JSON 파싱 에러
      return NetworkResponse<T>.failure(
        error: 'JSON 파싱 에러: $e',
        statusCode: response.statusCode,
        headers: response.headers,
        rawBody: response.body,
      );
    }
  }

  // 에러 처리
  static NetworkResponse<T> _handleError<T>(dynamic error) {
    if (error is http.ClientException) {
      return NetworkResponse<T>.failure(error: '네트워크 에러: ${error.message}');
    } else if (error is FormatException) {
      return NetworkResponse<T>.failure(error: 'URL 형식 에러: ${error.message}');
    } else {
      return NetworkResponse<T>.failure(error: '알 수 없는 에러: $error');
    }
  }

  // ============================================
  // HTTP 메서드
  // ============================================

  // GET 요청
  //
  // 사용 예시:
  // ```dart
  // final response = await CustomNetworkUtil.get<User>(
  //   '/api/users/1',
  //   fromJson: (json) => User.fromJson(json),
  // );
  // ```
  static Future<NetworkResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _addQueryParams(_buildUrl(endpoint), queryParams);
      final mergedHeaders = _mergeHeaders(headers);

      final response = await http
          .get(Uri.parse(url), headers: mergedHeaders)
          .timeout(timeout ?? CustomNetworkUtil.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST 요청
  //
  // 사용 예시:
  // ```dart
  // final response = await CustomNetworkUtil.post<User>(
  //   '/api/users',
  //   body: {'name': '홍길동', 'age': 25},
  //   fromJson: (json) => User.fromJson(json),
  // );
  // ```
  static Future<NetworkResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final mergedHeaders = _mergeHeaders(headers);
      final jsonBody = body != null ? CustomJsonUtil.encode(body) : null;

      final response = await http
          .post(Uri.parse(url), headers: mergedHeaders, body: jsonBody)
          .timeout(timeout ?? CustomNetworkUtil.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT 요청
  //
  // 사용 예시:
  // ```dart
  // final response = await CustomNetworkUtil.put<User>(
  //   '/api/users/1',
  //   body: {'name': '김철수'},
  //   fromJson: (json) => User.fromJson(json),
  // );
  // ```
  static Future<NetworkResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final mergedHeaders = _mergeHeaders(headers);
      final jsonBody = body != null ? CustomJsonUtil.encode(body) : null;

      final response = await http
          .put(Uri.parse(url), headers: mergedHeaders, body: jsonBody)
          .timeout(timeout ?? CustomNetworkUtil.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE 요청
  //
  // 사용 예시:
  // ```dart
  // final response = await CustomNetworkUtil.delete('/api/users/1');
  // ```
  static Future<NetworkResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final mergedHeaders = _mergeHeaders(headers);

      final response = await http
          .delete(Uri.parse(url), headers: mergedHeaders)
          .timeout(timeout ?? CustomNetworkUtil.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PATCH 요청
  //
  // 사용 예시:
  // ```dart
  // final response = await CustomNetworkUtil.patch<User>(
  //   '/api/users/1',
  //   body: {'age': 30},
  //   fromJson: (json) => User.fromJson(json),
  // );
  // ```
  static Future<NetworkResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final mergedHeaders = _mergeHeaders(headers);
      final jsonBody = body != null ? CustomJsonUtil.encode(body) : null;

      final response = await http
          .patch(Uri.parse(url), headers: mergedHeaders, body: jsonBody)
          .timeout(timeout ?? CustomNetworkUtil.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
}
