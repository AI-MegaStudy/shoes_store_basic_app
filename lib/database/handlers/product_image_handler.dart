import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/product/product_image.dart';
import 'package:sqflite/sqflite.dart';

/// ProductImage 테이블 핸들러
class ProductImageHandler {
  /// DatabaseManager 인스턴스
  final DatabaseManager _dbManager = DatabaseManager();

  /// DB 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  // ============================================
  // 조회 메서드
  // ============================================

  /// 전체 이미지 조회
  /// 
  /// 반환: 모든 ProductImage 리스트
  Future<List<ProductImage>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductImage,
      orderBy: 'id ASC',
    );
    return results.map((e) => ProductImage.fromMap(e)).toList();
  }

  /// ID로 이미지 조회
  /// 
  /// [id] ProductImage ID
  /// 반환: ProductImage 객체 (없으면 null)
  Future<ProductImage?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductImage,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProductImage.fromMap(results.first);
  }

  /// ProductBase별 이미지 조회
  /// 
  /// [pbid] ProductBase ID
  /// 반환: 해당 ProductBase의 모든 이미지 리스트
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = ProductImageHandler();
  /// final images = await handler.queryByProductBaseId(productBaseId);
  /// // images에는 해당 제품의 모든 이미지가 포함됨
  /// for (var image in images) {
  ///   print(image.imagePath); // 이미지 경로 출력
  /// }
  /// ```
  Future<List<ProductImage>> queryByProductBaseId(int pbid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProductImage,
      where: 'pbid = ?',
      whereArgs: [pbid],
      orderBy: 'id ASC',
    );
    return results.map((e) => ProductImage.fromMap(e)).toList();
  }

  // ============================================
  // 삽입 메서드
  // ============================================

  /// 이미지 추가
  /// 
  /// [image] 추가할 ProductImage 객체
  /// 반환: 삽입된 레코드의 ID
  Future<int> insertData(ProductImage image) async {
    final db = await _getDatabase();
    final map = image.toMap(includeId: false);
    return await db.insert(config.tableProductImage, map);
  }

  /// 이미지 일괄 추가
  /// 
  /// [images] 추가할 ProductImage 리스트
  /// 반환: 삽입된 레코드의 ID 리스트
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = ProductImageHandler();
  /// final images = [
  ///   ProductImage(pbid: 1, imagePath: 'images/product1_01.png'),
  ///   ProductImage(pbid: 1, imagePath: 'images/product1_02.png'),
  ///   ProductImage(pbid: 1, imagePath: 'images/product1_03.png'),
  /// ];
  /// final ids = await handler.insertBatch(images);
  /// ```
  Future<List<int>> insertBatch(List<ProductImage> images) async {
    final db = await _getDatabase();
    final List<int> ids = [];
    
    await db.transaction((txn) async {
      for (final image in images) {
        final map = image.toMap(includeId: false);
        final id = await txn.insert(config.tableProductImage, map);
        ids.add(id);
      }
    });
    
    return ids;
  }

  // ============================================
  // 삭제 메서드
  // ============================================

  /// 이미지 삭제
  /// 
  /// [id] 삭제할 ProductImage ID
  /// 반환: 삭제된 행 수
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableProductImage,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ProductBase별 이미지 전체 삭제
  /// 
  /// [pbid] ProductBase ID
  /// 반환: 삭제된 행 수
  /// 
  /// 사용 예시:
  /// ```dart
  /// final handler = ProductImageHandler();
  /// await handler.deleteByProductBaseId(productBaseId);
  /// // 해당 제품의 모든 이미지가 삭제됨
  /// ```
  Future<int> deleteByProductBaseId(int pbid) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableProductImage,
      where: 'pbid = ?',
      whereArgs: [pbid],
    );
  }
}

