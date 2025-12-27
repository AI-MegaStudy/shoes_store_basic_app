import 'package:shoes_store_basic_app/core/global_storage.dart';
import 'package:shoes_store_basic_app/model/employee.dart';

/// 관리자 정보 저장소 클래스
class AdminStorage {
  static GlobalStorage get _storage => GlobalStorage.instance;

  static const String _keyEmployeeId = 'admin_employee_id';
  static const String _keyEmployeeEmail = 'admin_employee_email';
  static const String _keyEmployeePhone = 'admin_employee_phone';
  static const String _keyEmployeeName = 'admin_employee_name';

  /// 관리자 정보 저장
  static void saveAdmin(Employee employee) {
    if (employee.id != null) {
      _storage.save(_keyEmployeeId, employee.id);
    }
    _storage.save(_keyEmployeeEmail, employee.eEmail);
    _storage.save(_keyEmployeePhone, employee.ePhoneNumber);
    _storage.save(_keyEmployeeName, employee.eName);
    _storage.save('admin_role', employee.eRole);
  }

  /// 저장된 관리자 정보 가져오기
  static Employee? getAdmin() {
    final email = _storage.get<String>(_keyEmployeeEmail);
    final phone = _storage.get<String>(_keyEmployeePhone);
    final name = _storage.get<String>(_keyEmployeeName);
    final id = _storage.get<int>(_keyEmployeeId);

    if (email == null || phone == null || name == null) {
      return null;
    }

    return Employee(
      id: id,
      eEmail: email,
      ePhoneNumber: phone,
      eName: name,
      ePassword: '',
      eRole: getAdminRole(),
    );
  }

  /// 관리자 이름 가져오기
  static String? getAdminName() {
    return _storage.get<String>(_keyEmployeeName);
  }

  /// 관리자 이메일 가져오기
  static String? getAdminEmail() {
    return _storage.get<String>(_keyEmployeeEmail);
  }

  /// 관리자 역할 가져오기 (기본값: '관리자')
  static String getAdminRole() {
    return _storage.get<String>('admin_role') ?? '관리자';
  }

  /// 관리자 역할 저장
  static void saveAdminRole(String role) {
    _storage.save('admin_role', role);
  }

  /// 관리자 정보 삭제 (로그아웃 시 호출)
  static void clearAdmin() {
    _storage.remove(_keyEmployeeId);
    _storage.remove(_keyEmployeeEmail);
    _storage.remove(_keyEmployeePhone);
    _storage.remove(_keyEmployeeName);
    _storage.remove('admin_role');
  }

  /// 관리자 로그인 여부 확인
  static bool isAdminLoggedIn() {
    return _storage.containsKey(_keyEmployeeEmail);
  }
}

