import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/product/product_base.dart';
import 'package:sqflite/sqflite.dart';

/// ProductBase 테이블 핸들러
class ProductBaseHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 기본 조회 메서드
  // ============================================

  /// 전체 제품 기본 정보 조회
  /// 
  /// 반환: 모든 ProductBase 리스트
  Future<List<ProductBase>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductBase,
      orderBy: 'id ASC',
    );
    return results.map((e) => ProductBase.fromMap(e)).toList();
  }

  /// ID로 제품 기본 정보 조회
  /// 
  /// [id] ProductBase ID
  /// 반환: ProductBase 객체 (없으면 null)
  Future<ProductBase?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductBase,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProductBase.fromMap(results.first);
  }

  /// 이름으로 제품 기본 정보 조회
  /// 
  /// [name] 제품명 (예: 'U740WN2', '나이키 샥스 TL')
  /// 반환: ProductBase 객체 (없으면 null)
  Future<ProductBase?> queryByName(String name) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductBase,
      where: 'pName = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProductBase.fromMap(results.first);
  }

  /// 색상별 제품 기본 정보 조회
  /// 
  /// [color] 색상 (예: 'Black', 'Gray', 'White')
  /// 반환: 해당 색상의 모든 ProductBase 리스트
  Future<List<ProductBase>> queryByColor(String color) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductBase,
      where: 'pColor = ?',
      whereArgs: [color],
      orderBy: 'id ASC',
    );
    return results.map((e) => ProductBase.fromMap(e)).toList();
  }

  /// 카테고리별 제품 기본 정보 조회
  /// 
  /// [category] 카테고리 (예: 'Running', 'Sneakers')
  /// 반환: 해당 카테고리의 모든 ProductBase 리스트
  Future<List<ProductBase>> queryByCategory(String category) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductBase,
      where: 'pCategory = ?',
      whereArgs: [category],
      orderBy: 'id ASC',
    );
    return results.map((e) => ProductBase.fromMap(e)).toList();
  }

  // ============================================
  // 조인 쿼리 메서드
  // ============================================

  /// ProductBase + 이미지 목록 조인 조회
  /// 
  /// [id] ProductBase ID
  /// 반환: ProductBase 정보와 모든 관련 이미지 경로를 포함한 Map
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = ProductBaseHandler();
  /// final productWithImages = await handler.queryWithImages(productBaseId);
  /// final images = productWithImages['images'] as List<String>;
  /// // images에는 해당 제품의 모든 이미지 경로가 포함됨
  /// ```
  Future<Map<String, dynamic>?> queryWithImages(int id) async {
    final db = await _getDatabase();
    
    // ProductBase 정보 조회
    final baseResults = await db.query(
      config.tableProductBase,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (baseResults.isEmpty) return null;
    
    // 이미지 목록 조회
    final imageResults = await db.query(
      config.tableProductImage,
      where: 'pbid = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );
    
    final result = Map<String, dynamic>.from(baseResults.first);
    result['images'] = imageResults.map((e) => e['imagePath'] as String).toList();
    
    return result;
  }

  /// ProductBase 목록 + 첫 번째 이미지 조인 조회
  /// 
  /// 반환: 모든 ProductBase 정보와 각 제품의 첫 번째 이미지 경로를 포함한 Map 리스트
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = ProductBaseHandler();
  /// final products = await handler.queryListWithFirstImage();
  /// // 각 제품마다 첫 번째 이미지 경로가 'firstImage' 필드에 포함됨
  /// for (var product in products) {
  ///   print('${product['pName']}: ${product['firstImage']}');
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> queryListWithFirstImage() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT 
        ProductBase.*,
        (SELECT imagePath FROM ProductImage 
         WHERE ProductImage.pbid = ProductBase.id 
         LIMIT 1) as firstImage
      FROM ProductBase
      ORDER BY ProductBase.id ASC
    ''');

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 제품 기본 정보 추가
  /// 
  /// [productBase] 추가할 ProductBase 객체
  /// 반환: 삽입된 레코드의 ID
  Future<int> insertData(ProductBase productBase) async {
    final db = await _getDatabase();
    final map = productBase.toMap(includeId: false);
    return await db.insert(config.tableProductBase, map);
  }

  // ============================================
  // 수정 메서드
  // ============================================

  /// 제품 기본 정보 수정
  /// 
  /// [productBase] 수정할 ProductBase 객체 (id 필수)
  /// 반환: 업데이트된 행 수
  Future<int> updateData(ProductBase productBase) async {
    if (productBase.id == null) {
      throw Exception('ProductBase id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = productBase.toMap(includeId: false);
    return await db.update(
      config.tableProductBase,
      map,
      where: 'id = ?',
      whereArgs: [productBase.id],
    );
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 제품 기본 정보 삭제
  /// 
  /// [id] 삭제할 ProductBase ID
  /// 반환: 삭제된 행 수
  /// 
  /// 주의: Product나 ProductImage에서 참조 중인 ProductBase는 삭제하지 않는 것이 좋습니다.
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableProductBase,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

