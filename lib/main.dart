import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/theme_provider.dart';
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/database/dummy_data/dummy_data_setting.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/login_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/admin_login_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/search_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/order_list_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/return_list_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/user_profile_edit_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_mobile_block_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_order_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_return_order_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_profile_edit_view.dart';
import 'package:shoes_store_basic_app/view/cheng/test_navigation_page.dart';
import 'package:shoes_store_basic_app/view/customer/address_payment_view.dart';
import 'package:shoes_store_basic_app/view/customer/cart.dart';
import 'package:shoes_store_basic_app/view/customer/purchase_view.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  // GetStorage 초기화 (get_storage는 GetX와 독립적으로 사용 가능)
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage에서 DB 초기화 완료 여부 확인
  final storage = GetStorage();
  final isDBInitialized = storage.read<bool>(config.storageKeyDBInitialized) ?? false;

  // DB가 초기화되지 않았을 때만 초기화 및 더미 데이터 삽입
  if (!isDBInitialized) {
    // 데이터베이스 초기화 (DatabaseManager 사용)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '${config.dbName}${config.dbFileExt}');
    
    // DatabaseManager 인스턴스 가져오기
    final dbManager = DatabaseManager();
    
    // 기존 DB 연결 닫기 및 리셋 (DB 삭제 전에 필수)
    await dbManager.closeAndReset();
    
    // 개발 중이므로 기존 DB 삭제 (운영 환경에서는 제거)
    await deleteDatabase(path);
    
    // DatabaseManager로 DB 초기화
    await dbManager.initializeDB();

    // 더미 데이터 삽입 (새 핸들러 방식 사용)
    final dummyDataSetting = DummyDataSetting();
    await dummyDataSetting.insertAllDummyData();
    
    // 초기화 완료 플래그 저장
    await storage.write(config.storageKeyDBInitialized, true);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // 시스템에서 설정한 색상으로 초기화

  final Color _seedColor = Colors.deepPurple;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      onToggleTheme: _toggleTheme,
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: _seedColor,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: _seedColor,
        ),
        initialRoute: config.routeLogin,
        routes: {
          config.routeLogin: (context) => const LoginView(),
          config.routeCart: (context) => const Cart(),
          config.routeSearchView: (context) => const SearchView(),
          config.routePurchaseView: (context) => const PurchaseView(),
          config.routeAddressPayment: (context) => const AddressPaymentView(),
          config.routeAdminLogin: (context) => const AdminLoginView(),
          config.routeAdminMobileBlock: (context) => const AdminMobileBlockView(),
          config.routeAdminOrderView: (context) => const AdminOrderView(),
          config.routeAdminReturnOrderView: (context) => const AdminReturnOrderView(),
          config.routeOrderListView: (context) => const OrderListView(),
          config.routeReturnListView: (context) => const ReturnListView(),
          config.routeUserProfileEdit: (context) => const UserProfileEditView(),
          config.routeAdminProfileEdit: (context) => const AdminProfileEditView(),
          config.routeTestNavigationPage: (context) => const TestNavigationPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
