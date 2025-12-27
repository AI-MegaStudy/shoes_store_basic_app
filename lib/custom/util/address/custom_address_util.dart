import 'dart:async';

import 'package:http/http.dart' as http;

import '../json/custom_json_util.dart';

// 주소 파싱 예외 클래스
class AddressException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AddressException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AddressException: $message${code != null ? ' (코드: $code)' : ''}';
}

// 주소 파싱 유틸리티 클래스
// BigDataCloud Reverse Geocoding API 응답을 파싱하여 주소 텍스트를 생성합니다.
//
// 사용 예시:
// ```dart
// // 위도, 경도로 주소 가져오기
// try {
//   final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
//   print(address); // "대한민국 서울특별시 송파구 가락2동"
// } on AddressException catch (e) {
//   print('주소 가져오기 실패: ${e.message}');
// }
//
// // JSON 문자열로 파싱
// final jsonString = await http.get('https://api.bigdatacloud.net/...');
// final address = CustomAddressUtil.parseAddress(jsonString);
// print(address); // "대한민국 서울특별시 송파구 가락2동"
// ```
class CustomAddressUtil {
  // BigDataCloud API 기본 URL
  static const String _baseUrl =
      'https://api.bigdatacloud.net/data/reverse-geocode-client';

  // API 요청 타임아웃 (초)
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // 좌표 유효성 검증
  static bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // 위도와 경도를 받아서 주소를 가져옵니다
  //
  // [latitude] 위도 (-90 ~ 90)
  // [longitude] 경도 (-180 ~ 180)
  // [language] 언어 코드 (기본값: "ko" - 한국어)
  // [separator] 주소 구성 요소 사이의 구분자 (기본값: " ")
  // [includeCountry] 국가명 포함 여부 (기본값: true)
  // [timeout] 요청 타임아웃 (기본값: 10초)
  //
  // 반환값: 파싱된 주소 문자열 (예: "대한민국 서울특별시 송파구 가락2동")
  //
  // 예외: [AddressException] - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
  //   print(address); // "대한민국 서울특별시 송파구 가락2동"
  // } on AddressException catch (e) {
  //   print('주소 가져오기 실패: ${e.message}');
  // }
  //
  // final simpleAddress = await CustomAddressUtil.getAddressFromCoordinates(
  //   37.497429,
  //   127.127782,
  //   includeCountry: false,
  // );
  // print(simpleAddress); // "서울특별시 송파구 가락2동"
  // ```
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    String language = 'ko',
    String separator = " ",
    bool includeCountry = true,
    Duration? timeout,
  }) async {
    // 좌표 유효성 검증
    if (!_isValidCoordinate(latitude, longitude)) {
      throw AddressException(
        '유효하지 않은 좌표입니다. 위도: $latitude, 경도: $longitude',
        code: 'INVALID_COORDINATE',
      );
    }

    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude&localityLanguage=$language',
      );

      // 타임아웃 설정
      final response = await http
          .get(url)
          .timeout(
            timeout ?? _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'API 요청이 타임아웃되었습니다. (${timeout?.inSeconds ?? _timeoutDuration.inSeconds}초)',
                timeout ?? _timeoutDuration,
              );
            },
          );

      // HTTP 상태 코드 확인
      if (response.statusCode == 200) {
        try {
          final address = parseAddress(
            response.body,
            separator: separator,
            includeCountry: includeCountry,
          );

          if (address == null || address.isEmpty) {
            throw AddressException('주소 정보를 파싱할 수 없습니다.', code: 'PARSE_ERROR');
          }

          return address;
        } catch (e) {
          if (e is AddressException) {
            rethrow;
          }
          throw AddressException(
            '주소 파싱 중 오류가 발생했습니다: ${e.toString()}',
            code: 'PARSE_ERROR',
            originalError: e,
          );
        }
      } else {
        throw AddressException(
          'API 요청 실패: HTTP ${response.statusCode}',
          code: 'HTTP_ERROR',
        );
      }
    } on TimeoutException catch (e) {
      throw AddressException(
        'API 요청 타임아웃: ${e.message}',
        code: 'TIMEOUT',
        originalError: e,
      );
    } on http.ClientException catch (e) {
      throw AddressException(
        '네트워크 연결 오류: ${e.message}',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } on AddressException {
      rethrow;
    } catch (e) {
      throw AddressException(
        '알 수 없는 오류가 발생했습니다: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  // 위도와 경도를 받아서 간단한 주소를 가져옵니다 (국가 제외)
  //
  // [latitude] 위도 (-90 ~ 90)
  // [longitude] 경도 (-180 ~ 180)
  // [language] 언어 코드 (기본값: "ko" - 한국어)
  // [timeout] 요청 타임아웃 (기본값: 10초)
  //
  // 반환값: 간단한 주소 문자열 (예: "서울특별시 송파구 가락2동")
  //
  // 예외: [AddressException] - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final address = await CustomAddressUtil.getSimpleAddressFromCoordinates(37.497429, 127.127782);
  //   print(address); // "서울특별시 송파구 가락2동"
  // } on AddressException catch (e) {
  //   print('주소 가져오기 실패: ${e.message}');
  // }
  // ```
  static Future<String?> getSimpleAddressFromCoordinates(
    double latitude,
    double longitude, {
    String language = 'ko',
    Duration? timeout,
  }) async {
    return getAddressFromCoordinates(
      latitude,
      longitude,
      language: language,
      includeCountry: false,
      timeout: timeout,
    );
  }

  // 위도와 경도를 받아서 상세 주소 정보를 가져옵니다
  //
  // [latitude] 위도 (-90 ~ 90)
  // [longitude] 경도 (-180 ~ 180)
  // [language] 언어 코드 (기본값: "ko" - 한국어)
  // [timeout] 요청 타임아웃 (기본값: 10초)
  //
  // 반환값: 주소 정보가 담긴 Map
  // - countryName: 국가명
  // - province: 시/도
  // - city: 시
  // - district: 구/군
  // - locality: 동/읍/면
  // - fullAddress: 전체 주소
  //
  // 예외: [AddressException] - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final addressInfo = await CustomAddressUtil.getAddressInfoFromCoordinates(37.497429, 127.127782);
  //   print(addressInfo?['countryName']); // "대한민국"
  //   print(addressInfo?['district']); // "송파구"
  //   print(addressInfo?['fullAddress']); // "대한민국 서울특별시 송파구 가락2동"
  // } on AddressException catch (e) {
  //   print('주소 정보 가져오기 실패: ${e.message}');
  // }
  // ```
  static Future<Map<String, String?>?> getAddressInfoFromCoordinates(
    double latitude,
    double longitude, {
    String language = 'ko',
    Duration? timeout,
  }) async {
    // 좌표 유효성 검증
    if (!_isValidCoordinate(latitude, longitude)) {
      throw AddressException(
        '유효하지 않은 좌표입니다. 위도: $latitude, 경도: $longitude',
        code: 'INVALID_COORDINATE',
      );
    }

    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude&localityLanguage=$language',
      );

      // 타임아웃 설정
      final response = await http
          .get(url)
          .timeout(
            timeout ?? _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'API 요청이 타임아웃되었습니다. (${timeout?.inSeconds ?? _timeoutDuration.inSeconds}초)',
                timeout ?? _timeoutDuration,
              );
            },
          );

      // HTTP 상태 코드 확인
      if (response.statusCode == 200) {
        try {
          final addressInfo = getAddressInfo(response.body);

          if (addressInfo == null || addressInfo.isEmpty) {
            throw AddressException('주소 정보를 파싱할 수 없습니다.', code: 'PARSE_ERROR');
          }

          return addressInfo;
        } catch (e) {
          if (e is AddressException) {
            rethrow;
          }
          throw AddressException(
            '주소 정보 파싱 중 오류가 발생했습니다: ${e.toString()}',
            code: 'PARSE_ERROR',
            originalError: e,
          );
        }
      } else {
        throw AddressException(
          'API 요청 실패: HTTP ${response.statusCode}',
          code: 'HTTP_ERROR',
        );
      }
    } on TimeoutException catch (e) {
      throw AddressException(
        'API 요청 타임아웃: ${e.message}',
        code: 'TIMEOUT',
        originalError: e,
      );
    } on http.ClientException catch (e) {
      throw AddressException(
        '네트워크 연결 오류: ${e.message}',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } on AddressException {
      rethrow;
    } catch (e) {
      throw AddressException(
        '알 수 없는 오류가 발생했습니다: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  // BigDataCloud API 응답 JSON 문자열을 파싱하여 주소 텍스트로 변환
  //
  // [jsonString] BigDataCloud Reverse Geocoding API 응답 JSON 문자열
  // [separator] 주소 구성 요소 사이의 구분자 (기본값: " ")
  // [includeCountry] 국가명 포함 여부 (기본값: true)
  //
  // 반환값: 파싱된 주소 문자열 (예: "대한민국 서울특별시 송파구 가락2동")
  //
  // 예외: [AddressException] - JSON 파싱 오류 발생 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final address = CustomAddressUtil.parseAddress(jsonString);
  //   // "대한민국 서울특별시 송파구 가락2동"
  // } on AddressException catch (e) {
  //   print('주소 파싱 실패: ${e.message}');
  // }
  //
  // final addressWithoutCountry = CustomAddressUtil.parseAddress(
  //   jsonString,
  //   includeCountry: false,
  // );
  // // "서울특별시 송파구 가락2동"
  //
  // final addressWithComma = CustomAddressUtil.parseAddress(
  //   jsonString,
  //   separator: ", ",
  // );
  // // "대한민국, 서울특별시, 송파구, 가락2동"
  // ```
  static String? parseAddress(
    String jsonString, {
    String separator = " ",
    bool includeCountry = true,
  }) {
    try {
      if (jsonString.isEmpty) {
        throw AddressException('JSON 문자열이 비어있습니다.', code: 'EMPTY_JSON');
      }

      final json = CustomJsonUtil.decode(jsonString);
      if (json == null) {
        throw AddressException('JSON 디코딩에 실패했습니다.', code: 'DECODE_ERROR');
      }

      if (json is! Map<String, dynamic>) {
        throw AddressException(
          'JSON 형식이 올바르지 않습니다. Map 형식이어야 합니다.',
          code: 'INVALID_FORMAT',
        );
      }

      final address = _buildAddressFromJson(
        json,
        separator: separator,
        includeCountry: includeCountry,
      );

      if (address == null || address.isEmpty) {
        throw AddressException('주소 정보를 추출할 수 없습니다.', code: 'NO_ADDRESS_DATA');
      }

      return address;
    } on AddressException {
      rethrow;
    } catch (e) {
      throw AddressException(
        '주소 파싱 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PARSE_ERROR',
        originalError: e,
      );
    }
  }

  // Map 형태의 JSON 데이터로부터 주소 텍스트 생성
  //
  // [json] BigDataCloud API 응답 Map
  // [separator] 주소 구성 요소 사이의 구분자
  // [includeCountry] 국가명 포함 여부
  //
  // 반환값: 파싱된 주소 문자열
  //
  // 예외: [AddressException] - 주소 정보 추출 실패 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  //   final address = CustomAddressUtil.parseAddressFromMap(jsonMap);
  // } on AddressException catch (e) {
  //   print('주소 파싱 실패: ${e.message}');
  // }
  // ```
  static String? parseAddressFromMap(
    Map<String, dynamic> json, {
    String separator = " ",
    bool includeCountry = true,
  }) {
    try {
      final address = _buildAddressFromJson(
        json,
        separator: separator,
        includeCountry: includeCountry,
      );

      if (address == null || address.isEmpty) {
        throw AddressException('주소 정보를 추출할 수 없습니다.', code: 'NO_ADDRESS_DATA');
      }

      return address;
    } on AddressException {
      rethrow;
    } catch (e) {
      throw AddressException(
        '주소 파싱 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PARSE_ERROR',
        originalError: e,
      );
    }
  }

  // JSON에서 주소 정보 추출 및 조합
  static String? _buildAddressFromJson(
    Map<String, dynamic> json, {
    required String separator,
    required bool includeCountry,
  }) {
    final List<String> addressParts = [];

    // 국가명 추가
    if (includeCountry) {
      final countryName = json['countryName'] as String?;
      if (countryName != null && countryName.isNotEmpty) {
        addressParts.add(countryName);
      }
    }

    // 시/도 정보 (principalSubdivision 또는 city)
    final principalSubdivision = json['principalSubdivision'] as String?;
    final city = json['city'] as String?;

    // principalSubdivision이 있으면 사용, 없으면 city 사용
    final cityOrProvince = principalSubdivision ?? city;
    if (cityOrProvince != null && cityOrProvince.isNotEmpty) {
      // 중복 제거 (예: "서울특별시"가 두 번 나오는 경우)
      if (!addressParts.contains(cityOrProvince)) {
        addressParts.add(cityOrProvince);
      }
    }

    // 구 정보 추출 (localityInfo.administrative에서 adminLevel 6인 항목)
    final localityInfo = json['localityInfo'] as Map<String, dynamic>?;
    if (localityInfo != null) {
      final administrative = localityInfo['administrative'] as List<dynamic>?;
      if (administrative != null) {
        for (final admin in administrative) {
          if (admin is Map<String, dynamic>) {
            final adminLevel = admin['adminLevel'] as int?;
            final name = admin['name'] as String?;

            // adminLevel 6은 구/군 단위
            if (adminLevel == 6 && name != null && name.isNotEmpty) {
              if (!addressParts.contains(name)) {
                addressParts.add(name);
              }
              break; // 첫 번째 매칭되는 구 정보만 사용
            }
          }
        }
      }
    }

    // 동/읍/면 정보 (locality)
    final locality = json['locality'] as String?;
    if (locality != null && locality.isNotEmpty) {
      addressParts.add(locality);
    }

    // 주소 구성 요소가 없으면 null 반환
    if (addressParts.isEmpty) {
      return null;
    }

    return addressParts.join(separator);
  }

  // 간단한 주소 형식 (국가 제외, 시/도, 구, 동만)
  //
  // 사용 예시:
  // ```dart
  // final simpleAddress = CustomAddressUtil.parseSimpleAddress(jsonString);
  // // "서울특별시 송파구 가락2동"
  // ```
  static String? parseSimpleAddress(String jsonString) {
    return parseAddress(jsonString, includeCountry: false);
  }

  // 상세 주소 정보를 Map으로 반환
  //
  // 반환값: 주소 정보가 담긴 Map
  // - countryName: 국가명
  // - province: 시/도
  // - city: 시
  // - district: 구/군
  // - locality: 동/읍/면
  // - fullAddress: 전체 주소
  //
  // 예외: [AddressException] - JSON 파싱 오류 발생 시
  //
  // 사용 예시:
  // ```dart
  // try {
  //   final addressInfo = CustomAddressUtil.getAddressInfo(jsonString);
  //   print(addressInfo?['countryName']); // "대한민국"
  //   print(addressInfo?['district']); // "송파구"
  //   print(addressInfo?['fullAddress']); // "대한민국 서울특별시 송파구 가락2동"
  // } on AddressException catch (e) {
  //   print('주소 정보 파싱 실패: ${e.message}');
  // }
  // ```
  static Map<String, String?>? getAddressInfo(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        throw AddressException('JSON 문자열이 비어있습니다.', code: 'EMPTY_JSON');
      }

      final json = CustomJsonUtil.decode(jsonString);
      if (json == null) {
        throw AddressException('JSON 디코딩에 실패했습니다.', code: 'DECODE_ERROR');
      }

      if (json is! Map<String, dynamic>) {
        throw AddressException(
          'JSON 형식이 올바르지 않습니다. Map 형식이어야 합니다.',
          code: 'INVALID_FORMAT',
        );
      }

      final countryName = json['countryName'] as String?;
      final principalSubdivision = json['principalSubdivision'] as String?;
      final city = json['city'] as String?;
      final locality = json['locality'] as String?;

      // 구 정보 추출
      String? district;
      final localityInfo = json['localityInfo'] as Map<String, dynamic>?;
      if (localityInfo != null) {
        final administrative = localityInfo['administrative'] as List<dynamic>?;
        if (administrative != null) {
          for (final admin in administrative) {
            if (admin is Map<String, dynamic>) {
              final adminLevel = admin['adminLevel'] as int?;
              final name = admin['name'] as String?;
              if (adminLevel == 6 && name != null && name.isNotEmpty) {
                district = name;
                break;
              }
            }
          }
        }
      }

      final fullAddress = _buildAddressFromJson(
        json,
        separator: " ",
        includeCountry: true,
      );

      return {
        'countryName': countryName,
        'province': principalSubdivision,
        'city': city,
        'district': district,
        'locality': locality,
        'fullAddress': fullAddress,
      };
    } on AddressException {
      rethrow;
    } catch (e) {
      throw AddressException(
        '주소 정보 파싱 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PARSE_ERROR',
        originalError: e,
      );
    }
  }
}
