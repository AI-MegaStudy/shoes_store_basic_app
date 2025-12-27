import 'package:shoes_store_basic_app/database/dummy_data/dummy_data_sets.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/employee_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/manufacturer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_base_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_image_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/purchase_item_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/model/employee.dart';
import 'package:shoes_store_basic_app/model/login_history.dart';
import 'package:shoes_store_basic_app/model/product/manufacturer.dart';
import 'package:shoes_store_basic_app/model/product/product_base.dart';
import 'package:shoes_store_basic_app/model/product/product_image.dart';
import 'package:shoes_store_basic_app/model/product/product.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase.dart';
import 'package:shoes_store_basic_app/model/purchase/purchase_item.dart';

/// 더미 데이터 세팅 클래스
///
/// 개발 및 테스트를 위한 더미 데이터를 데이터베이스에 삽입합니다.
/// 새로운 핸들러 방식을 사용하며, 목적별 데이터 세트를 지원합니다.
class DummyDataSetting {
  /// 데이터 세트를 받아서 모든 더미 데이터 삽입
  ///
  /// [dataSet] 삽입할 데이터 세트 (기본값: DevelopmentDataSet)
  ///
  /// 순서:
  /// 1. Manufacturer (제조사)
  /// 2. ProductBase (제품 기본 정보)
  /// 3. ProductImage (제품 이미지)
  /// 4. Product (제품)
  /// 5. Customer (고객)
  /// 6. Employee (직원)
  /// 7. Purchase (주문)
  /// 8. PurchaseItem (주문 항목)
  /// 9. LoginHistory (로그인 이력)
  ///
  /// 사용 예시:
  /// ```dart
  /// final setting = DummyDataSetting();
  /// // 개발용 데이터 삽입
  /// await setting.insertDataSet(DevelopmentDataSet());
  /// // 테스트용 데이터 삽입
  /// await setting.insertDataSet(TestDataSet());
  /// ```
  Future<void> insertDataSet(DummyDataSet dataSet) async {
    print('📦 더미 데이터 삽입 시작... (데이터 세트: ${dataSet.runtimeType})');

    // 1. 제조사 삽입
    final manufacturerIds = await insertManufacturers(dataSet.manufacturers);
    print('✅ 제조사 삽입 완료: ${manufacturerIds.length}개');

    // 2. 제품 기본 정보 삽입
    final productBaseIds = await insertProductBases(dataSet.productBases);
    print('✅ 제품 기본 정보 삽입 완료: ${productBaseIds.length}개');

    // 3. 제품 이미지 삽입
    await insertProductImages(productBaseIds, dataSet.productImages);
    print('✅ 제품 이미지 삽입 완료');

    // 4. 제품 삽입
    await insertProducts(
      productBaseIds,
      manufacturerIds,
      dataSet.productConfig,
    );
    print('✅ 제품 삽입 완료');

    // 5. 고객 삽입
    final customerIds = await insertCustomers(dataSet.customers);
    print('✅ 고객 삽입 완료: ${customerIds.length}개');

    // 6. 직원 삽입
    final employeeIds = await insertEmployees(dataSet.employees);
    print('✅ 직원 삽입 완료: ${employeeIds.length}개');

    // 7. 주문 삽입
    final purchaseIds = await insertPurchases(dataSet.purchases, customerIds);
    print('✅ 주문 삽입 완료: ${purchaseIds.length}개');

    // 8. 주문 항목 삽입
    await insertPurchaseItems(dataSet.purchaseItems, purchaseIds);
    print('✅ 주문 항목 삽입 완료');

    // 9. 로그인 이력 삽입
    await insertLoginHistories(dataSet.loginHistories, customerIds);
    print('✅ 로그인 이력 삽입 완료');

    print('🎉 모든 더미 데이터 삽입 완료!');
  }

  /// 모든 더미 데이터 삽입 (기본 데이터 세트 사용)
  ///
  /// DevelopmentDataSet을 사용하여 데이터를 삽입합니다.
  /// 기존 호환성을 위해 유지됩니다.
  Future<void> insertAllDummyData() async {
    await insertDataSet(DevelopmentDataSet());
  }

