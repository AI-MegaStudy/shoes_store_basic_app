import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite 데이터베이스 초기화 및 관리 클래스
class DatabaseManager {
  static Database? _db;

  /// DB 초기화 및 테이블 생성
  Future<Database> initializeDB() async {
    if (_db != null) return _db!;

    final String dbName = '${config.dbName}${config.dbFileExt}';
    final int dbVersion = config.schemaVersion;

    final path = join(await getDatabasesPath(), dbName);
    print("Database Path: $path");

    _db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await _createIndexes(db);
      },
    );

    return _db!;
  }

  /// 모든 테이블 생성
  Future<void> _createTables(Database db) async {
    // Product 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pbid INTEGER,
        mfid INTEGER,
        size INTEGER,
        basePrice INTEGER,
        pQuantity INTEGER
      )
    ''');

    // ProductBase 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ProductBase (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pName TEXT,
        pDescription TEXT,
        pColor TEXT,
        pGender TEXT,
        pStatus TEXT,
        pFeatureType TEXT,
        pCategory TEXT,
        pModelNumber TEXT
      )
    ''');

    // Manufacturer 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Manufacturer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mName TEXT
      )
    ''');

    // ProductImage 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ProductImage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pbid INTEGER,
        imagePath TEXT
      )
    ''');

    // Customer 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cEmail TEXT,
        cPhoneNumber TEXT,
        cName TEXT,
        cPassword TEXT
      )
    ''');

    // Employee 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Employee (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eEmail TEXT,
        ePhoneNumber TEXT,
        eName TEXT,
        ePassword TEXT,
        eRole TEXT
      )
    ''');

    // PurchaseItem 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PurchaseItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pid INTEGER,
        pcid INTEGER,
        pcQuantity INTEGER,
        pcStatus TEXT
      )
    ''');

    // Purchase 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Purchase (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cid INTEGER,
        pickupDate TEXT,
        orderCode TEXT,
        timeStamp TEXT
      )
    ''');

    // LoginHistory 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS LoginHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cid INTEGER,
        loginTime TEXT,
        lStatus TEXT,
        lAddress TEXT,
        lPaymentMethod TEXT
      )
    ''');
  }

  /// 인덱스 생성
  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_purchase_cid 
      ON Purchase(cid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_purchase_order_code 
      ON Purchase(orderCode)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_purchase_item_pcid 
      ON PurchaseItem(pcid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_purchase_item_pid 
      ON PurchaseItem(pid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_purchase_item_status 
      ON PurchaseItem(pcStatus)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_product_pbid 
      ON Product(pbid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_product_mfid 
      ON Product(mfid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_product_image_pbid 
      ON ProductImage(pbid)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_customer_email 
      ON Customer(cEmail)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_customer_phone 
      ON Customer(cPhoneNumber)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_employee_email 
      ON Employee(eEmail)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_employee_phone 
      ON Employee(ePhoneNumber)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_employee_role 
      ON Employee(eRole)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_login_history_cid 
      ON LoginHistory(cid)
    ''');

    print("✅ 모든 인덱스 생성 완료");
  }

  /// DB 인스턴스 가져오기
  Future<Database> getDatabase() async {
    if (_db == null) {
      await initializeDB();
    }
    return _db!;
  }

  /// DB 연결 닫기 및 리셋
  Future<void> closeAndReset() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// 테이블 전체 삭제 (개발/테스트용)
  Future<void> clearAllTables() async {
    final db = await getDatabase();
    await db.delete('LoginHistory');
    await db.delete('PurchaseItem');
    await db.delete('Purchase');
    await db.delete('Employee');
    await db.delete('Customer');
    await db.delete('ProductImage');
    await db.delete('Product');
    await db.delete('ProductBase');
    await db.delete('Manufacturer');
    print("✅ 모든 테이블 데이터 삭제 완료");
  }
}

