import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/login_history.dart';
import 'package:sqflite/sqflite.dart';

/// LoginHistory 테이블 핸들러
class LoginHistoryHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 조회 메서드
  // ============================================

  /// 전체 로그인 이력 조회
  /// 
  /// 반환: 모든 LoginHistory 리스트 (최신순)
  Future<List<LoginHistory>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableLoginHistory,
      orderBy: 'loginTime DESC',
    );
    return results.map((e) => LoginHistory.fromMap(e)).toList();
  }

  /// ID로 로그인 이력 조회
  /// 
  /// [id] LoginHistory ID
  /// 반환: LoginHistory 객체 (없으면 null)
  Future<LoginHistory?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableLoginHistory,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return LoginHistory.fromMap(results.first);
  }

  /// 고객별 로그인 이력 조회
  /// 
  /// [cid] Customer ID
  /// 반환: 해당 고객의 모든 로그인 이력 리스트 (최신순)
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = LoginHistoryHandler();
  /// final history = await handler.queryByCustomerId(customerId);
  /// // history에는 해당 고객의 모든 로그인 기록이 최신순으로 포함됨
  /// ```
  Future<List<LoginHistory>> queryByCustomerId(int cid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableLoginHistory,
      where: 'cid = ?',
      whereArgs: [cid],
      orderBy: 'loginTime DESC',
    );
    return results.map((e) => LoginHistory.fromMap(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 로그인 이력 추가
  /// 
  /// [history] 추가할 LoginHistory 객체
  /// 반환: 삽입된 레코드의 ID
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = LoginHistoryHandler();
  /// final history = LoginHistory(
  ///   cid: customerId,
  ///   loginTime: DateTime.now().toIso8601String(),
  ///   lStatus: '활동 회원',
  ///   lAddress: '서울시 강남구',
  ///   lPaymentMethod: '카드',
  /// );
  /// await handler.insertData(history);
  /// ```
  Future<int> insertData(LoginHistory history) async {
    final db = await _getDatabase();
    final map = history.toMap(includeId: false);
    return await db.insert(config.tableLoginHistory, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 로그인 이력 수정
  /// 
  /// [history] 수정할 LoginHistory 객체 (id 필수)
  /// 반환: 수정된 행 수
  Future<int> updateData(LoginHistory history) async {
    if (history.id == null) {
      throw Exception('LoginHistory id is null. Cannot update.');
    }
    final db = await _getDatabase();
    final map = history.toMap(includeId: false);
    return await db.update(
      config.tableLoginHistory,
      map,
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  /// 고객 ID로 로그인 이력 상태 업데이트
  /// 
  /// [cid] Customer ID
  /// [status] 새로운 상태 값
  /// 반환: 수정된 행 수
  Future<int> updateStatusByCustomerId(int cid, String status) async {
    final db = await _getDatabase();
    return await db.update(
      config.tableLoginHistory,
      {'lStatus': status},
      where: 'cid = ?',
      whereArgs: [cid],
    );
  }

  /// 고객 ID로 로그인 시간 업데이트
  /// 
  /// [cid] Customer ID
  /// [loginTime] 새로운 로그인 시간
  /// 반환: 수정된 행 수
  Future<int> updateLoginTimeByCustomerId(int cid, String loginTime) async {
    final db = await _getDatabase();
    return await db.update(
      config.tableLoginHistory,
      {'loginTime': loginTime},
      where: 'cid = ?',
      whereArgs: [cid],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 로그인 이력 삭제
  /// 
  /// [id] 삭제할 LoginHistory ID
  /// 반환: 삭제된 행 수
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableLoginHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