  // ============================================
  // 개별 삽입 메서드 (공개 - 재사용 가능)
  // ============================================

  /// 제조사 데이터 삽입
  ///
  /// [data] 제조사 데이터 리스트
  /// 반환: 삽입된 제조사 ID 리스트
  ///
  /// 사용 예시:
  /// ```dart
  /// final setting = DummyDataSetting();
  /// final customData = [{'mName': 'Nike'}, {'mName': 'Adidas'}];
  /// final ids = await setting.insertManufacturers(customData);
  /// ```
  Future<List<int>> insertManufacturers(List<Map<String, dynamic>> data) async {
    final handler = ManufacturerHandler();
    final List<int> ids = [];

    for (final item in data) {
      final manufacturer = Manufacturer(mName: item['mName'] as String);
      final id = await handler.insertData(manufacturer);
      ids.add(id);
    }

    return ids;
  }

  /// 제품 기본 정보 데이터 삽입
  ///
  /// [data] 제품 기본 정보 데이터 리스트
  /// 반환: 삽입된 ProductBase ID 리스트
  Future<List<int>> insertProductBases(List<Map<String, dynamic>> data) async {
    final handler = ProductBaseHandler();
    final List<int> ids = [];

    for (final item in data) {
      final productBase = ProductBase(
        pName: item['pName'] as String,
        pDescription: item['pDescription'] as String,
        pColor: item['pColor'] as String,
        pGender: item['pGender'] as String,
        pStatus: item['pStatus'] as String,
        pCategory: item['pCategory'] as String,
        pModelNumber: item['pModelNumber'] as String,
      );
      final id = await handler.insertData(productBase);
      ids.add(id);
    }

    return ids;
  }

  /// 제품 이미지 데이터 삽입
  ///
  /// [productBaseIds] ProductBase ID 리스트
  /// [imageMap] ProductBase 인덱스별 이미지 경로 매핑
  Future<void> insertProductImages(
    List<int> productBaseIds,
    Map<int, List<String>> imageMap,
  ) async {
    final handler = ProductImageHandler();

    for (int i = 0; i < productBaseIds.length; i++) {
      final pbid = productBaseIds[i];
      final imagePaths = imageMap[i];

      if (imagePaths != null && imagePaths.isNotEmpty) {
        final List<ProductImage> images = [];
        for (final imagePath in imagePaths) {
          images.add(ProductImage(pbid: pbid, imagePath: imagePath));
        }
        await handler.insertBatch(images);
      }
    }
  }

  /// 제품 데이터 삽입
  ///
  /// [productBaseIds] ProductBase ID 리스트
  /// [manufacturerIds] Manufacturer ID 리스트
  /// [productConfig] ProductBase 인덱스별 제품 설정 정보
  Future<void> insertProducts(
    List<int> productBaseIds,
    List<int> manufacturerIds,
    Map<int, Map<String, dynamic>> productConfig,
  ) async {
    final handler = ProductHandler();

    for (int i = 0; i < productBaseIds.length; i++) {
      final pbid = productBaseIds[i];
      final config = productConfig[i];

      if (config != null) {
        final mfidIndex = config['mfid'] as int;
        final mfid = manufacturerIds[mfidIndex];
        final sizes = config['sizes'] as List<int>;
        final basePrices = config['basePrices'] as List<int>;
        final quantity = config['quantity'] as int;

        for (int j = 0; j < sizes.length; j++) {
          final product = Product(
            pbid: pbid,
            mfid: mfid,
            size: sizes[j],
            basePrice: basePrices[j],
            pQuantity: quantity,
          );
          await handler.insertData(product);
        }
      }
    }
  }

  /// 고객 데이터 삽입
  ///
  /// [data] 고객 데이터 리스트
  /// 반환: 삽입된 고객 ID 리스트
  Future<List<int>> insertCustomers(List<Map<String, dynamic>> data) async {
    final handler = CustomerHandler();
    final List<int> ids = [];

    for (final item in data) {
      final customer = Customer(
        cEmail: item['cEmail'] as String,
        cPhoneNumber: item['cPhoneNumber'] as String,
        cName: item['cName'] as String,
        cPassword: item['cPassword'] as String,
      );
      final id = await handler.insertData(customer);
      ids.add(id);
    }

    return ids;
  }

