/// 전역 저장소 클래스 (메모리 기반 휘발성 저장소)
class GlobalStorage {
  static final GlobalStorage instance = GlobalStorage._();
  
  GlobalStorage._();

  final Map<String, dynamic> _storage = {};

  /// 값을 저장
  void save(String key, dynamic value) {
    _storage[key] = value;
  }

  /// 키에 해당하는 값을 가져오기
  T? get<T>(String key) {
    final value = _storage[key];
    if (value == null) return null;
    
    try {
      return value as T;
    } catch (e) {
      return null;
    }
  }

  /// 키가 존재하는지 확인
  bool containsKey(String key) {
    return _storage.containsKey(key);
  }

  /// 키가 사용 가능한지 확인 (중복 검사)
  bool isKeyAvailable(String key) {
    return !_storage.containsKey(key);
  }

  /// 저장된 키-값 쌍 삭제
  dynamic remove(String key) {
    return _storage.remove(key);
  }

  /// 모든 데이터 삭제
  void clear() {
    _storage.clear();
  }

  /// 저장된 모든 키 반환
  List<String> getAllKeys() {
    return _storage.keys.toList();
  }

  /// 저장된 데이터 개수
  int get length => _storage.length;

  /// 저장소가 비어있는지 확인
  bool get isEmpty => _storage.isEmpty;

  /// 저장소가 비어있지 않은지 확인
  bool get isNotEmpty => _storage.isNotEmpty;

  /// 저장된 값의 타입 반환
  String? getType(String key) {
    final value = _storage[key];
    if (value == null) return null;
    return value.runtimeType.toString();
  }

  /// String 타입으로 값 가져오기
  String? getString(String key) {
    final value = _storage[key];
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// int 타입으로 값 가져오기
  int? getInt(String key) {
    final value = _storage[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// double 타입으로 값 가져오기
  double? getDouble(String key) {
    final value = _storage[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// bool 타입으로 값 가져오기
  bool? getBool(String key) {
    final value = _storage[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }

  /// 저장된 값이 특정 타입인지 확인
  bool isType(String key, String type) {
    final valueType = getType(key);
    return valueType == type;
  }

  /// 저장된 값이 기본 타입(String, int, bool, double)인지 확인
  bool isPrimitiveType(String key) {
    final type = getType(key);
    if (type == null) return false;
    return ['String', 'int', 'bool', 'double'].contains(type);
  }
}

