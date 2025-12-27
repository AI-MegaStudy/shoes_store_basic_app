import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 로컬 스토리지 유틸리티 클래스
// SharedPreferences를 래핑하여 간편하게 사용할 수 있는 유틸리티입니다.
//
// 주요 기능:
// - 타입 안전한 저장/불러오기 (String, int, bool, double)
// - 객체 저장/불러오기 (JSON 직렬화/역직렬화)
// - 리스트 저장/불러오기
// - 키 삭제 및 전체 삭제
class CustomStorageUtil {
  // SharedPreferences 인스턴스 (싱글톤)
  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  // 앱 시작 시 한 번 호출해야 합니다.
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.init();
  // ```
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // SharedPreferences 인스턴스 가져오기
  // init()이 호출되지 않았으면 자동으로 초기화합니다.
  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============================================
  // 기본 타입 저장/불러오기
  // ============================================

  // 문자열 저장
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.setString('username', '홍길동');
  // ```
  static Future<bool> setString(String key, String value) async {
    final prefs = await _getPrefs();
    return await prefs.setString(key, value);
  }

  // 문자열 불러오기
  //
  // 사용 예시:
  // ```dart
  // final username = await CustomStorageUtil.getString('username');
  // ```
  static Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  // 정수 저장
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.setInt('age', 25);
  // ```
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _getPrefs();
    return await prefs.setInt(key, value);
  }

  // 정수 불러오기
  //
  // 사용 예시:
  // ```dart
  // final age = await CustomStorageUtil.getInt('age');
  // ```
  static Future<int?> getInt(String key) async {
    final prefs = await _getPrefs();
    return prefs.getInt(key);
  }

  // 불린 저장
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.setBool('isDarkMode', true);
  // ```
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    return await prefs.setBool(key, value);
  }

  // 불린 불러오기
  //
  // 사용 예시:
  // ```dart
  // final isDarkMode = await CustomStorageUtil.getBool('isDarkMode');
  // ```
  static Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  // 실수 저장
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.setDouble('price', 99.99);
  // ```
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _getPrefs();
    return await prefs.setDouble(key, value);
  }

  // 실수 불러오기
  //
  // 사용 예시:
  // ```dart
  // final price = await CustomStorageUtil.getDouble('price');
  // ```
  static Future<double?> getDouble(String key) async {
    final prefs = await _getPrefs();
    return prefs.getDouble(key);
  }

  // 문자열 리스트 저장
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.setStringList('tags', ['flutter', 'dart', 'mobile']);
  // ```
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _getPrefs();
    return await prefs.setStringList(key, value);
  }

  // 문자열 리스트 불러오기
  //
  // 사용 예시:
  // ```dart
  // final tags = await CustomStorageUtil.getStringList('tags');
  // ```
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _getPrefs();
    return prefs.getStringList(key);
  }

  // ============================================
  // 객체 저장/불러오기 (JSON)
  // ============================================

  // 객체 저장 (JSON 직렬화)
  //
  // 사용 예시:
  // ```dart
  // final user = User(name: '홍길동', age: 25);
  // await CustomStorageUtil.setObject('user', user);
  // ```
  static Future<bool> setObject<T>(String key, T object) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(object);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  // 객체 불러오기 (JSON 역직렬화)
  //
  // 사용 예시:
  // ```dart
  // final user = await CustomStorageUtil.getObject<User>('user');
  // ```
  static Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // 리스트 저장 (JSON 직렬화)
  //
  // 사용 예시:
  // ```dart
  // final items = [Item(name: '사과'), Item(name: '바나나')];
  // await CustomStorageUtil.setList('items', items);
  // ```
  static Future<bool> setList<T>(String key, List<T> list) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(list);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  // 리스트 불러오기 (JSON 역직렬화)
  //
  // 사용 예시:
  // ```dart
  // final items = await CustomStorageUtil.getList<Item>('items', (json) => Item.fromJson(json));
  // ```
  static Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 유틸리티 메서드
  // ============================================

  // 키 삭제
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.remove('username');
  // ```
  static Future<bool> remove(String key) async {
    final prefs = await _getPrefs();
    return await prefs.remove(key);
  }

  // 모든 데이터 삭제
  //
  // 사용 예시:
  // ```dart
  // await CustomStorageUtil.clear();
  // ```
  static Future<bool> clear() async {
    final prefs = await _getPrefs();
    return await prefs.clear();
  }

  // 키 존재 여부 확인
  //
  // 사용 예시:
  // ```dart
  // final exists = await CustomStorageUtil.containsKey('username');
  // ```
  static Future<bool> containsKey(String key) async {
    final prefs = await _getPrefs();
    return prefs.containsKey(key);
  }

  // 모든 키 가져오기
  //
  // 사용 예시:
  // ```dart
  // final keys = await CustomStorageUtil.getAllKeys();
  // ```
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _getPrefs();
    return prefs.getKeys();
  }
}
