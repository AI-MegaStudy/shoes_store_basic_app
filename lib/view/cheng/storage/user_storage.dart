import 'package:shoes_store_basic_app/core/global_storage.dart';
import 'package:shoes_store_basic_app/model/customer.dart';

/// 사용자 정보 저장소 클래스
class UserStorage {
  static GlobalStorage get _storage => GlobalStorage.instance;

  static const String _keyCustomerId = 'user_customer_id';
  static const String _keyCustomerEmail = 'user_customer_email';
  static const String _keyCustomerPhoneNumber = 'user_customer_phone_number';
  static const String _keyCustomerName = 'user_customer_name';

  /// 사용자 정보 저장
  static void saveUser(Customer customer) {
    if (customer.id != null) {
      _storage.save(_keyCustomerId, customer.id);
    }
    _storage.save(_keyCustomerEmail, customer.cEmail);
    _storage.save(_keyCustomerPhoneNumber, customer.cPhoneNumber);
    _storage.save(_keyCustomerName, customer.cName);
  }

  /// 저장된 사용자 정보 가져오기
  static Customer? getUser() {
    final email = _storage.get<String>(_keyCustomerEmail);
    final phoneNumber = _storage.get<String>(_keyCustomerPhoneNumber);
    final name = _storage.get<String>(_keyCustomerName);
    final id = _storage.get<int>(_keyCustomerId);

    if (email == null || phoneNumber == null || name == null) {
      return null;
    }

    return Customer(
      id: id,
      cEmail: email,
      cPhoneNumber: phoneNumber,
      cName: name,
      cPassword: '',
    );
  }

  /// 사용자 이름 가져오기
  static String? getUserName() {
    return _storage.get<String>(_keyCustomerName);
  }

  /// 사용자 이메일 가져오기
  static String? getUserEmail() {
    return _storage.get<String>(_keyCustomerEmail);
  }

  /// 사용자 전화번호 가져오기
  static String? getUserPhoneNumber() {
    return _storage.get<String>(_keyCustomerPhoneNumber);
  }

  /// 사용자 ID 가져오기
  static int? getUserId() {
    return _storage.get<int>(_keyCustomerId);
  }

  /// 사용자 정보 삭제 (로그아웃 시 호출)
  static void clearUser() {
    _storage.remove(_keyCustomerId);
    _storage.remove(_keyCustomerEmail);
    _storage.remove(_keyCustomerPhoneNumber);
    _storage.remove(_keyCustomerName);
  }

  /// 사용자 로그인 여부 확인
  static bool isUserLoggedIn() {
    return _storage.containsKey(_keyCustomerEmail);
  }
}

