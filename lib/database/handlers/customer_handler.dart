import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:sqflite/sqflite.dart';

/// Customer 테이블 핸들러
class CustomerHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 조회 메서드
  // ============================================

  /// 전체 고객 조회
  /// 
  /// 반환: 모든 Customer 리스트
  Future<List<Customer>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableCustomer,
      orderBy: 'id ASC',
    );
    return results.map((e) => Customer.fromMap(e)).toList();
  }

  /// ID로 고객 조회
  /// 
  /// [id] Customer ID
  /// 반환: Customer 객체 (없으면 null)
  Future<Customer?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableCustomer,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  /// 이메일로 고객 조회
  /// 
  /// [email] 고객 이메일
  /// 반환: Customer 객체 (없으면 null)
  Future<Customer?> queryByEmail(String email) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableCustomer,
      where: 'cEmail = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  /// 전화번호로 고객 조회
  /// 
  /// [phoneNumber] 고객 전화번호
  /// 반환: Customer 객체 (없으면 null)
  Future<Customer?> queryByPhoneNumber(String phoneNumber) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableCustomer,
      where: 'cPhoneNumber = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  /// 이메일 또는 전화번호로 고객 조회 (로그인용)
  /// 
  /// [identifier] 이메일 또는 전화번호
  /// 반환: Customer 객체 (없으면 null)
  Future<Customer?> queryByIdentifier(String identifier) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableCustomer,
      where: 'cEmail = ? OR cPhoneNumber = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 고객 추가
  /// 
  /// [customer] 추가할 Customer 객체
  /// 반환: 삽입된 레코드의 ID
  Future<int> insertData(Customer customer) async {
    final db = await _getDatabase();
    final map = customer.toMap(includeId: false);
    return await db.insert(config.tableCustomer, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 고객 정보 수정
  /// 
  /// [customer] 수정할 Customer 객체 (id 필수)
  /// 반환: 업데이트된 행 수
  Future<int> updateData(Customer customer) async {
    if (customer.id == null) {
      throw Exception('Customer id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = customer.toMap(includeId: false);
    return await db.update(
      config.tableCustomer,
      map,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 고객 삭제
  /// 
  /// [id] 삭제할 Customer ID
  /// 반환: 삭제된 행 수
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableCustomer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