  /// 직원 데이터 삽입
  ///
  /// [data] 직원 데이터 리스트
  /// 반환: 삽입된 직원 ID 리스트
  Future<List<int>> insertEmployees(List<Map<String, dynamic>> data) async {
    final handler = EmployeeHandler();
    final List<int> ids = [];

    for (final item in data) {
      final employee = Employee(
        eEmail: item['eEmail'] as String,
        ePhoneNumber: item['ePhoneNumber'] as String,
        eName: item['eName'] as String,
        ePassword: item['ePassword'] as String,
        eRole: item['eRole'] as String,
      );
      final id = await handler.insertData(employee);
      ids.add(id);
    }

    return ids;
  }

  /// 주문 데이터 삽입
  ///
  /// [data] 주문 데이터 리스트 (cid는 Customer 인덱스)
  /// [customerIds] Customer ID 리스트
  /// 반환: 삽입된 주문 ID 리스트
  Future<List<int>> insertPurchases(
    List<Map<String, dynamic>> data,
    List<int> customerIds,
  ) async {
    final handler = PurchaseHandler();
    final List<int> ids = [];

    for (final item in data) {
      final cidIndex = item['cid'] as int;
      final cid = customerIds[cidIndex];

      final purchase = Purchase(
        cid: cid,
        pickupDate: item['pickupDate'] as String,
        orderCode: item['orderCode'] as String,
        timeStamp: item['timeStamp'] as String,
      );
      final id = await handler.insertData(purchase);
      ids.add(id);
    }

    return ids;
  }

  /// 주문 항목 데이터 삽입
  ///
  /// [data] 주문 항목 데이터 리스트 (pid, pcid는 인덱스)
  /// [purchaseIds] Purchase ID 리스트
  ///
  /// 주의: pid는 Product 인덱스이므로 실제 Product ID로 변환해야 합니다.
  /// 현재는 간단히 인덱스 + 1을 사용하지만, 실제로는 Product 삽입 순서를 추적해야 합니다.
  Future<void> insertPurchaseItems(
    List<Map<String, dynamic>> data,
    List<int> purchaseIds,
  ) async {
    final handler = PurchaseItemHandler();

    // Product ID 매핑을 위해 ProductHandler로 조회
    final productHandler = ProductHandler();
    final allProducts = await productHandler.queryAll();
    final productIdMap = <int, int>{}; // 인덱스 → 실제 ID

    for (int i = 0; i < allProducts.length; i++) {
      productIdMap[i] = allProducts[i].id!;
    }

    for (final item in data) {
      final pidIndex = item['pid'] as int;
      final pcidIndex = item['pcid'] as int;

      // 실제 ID로 변환
      final pid = productIdMap[pidIndex];
      final pcid = purchaseIds[pcidIndex];

      // pid가 null이면 해당 인덱스의 Product가 없는 것이므로 스킵
      if (pid != null) {
        final purchaseItem = PurchaseItem(
          pid: pid,
          pcid: pcid,
          pcQuantity: item['pcQuantity'] as int,
          pcStatus: item['pcStatus'] as String,
        );
        await handler.insertData(purchaseItem);
      }
    }
  }

  /// 로그인 이력 데이터 삽입
  ///
  /// [data] 로그인 이력 데이터 리스트 (cid는 Customer 인덱스)
  /// [customerIds] Customer ID 리스트
  Future<void> insertLoginHistories(
    List<Map<String, dynamic>> data,
    List<int> customerIds,
  ) async {
    final handler = LoginHistoryHandler();

    for (final item in data) {
      final cidIndex = item['cid'] as int;
      final cid = customerIds[cidIndex];

      final loginHistory = LoginHistory(
        cid: cid,
        loginTime: item['loginTime'] as String,
        lStatus: item['lStatus'] as String,
        lAddress: item['lAddress'] as String,
        lPaymentMethod: item['lPaymentMethod'] as String,
      );
      await handler.insertData(loginHistory);
    }
  }
}
