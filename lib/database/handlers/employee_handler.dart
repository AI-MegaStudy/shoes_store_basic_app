import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/employee.dart';
import 'package:sqflite/sqflite.dart';

/// Employee 테이블 핸들러
class EmployeeHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 조회 메서드
  // ============================================

  /// 전체 직원 조회
  Future<List<Employee>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      orderBy: 'id ASC',
    );
    return results.map((e) => Employee.fromMap(e)).toList();
  }

  /// ID로 직원 조회
  Future<Employee?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Employee.fromMap(results.first);
  }

  /// 이메일로 직원 조회
  Future<Employee?> queryByEmail(String email) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      where: 'eEmail = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Employee.fromMap(results.first);
  }

  /// 전화번호로 직원 조회
  Future<Employee?> queryByPhoneNumber(String phoneNumber) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      where: 'ePhoneNumber = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Employee.fromMap(results.first);
  }

  /// 이메일 또는 전화번호로 직원 조회 (로그인용)
  Future<Employee?> queryByIdentifier(String identifier) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      where: 'eEmail = ? OR ePhoneNumber = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Employee.fromMap(results.first);
  }

  /// 역할로 직원 조회
  Future<List<Employee>> queryByRole(String role) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableEmployee,
      where: 'eRole = ?',
      whereArgs: [role],
      orderBy: 'id ASC',
    );
    return results.map((e) => Employee.fromMap(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 직원 추가
  Future<int> insertData(Employee employee) async {
    final db = await _getDatabase();
    final map = employee.toMap(includeId: false);
    return await db.insert(config.tableEmployee, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 직원 정보 수정
  Future<int> updateData(Employee employee) async {
    if (employee.id == null) {
      throw Exception('Employee id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = employee.toMap(includeId: false);
    return await db.update(
      config.tableEmployee,
      map,
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 직원 삭제
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableEmployee,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

