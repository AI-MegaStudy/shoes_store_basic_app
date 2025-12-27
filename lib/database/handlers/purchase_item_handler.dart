import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase_item.dart';
import 'package:sqflite/sqflite.dart';

/// PurchaseItem 테이블 핸들러
class PurchaseItemHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 기본 조회 메서드
  // ============================================

  /// 전체 주문 항목 조회
  Future<List<PurchaseItem>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tablePurchaseItem,
      orderBy: 'id ASC',
    );
    return results.map((e) => PurchaseItem.fromMap(e)).toList();
  }

  /// ID로 주문 항목 조회
  Future<PurchaseItem?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tablePurchaseItem,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return PurchaseItem.fromMap(results.first);
  }

  /// 주문별 항목 조회
  Future<List<PurchaseItem>> queryByPurchaseId(int pcid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tablePurchaseItem,
      where: 'pcid = ?',
      whereArgs: [pcid],
      orderBy: 'id ASC',
    );
    return results.map((e) => PurchaseItem.fromMap(e)).toList();
  }

  /// 제품별 주문 항목 조회
  Future<List<PurchaseItem>> queryByProductId(int pid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tablePurchaseItem,
      where: 'pid = ?',
      whereArgs: [pid],
      orderBy: 'id ASC',
    );
    return results.map((e) => PurchaseItem.fromMap(e)).toList();
  }

  /// 상태별 주문 항목 조회
  Future<List<PurchaseItem>> queryByStatus(String status) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tablePurchaseItem,
      where: 'pcStatus = ?',
      whereArgs: [status],
      orderBy: 'id ASC',
    );
    return results.map((e) => PurchaseItem.fromMap(e)).toList();
  }

  // ============================================
  // 조인 쿼리 메서드
  // ============================================

  /// 주문 항목 + 제품 정보 조인 조회
  ///
  /// [id] PurchaseItem ID
  /// 반환: PurchaseItem과 Product 정보를 포함한 Map
  Future<Map<String, dynamic>?> queryWithProduct(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        PurchaseItem.*,
        Product.size,
        Product.basePrice,
        Product.pQuantity,
        Product.pbid,
        Product.mfid
      FROM PurchaseItem
      JOIN Product ON PurchaseItem.pid = Product.id
      WHERE PurchaseItem.id = ?
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  /// 주문별 항목 + 제품 정보 조인 조회
  ///
  /// [pcid] Purchase ID
  /// 반환: PurchaseItem과 Product 정보를 포함한 Map 리스트
  Future<List<Map<String, dynamic>>> queryByPurchaseIdWithProduct(
    int pcid,
  ) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        PurchaseItem.*,
        Product.size,
        Product.basePrice,
        Product.pQuantity,
        Product.pbid,
        Product.mfid
      FROM PurchaseItem
      JOIN Product ON PurchaseItem.pid = Product.id
      WHERE PurchaseItem.pcid = ?
      ORDER BY PurchaseItem.id ASC
    ''',
      [pcid],
    );

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 주문 항목 + 제품 + ProductBase + Manufacturer + 이미지 조인 조회 (전체 상세 정보)
  ///
  /// [id] PurchaseItem ID
  /// 반환: 모든 관련 정보를 포함한 Map
  Future<Map<String, dynamic>?> queryFullDetail(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        PurchaseItem.*,
        Product.size,
        Product.basePrice,
        Product.pQuantity,
        ProductBase.pName,
        ProductBase.pDescription,
        ProductBase.pColor,
        ProductBase.pGender,
        ProductBase.pCategory,
        ProductBase.pModelNumber,
        Manufacturer.mName,
        ProductImage.imagePath
      FROM PurchaseItem
      JOIN Product ON PurchaseItem.pid = Product.id
      JOIN ProductBase ON Product.pbid = ProductBase.id
      JOIN Manufacturer ON Product.mfid = Manufacturer.id
      LEFT JOIN ProductImage ON ProductBase.id = ProductImage.pbid
      WHERE PurchaseItem.id = ?
      LIMIT 1
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  /// 주문별 항목 전체 상세 정보 조회
  ///
  /// [pcid] Purchase ID
  /// 반환: 모든 관련 정보를 포함한 Map 리스트
  Future<List<Map<String, dynamic>>> queryByPurchaseIdFullDetail(
    int pcid,
  ) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT 
        PurchaseItem.*,
        Product.size,
        Product.basePrice,
        Product.pQuantity,
        ProductBase.pName,
        ProductBase.pDescription,
        ProductBase.pColor,
        ProductBase.pGender,
        ProductBase.pCategory,
        ProductBase.pModelNumber,
        Manufacturer.mName,
        (SELECT imagePath FROM ProductImage 
        WHERE ProductImage.pbid = ProductBase.id 
        LIMIT 1) as imagePath
      FROM PurchaseItem
      JOIN Product ON PurchaseItem.pid = Product.id
      JOIN ProductBase ON Product.pbid = ProductBase.id
      JOIN Manufacturer ON Product.mfid = Manufacturer.id
      WHERE PurchaseItem.pcid = ?
      ORDER BY PurchaseItem.id ASC
    ''',
      [pcid],
    );

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 주문 항목 추가
  Future<int> insertData(PurchaseItem item) async {
    final db = await _getDatabase();
    final map = item.toMap(includeId: false);
    return await db.insert(config.tablePurchaseItem, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 주문 항목 정보 수정
  Future<int> updateData(PurchaseItem item) async {
    if (item.id == null) {
      throw Exception('PurchaseItem id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = item.toMap(includeId: false);
    return await db.update(
      config.tablePurchaseItem,
      map,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 주문 항목 상태만 업데이트
  Future<int> updateStatus(int id, String status) async {
    final db = await _getDatabase();
    return await db.update(
      config.tablePurchaseItem,
      {'pcStatus': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 주문 항목 삭제
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tablePurchaseItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
