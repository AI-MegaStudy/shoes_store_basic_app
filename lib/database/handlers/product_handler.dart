import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/model/product/product.dart';
import 'package:sqflite/sqflite.dart';

/// Product 테이블 핸들러
class ProductHandler {
  final DatabaseManager _dbManager = DatabaseManager();

  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  /// 전체 제품 조회
  Future<List<Product>> queryAll() async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProduct,
      orderBy: 'id ASC',
    );
    return results.map((e) => Product.fromMap(e)).toList();
  }

  /// ID로 제품 조회
  Future<Product?> queryById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProduct,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  /// ProductBase별 제품 조회
  Future<List<Product>> queryByProductBaseId(int pbid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProduct,
      where: 'pbid = ?',
      whereArgs: [pbid],
      orderBy: 'size ASC',
    );
    return results.map((e) => Product.fromMap(e)).toList();
  }

  /// 제조사별 제품 조회
  Future<List<Product>> queryByManufacturerId(int mfid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProduct,
      where: 'mfid = ?',
      whereArgs: [mfid],
      orderBy: 'id ASC',
    );
    return results.map((e) => Product.fromMap(e)).toList();
  }

  /// 사이즈별 제품 조회
  Future<List<Product>> queryBySize(int size) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.query(
      config.tableProduct,
      where: 'size = ?',
      whereArgs: [size],
      orderBy: 'id ASC',
    );
    return results.map((e) => Product.fromMap(e)).toList();
  }

  /// 제품 + ProductBase 정보 조인 조회
  Future<Map<String, dynamic>?> queryWithBase(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT 
        Product.*,
        ProductBase.pName,
        ProductBase.pDescription,
        ProductBase.pColor,
        ProductBase.pGender,
        ProductBase.pStatus,
        ProductBase.pCategory,
        ProductBase.pModelNumber
      FROM Product
      JOIN ProductBase ON Product.pbid = ProductBase.id
      WHERE Product.id = ?
    ''', [id]);

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  /// 제품 + ProductBase + Manufacturer 정보 조인 조회
  Future<Map<String, dynamic>?> queryWithBaseAndManufacturer(int id) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT 
        Product.*,
        ProductBase.pName,
        ProductBase.pDescription,
        ProductBase.pColor,
        ProductBase.pGender,
        ProductBase.pStatus,
        ProductBase.pCategory,
        ProductBase.pModelNumber,
        Manufacturer.mName
      FROM Product
      JOIN ProductBase ON Product.pbid = ProductBase.id
      JOIN Manufacturer ON Product.mfid = Manufacturer.id
      WHERE Product.id = ?
    ''', [id]);

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  /// ProductBase별 제품 목록 + ProductBase 정보 조인 조회
  Future<List<Map<String, dynamic>>> queryListWithBase(int pbid) async {
    final db = await _getDatabase();
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT 
        Product.*,
        ProductBase.pName,
        ProductBase.pDescription,
        ProductBase.pColor,
        ProductBase.pGender,
        ProductBase.pStatus,
        ProductBase.pCategory,
        ProductBase.pModelNumber
      FROM Product
      JOIN ProductBase ON Product.pbid = ProductBase.id
      WHERE Product.pbid = ?
      ORDER BY Product.size ASC
    ''', [pbid]);

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 제품 추가
  Future<int> insertData(Product product) async {
    final db = await _getDatabase();
    final map = product.toMap(includeId: false);
    return await db.insert(config.tableProduct, map);
  }

  /// 제품 정보 수정
  Future<int> updateData(Product product) async {
    if (product.id == null) {
      throw Exception('Product id is null. Cannot update.');
    }

    final db = await _getDatabase();
    final map = product.toMap(includeId: false);
    return await db.update(
      config.tableProduct,
      map,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// 제품 재고만 업데이트
  Future<int> updateQuantity(int id, int quantity) async {
    final db = await _getDatabase();
    return await db.update(
      config.tableProduct,
      {'pQuantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 제품 삭제
  Future<int> deleteData(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      config.tableProduct,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

