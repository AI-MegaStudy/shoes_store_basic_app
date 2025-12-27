import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:sqflite/sqflite.dart';

/// Purchase 테이블 핸들러
class PurchaseHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 기본 조회 메서드
  // ============================================

  /// 전체 주문 조회
  Future<List<Purchase>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      'Purchase',
      orderBy: 'timeStamp DESC',
    );
    return results.map((e) => Purchase.fromMap(e)).toList();
  }

  /// ID로 주문 조회
  Future<Purchase?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      'Purchase',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Purchase.fromMap(results.first);
  }

  /// 고객별 주문 조회
  Future<List<Purchase>> queryByCustomerId(int cid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      'Purchase',
      where: 'cid = ?',
      whereArgs: [cid],
      orderBy: 'timeStamp DESC',
    );
    return results.map((e) => Purchase.fromMap(e)).toList();
  }

  /// 주문 코드로 조회
  Future<Purchase?> queryByOrderCode(String orderCode) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      'Purchase',
      where: 'orderCode = ?',
      whereArgs: [orderCode],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Purchase.fromMap(results.first);
  }

  // ============================================
  // 조인 쿼리 메서드
  // ============================================

  /// 주문 + 고객 정보 조인 조회
  ///
  /// [id] Purchase ID
  /// 반환: Purchase와 Customer 정보를 포함한 Map
  Future<Map<String, dynamic>?> queryWithCustomer(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        Purchase.*,
        Customer.cName,
        Customer.cEmail,
        Customer.cPhoneNumber
      FROM Purchase
      JOIN Customer ON Purchase.cid = Customer.id
      WHERE Purchase.id = ?
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  /// 고객별 주문 목록 + 고객 정보 조인 조회
  ///
  /// [cid] Customer ID
  /// 반환: Purchase와 Customer 정보를 포함한 Map 리스트
  Future<List<Map<String, dynamic>>> queryListWithCustomer(int cid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        Purchase.*,
        Customer.cName,
        Customer.cEmail,
        Customer.cPhoneNumber
      FROM Purchase
      JOIN Customer ON Purchase.cid = Customer.id
      WHERE Purchase.cid = ?
      ORDER BY Purchase.timeStamp DESC
    ''',
      [cid],
    );

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 주문 추가
  Future<int> insertData(Purchase purchase) async {
    final db = await _getDatabase();
    final map = purchase.toMap(includeId: false);
    return await db.insert('Purchase', map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 주문 정보 수정
  Future<int> updateData(Purchase purchase) async {
    if (purchase.id == null) {
      throw Exception('Purchase id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = purchase.toMap(includeId: false);
    return await db.update(
      'Purchase',
      map,
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 주문 삭제
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete('Purchase', where: 'id = ?', whereArgs: [id]);
  }
}
