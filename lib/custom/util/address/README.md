# CustomAddressUtil

BigDataCloud Reverse Geocoding API 응답을 파싱하여 주소 텍스트를 생성하는 유틸리티 클래스입니다.

## 주요 기능

- 위도/경도로 직접 주소 가져오기 (API 자동 호출)
- BigDataCloud API 응답 JSON을 파싱하여 주소 문자열 생성
- 국가명 포함/제외 옵션
- 커스텀 구분자 설정
- 상세 주소 정보 추출
- **강화된 예외 처리**: 좌표 유효성 검증, 네트워크 타임아웃, 상세한 에러 메시지
- **타임아웃 설정**: API 요청 타임아웃 설정 가능 (기본값: 10초)

## 사용 예시

### 위도/경도로 주소 가져오기 (가장 간단한 방법)

```dart
import 'custom_address_util.dart';

// 위도, 경도로 주소 가져오기 (예외 처리 포함)
try {
  final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
  print(address); // "대한민국 서울특별시 송파구 가락2동"
} on AddressException catch (e) {
  print('주소 가져오기 실패: ${e.message} (코드: ${e.code})');
}

// 간단한 주소 (국가 제외)
try {
  final simpleAddress = await CustomAddressUtil.getSimpleAddressFromCoordinates(37.497429, 127.127782);
  print(simpleAddress); // "서울특별시 송파구 가락2동"
} on AddressException catch (e) {
  print('주소 가져오기 실패: ${e.message}');
}

// 상세 주소 정보
try {
  final addressInfo = await CustomAddressUtil.getAddressInfoFromCoordinates(37.497429, 127.127782);
  print(addressInfo?['district']); // "송파구"
  print(addressInfo?['fullAddress']); // "대한민국 서울특별시 송파구 가락2동"
} on AddressException catch (e) {
  print('주소 정보 가져오기 실패: ${e.message}');
}
```

### JSON 문자열로 파싱 (기존 방법)

```dart
import 'package:http/http.dart' as http;
import 'custom_address_util.dart';

// BigDataCloud API 호출
final response = await http.get(
  Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=37.497429&longitude=127.127782&localityLanguage=ko')
);

// 주소 파싱
final address = CustomAddressUtil.parseAddress(response.body);
print(address); // "대한민국 서울특별시 송파구 가락2동"
```

### 간단한 주소 (국가 제외)

```dart
final simpleAddress = CustomAddressUtil.parseSimpleAddress(jsonString);
print(simpleAddress); // "서울특별시 송파구 가락2동"
```

### 커스텀 구분자 사용

```dart
// 쉼표로 구분
final addressWithComma = CustomAddressUtil.parseAddress(
  jsonString,
  separator: ", ",
);
// "대한민국, 서울특별시, 송파구, 가락2동"

// 화살표로 구분
final addressWithArrow = CustomAddressUtil.parseAddress(
  jsonString,
  separator: " > ",
  includeCountry: false,
);
// "서울특별시 > 송파구 > 가락2동"
```

### 상세 주소 정보 가져오기

```dart
final addressInfo = CustomAddressUtil.getAddressInfo(jsonString);
if (addressInfo != null) {
  print(addressInfo['countryName']); // "대한민국"
  print(addressInfo['province']);     // "서울특별시"
  print(addressInfo['city']);         // "서울특별시"
  print(addressInfo['district']);    // "송파구"
  print(addressInfo['locality']);     // "가락2동"
  print(addressInfo['fullAddress']);  // "대한민국 서울특별시 송파구 가락2동"
}
```

### Map 형태의 JSON에서 파싱

```dart
final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
final address = CustomAddressUtil.parseAddressFromMap(jsonMap);
```

## 메서드 목록

### `getAddressFromCoordinates(double latitude, double longitude, {String language = 'ko', String separator = " ", bool includeCountry = true})`

위도와 경도를 받아서 BigDataCloud API를 호출하고 주소를 반환합니다.

**파라미터:**
- `latitude`: 위도 (-90 ~ 90)
- `longitude`: 경도 (-180 ~ 180)
- `language`: 언어 코드 (기본값: "ko" - 한국어)
- `separator`: 주소 구성 요소 사이의 구분자 (기본값: " ")
- `includeCountry`: 국가명 포함 여부 (기본값: true)
- `timeout`: 요청 타임아웃 (기본값: 10초)

**반환값:** 파싱된 주소 문자열 또는 `null`

**예외:** `AddressException` - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시

### `getSimpleAddressFromCoordinates(double latitude, double longitude, {String language = 'ko'})`

위도와 경도로 간단한 주소를 가져옵니다 (국가 제외).

