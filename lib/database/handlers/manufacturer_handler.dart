import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/product/manufacturer.dart';
import 'package:sqflite/sqflite.dart';

/// Manufacturer 테이블 핸들러
class ManufacturerHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 조회 메서드
  // ============================================

  /// 전체 제조사 조회
  /// 
  /// 반환: 모든 Manufacturer 리스트
  Future<List<Manufacturer>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableManufacturer,
      orderBy: 'id ASC',
    );
    return results.map((e) => Manufacturer.fromMap(e)).toList();
  }

  /// ID로 제조사 조회
  /// 
  /// [id] Manufacturer ID
  /// 반환: Manufacturer 객체 (없으면 null)
  Future<Manufacturer?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableManufacturer,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Manufacturer.fromMap(results.first);
  }

  /// 이름으로 제조사 조회
  /// 
  /// [name] 제조사명 (예: '나이키', '뉴발란스')
  /// 반환: Manufacturer 객체 (없으면 null)
  Future<Manufacturer?> queryByName(String name) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableManufacturer,
      where: 'mName = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Manufacturer.fromMap(results.first);
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 제조사 추가
  /// 
  /// [manufacturer] 추가할 Manufacturer 객체
  /// 반환: 삽입된 레코드의 ID
  Future<int> insertData(Manufacturer manufacturer) async {
    final db = await _getDatabase();
    final map = manufacturer.toMap(includeId: false);
    return await db.insert(config.tableManufacturer, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 제조사 정보 수정
  /// 
  /// [manufacturer] 수정할 Manufacturer 객체 (id 필수)
  /// 반환: 업데이트된 행 수
  Future<int> updateData(Manufacturer manufacturer) async {
    if (manufacturer.id == null) {
      throw Exception('Manufacturer id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = manufacturer.toMap(includeId: false);
    return await db.update(
      config.tableManufacturer,
      map,
      where: 'id = ?',
      whereArgs: [manufacturer.id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 제조사 삭제
  /// 
  /// [id] 삭제할 Manufacturer ID
  /// 반환: 삭제된 행 수
  /// 
  /// 주의: Product에서 참조 중인 Manufacturer는 삭제하지 않는 것이 좋습니다.
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableManufacturer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

