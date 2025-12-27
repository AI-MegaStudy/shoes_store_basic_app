import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:sqflite/sqflite.dart';

/// Purchase 관련 복합 조인 쿼리 서비스
class PurchaseService {
  final DatabaseManager _dbManager = DatabaseManager();

  Future<Database> _getDatabase() async {
    return await _dbManager.getDatabase();
  }

  /// 주문 상세 정보 조회 (전체 조인)
  Future<Map<String, dynamic>?> queryOrderDetail(int purchaseId) async {
    final db = await _getDatabase();

    final purchaseResults = await db.rawQuery('''
      SELECT 
        Purchase.*,
        Customer.cName,
        Customer.cEmail,
        Customer.cPhoneNumber
      FROM Purchase
      JOIN Customer ON Purchase.cid = Customer.id
      WHERE Purchase.id = ?
    ''', [purchaseId]);

    if (purchaseResults.isEmpty) return null;

    final itemResults = await db.rawQuery('''
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
    ''', [purchaseId]);

    return {
      'purchase': Map<String, dynamic>.from(purchaseResults.first),
      'customer': {
        'cName': purchaseResults.first['cName'],
        'cEmail': purchaseResults.first['cEmail'],
        'cPhoneNumber': purchaseResults.first['cPhoneNumber'],
      },
      'items': itemResults.map((e) => {
        'purchaseItem': {
          'id': e['id'],
          'pid': e['pid'],
          'pcid': e['pcid'],
          'pcQuantity': e['pcQuantity'],
          'pcStatus': e['pcStatus'],
        },
        'product': {
          'id': e['pid'],
          'size': e['size'],
          'basePrice': e['basePrice'],
          'pQuantity': e['pQuantity'],
        },
        'productBase': {
          'pName': e['pName'],
          'pDescription': e['pDescription'],
          'pColor': e['pColor'],
          'pGender': e['pGender'],
          'pCategory': e['pCategory'],
          'pModelNumber': e['pModelNumber'],
        },
        'manufacturer': {
          'mName': e['mName'],
        },
        'imagePath': e['imagePath'],
      }).toList(),
    };
  }

  /// 고객별 주문 목록 조회 (항목 수, 총 금액 포함)
  Future<List<Map<String, dynamic>>> queryOrderListByCustomer(int cid) async {
    final db = await _getDatabase();

    final results = await db.rawQuery('''
      SELECT 
        Purchase.*,
        COUNT(PurchaseItem.id) as itemCount,
        SUM(Product.basePrice * PurchaseItem.pcQuantity) as totalPrice
      FROM Purchase
      LEFT JOIN PurchaseItem ON Purchase.id = PurchaseItem.pcid
      LEFT JOIN Product ON PurchaseItem.pid = Product.id
      WHERE Purchase.cid = ?
      GROUP BY Purchase.id
      ORDER BY Purchase.timeStamp DESC
    ''', [cid]);

    return results.map((e) => {
      'purchase': {
        'id': e['id'],
        'cid': e['cid'],
        'pickupDate': e['pickupDate'],
        'orderCode': e['orderCode'],
        'timeStamp': e['timeStamp'],
      },
      'itemCount': e['itemCount'] ?? 0,
      'totalPrice': e['totalPrice'] ?? 0,
    }).toList();
  }

  /// 주문 + 모든 주문 항목 조인 조회
  Future<Map<String, dynamic>?> queryOrderListWithItems(int purchaseId) async {
    final db = await _getDatabase();

    final purchaseResults = await db.query(
      'Purchase',
      where: 'id = ?',
      whereArgs: [purchaseId],
      limit: 1,
    );

    if (purchaseResults.isEmpty) return null;

    final itemResults = await db.rawQuery('''
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
        Manufacturer.mName
      FROM PurchaseItem
      JOIN Product ON PurchaseItem.pid = Product.id
      JOIN ProductBase ON Product.pbid = ProductBase.id
      JOIN Manufacturer ON Product.mfid = Manufacturer.id
      WHERE PurchaseItem.pcid = ?
      ORDER BY PurchaseItem.id ASC
    ''', [purchaseId]);

    return {
      'purchase': Map<String, dynamic>.from(purchaseResults.first),
      'items': itemResults.map((e) => Map<String, dynamic>.from(e)).toList(),
    };
  }

  /// 반품 가능한 주문 목록 조회 (상태 2이고 반품 신청이 안 된 주문만)
  Future<List<Map<String, dynamic>>> queryReturnableOrders(int cid) async {
    final db = await _getDatabase();

    final completeStatus = config.pickupStatus[2]!;
    final returnRequestStatus = config.pickupStatus[3]!;
    final returnDoneStatus = config.pickupStatus[5]!;

    final results = await db.rawQuery('''
      SELECT DISTINCT
        Purchase.*
      FROM Purchase
      JOIN PurchaseItem ON Purchase.id = PurchaseItem.pcid
      WHERE Purchase.cid = ?
        AND PurchaseItem.pcStatus = ?
        AND PurchaseItem.pcStatus != ?
        AND PurchaseItem.pcStatus != ?
      ORDER BY Purchase.timeStamp DESC
    ''', [cid, completeStatus, returnRequestStatus, returnDoneStatus]);

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