**파라미터:**
- `latitude`: 위도 (-90 ~ 90)
- `longitude`: 경도 (-180 ~ 180)
- `language`: 언어 코드 (기본값: "ko" - 한국어)
- `timeout`: 요청 타임아웃 (기본값: 10초)

**반환값:** 간단한 주소 문자열 또는 `null`

**예외:** `AddressException` - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시

### `getAddressInfoFromCoordinates(double latitude, double longitude, {String language = 'ko'})`

위도와 경도로 상세 주소 정보를 가져옵니다.

**파라미터:**
- `latitude`: 위도 (-90 ~ 90)
- `longitude`: 경도 (-180 ~ 180)
- `language`: 언어 코드 (기본값: "ko" - 한국어)
- `timeout`: 요청 타임아웃 (기본값: 10초)

**반환값:** 주소 정보가 담긴 Map 또는 `null`

**예외:** `AddressException` - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시

### `parseAddress(String jsonString, {String separator = " ", bool includeCountry = true})`

JSON 문자열을 파싱하여 주소 텍스트를 반환합니다.

**파라미터:**
- `jsonString`: BigDataCloud API 응답 JSON 문자열
- `separator`: 주소 구성 요소 사이의 구분자 (기본값: " ")
- `includeCountry`: 국가명 포함 여부 (기본값: true)

**반환값:** 파싱된 주소 문자열 또는 `null`

**예외:** `AddressException` - JSON 파싱 오류 발생 시

### `parseSimpleAddress(String jsonString)`

국가명을 제외한 간단한 주소를 반환합니다.

**파라미터:**
- `jsonString`: BigDataCloud API 응답 JSON 문자열

**반환값:** 간단한 주소 문자열 또는 `null`

### `parseAddressFromMap(Map<String, dynamic> json, {String separator = " ", bool includeCountry = true})`

Map 형태의 JSON 데이터로부터 주소 텍스트를 생성합니다.

**파라미터:**
- `json`: BigDataCloud API 응답 Map
- `separator`: 주소 구성 요소 사이의 구분자 (기본값: " ")
- `includeCountry`: 국가명 포함 여부 (기본값: true)

**반환값:** 파싱된 주소 문자열 또는 `null`

### `getAddressInfo(String jsonString)`

상세 주소 정보를 Map으로 반환합니다.

**파라미터:**
- `jsonString`: BigDataCloud API 응답 JSON 문자열

**반환값:** 주소 정보가 담긴 Map 또는 `null`

**Map 키:**
- `countryName`: 국가명
- `province`: 시/도
- `city`: 시
- `district`: 구/군
- `locality`: 동/읍/면
- `fullAddress`: 전체 주소

## 주소 구성 순서

주소는 다음 순서로 구성됩니다:

1. 국가명 (선택사항)
2. 시/도 (principalSubdivision 또는 city)
3. 구/군 (localityInfo.administrative에서 adminLevel 6인 항목)
4. 동/읍/면 (locality)

## 예외 처리

모든 API 호출 메서드는 `AddressException`을 던질 수 있습니다. 예외 코드로 오류 유형을 구분할 수 있습니다:

- `INVALID_COORDINATE`: 유효하지 않은 좌표
- `TIMEOUT`: API 요청 타임아웃
- `NETWORK_ERROR`: 네트워크 연결 오류
- `HTTP_ERROR`: HTTP 상태 코드 오류
- `PARSE_ERROR`: JSON 파싱 오류
- `DECODE_ERROR`: JSON 디코딩 오류
- `INVALID_FORMAT`: 잘못된 JSON 형식
- `EMPTY_JSON`: 빈 JSON 문자열
- `NO_ADDRESS_DATA`: 주소 데이터 없음
- `UNKNOWN_ERROR`: 알 수 없는 오류

```dart
try {
  final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
} on AddressException catch (e) {
  switch (e.code) {
    case 'INVALID_COORDINATE':
      print('좌표가 유효하지 않습니다.');
      break;
    case 'TIMEOUT':
      print('요청 시간이 초과되었습니다.');
      break;
    case 'NETWORK_ERROR':
      print('네트워크 연결을 확인해주세요.');
      break;
    default:
      print('오류 발생: ${e.message}');
  }
}
```

## 의존성

- `http`: API 호출을 위해 사용 (위도/경도 메서드 사용 시)
- `CustomJsonUtil`: JSON 파싱을 위해 사용

## 참고

- BigDataCloud API: https://www.bigdatacloud.com/docs/api/reverse-geocoding-api
- API 응답 형식에 따라 주소 구성이 달라질 수 있습니다.

