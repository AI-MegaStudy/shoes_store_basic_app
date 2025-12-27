import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/core/database_manager.dart';
import 'package:shoes_store_basic_app/database/dummy_data/dummy_data_setting.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_mobile_block_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_order_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_return_order_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/admin_login_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/login_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/signup_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/order_list_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/return_list_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/search_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/user_profile_edit_view.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: '네비게이션 테스트',
        centerTitle: true,
        titleTextStyle: config.boldLabelStyle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: config.largePadding,
            child: CustomColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: config.defaultSpacing,
              children: [
                CustomText(
                  '페이지 이동 테스트',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                config.defaultVerticalSpacing,
                CustomButton(
                  btnText: 'DB 초기화 및 더미 데이터 재삽입',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _reinitializeDatabase(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                config.defaultVerticalSpacing,
                CustomButton(
                  btnText: '로그인 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToLogin(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '회원가입 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToSignUp(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '회원가입 화면 (더미 데이터)',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToSignUpWithTestData(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '사용자 프로필 수정 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToUserProfileEdit(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '관리자 로그인 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToAdminLogin(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '관리자 모바일 차단 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToAdminBlock(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '주문 관리 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToOrderView(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '반품 관리 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToReturnOrderView(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '고객용 주문 목록 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToCustomerOrderList(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '고객용 반품 목록 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToCustomerReturnList(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                CustomButton(
                  btnText: '검색 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToSearchView(context),
                  minimumSize: Size(double.infinity, config.defaultButtonHeight),
                ),
                const SizedBox(height: 32),
                CustomText(
                  'DB 테스트',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                    CustomButton(
                      btnText: '모든 사용자 출력',
                      buttonType: ButtonType.elevated,
                      onCallBack: () => _printRecentCustomers(context),
                      minimumSize: Size(double.infinity, config.defaultButtonHeight),
                    ),
                    CustomButton(
                      btnText: '로그인 히스토리 전체 출력',
                      buttonType: ButtonType.elevated,
                      onCallBack: () => _printAllLoginHistory(context),
                      minimumSize: Size(double.infinity, config.defaultButtonHeight),
                    ),
                // const SizedBox(height: 32),
                // CustomText(
                //   'DB 스키마 검증 테스트',
                //   fontSize: 24,
                //   fontWeight: FontWeight.bold,
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 16),
                // CustomButton(
                //   btnText: 'Customer 테이블 검증',
                //   buttonType: ButtonType.elevated,
                //   onCallBack: () => _testCustomerTable(context),
                //   minimumSize: const Size(double.infinity, 56),
                // ),
                // CustomButton(
                //   btnText: 'Employee 테이블 검증',
                //   buttonType: ButtonType.elevated,
                //   onCallBack: () => _testEmployeeTable(context),
                //   minimumSize: const Size(double.infinity, 56),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로그인 화면으로 이동
  void _navigateToLogin(BuildContext context) {
    CustomNavigationUtil.to(context, const LoginView());
  }

  /// 회원가입 화면으로 이동
  void _navigateToSignUp(BuildContext context) {
    CustomNavigationUtil.to(context, const SignUpView());
  }

  /// 회원가입 화면으로 이동 (더미 데이터 포함)
  /// 인서트 로직 검증을 위한 테스트용 더미 데이터를 전달합니다.
  /// 
  /// 더미 데이터는 고정된 값으로 설정되어 있어 테스트 시 쉽게 찾을 수 있습니다.
  /// 중복 오류가 발생하면 DB에서 해당 데이터를 삭제한 후 다시 테스트하세요.
  void _navigateToSignUpWithTestData(BuildContext context) {
    // 테스트용 고정 더미 데이터 생성
    // Customer 모델의 필드에 맞춰 더미 데이터를 생성합니다.
    // 고정된 값으로 설정하여 테스트 시 쉽게 찾을 수 있도록 합니다.
    final testData = {
      'email': 'dummytest@example.com', // 테스트용 이메일 (고정값)
      'password': 'qwer1234', // 테스트용 비밀번호 (고정값: qwer1234)
      'name': '더미 테스트 사용자', // 테스트용 이름 (고정값)
      'phone': '010-9999-8888', // 테스트용 전화번호 (고정값)
      'autoAgree': 'true', // 약관 자동 동의 (테스트 편의)
    };

    // 더미 데이터와 함께 회원가입 화면으로 이동
    CustomNavigationUtil.to(context, SignUpView(testData: testData));
  }

  /// 사용자 프로필 수정 화면으로 이동
  void _navigateToUserProfileEdit(BuildContext context) {
    CustomNavigationUtil.to(context, const UserProfileEditView());
  }

  /// 관리자 로그인 화면으로 이동
  void _navigateToAdminLogin(BuildContext context) {
    CustomNavigationUtil.to(context, const AdminLoginView());
  }

  /// 관리자 모바일 차단 화면으로 이동
  void _navigateToAdminBlock(BuildContext context) {
    CustomNavigationUtil.to(context, const AdminMobileBlockView());
  }

  /// 주문 관리 화면으로 이동
  void _navigateToOrderView(BuildContext context) {
    CustomNavigationUtil.to(context, const AdminOrderView());
  }

  /// 반품 관리 화면으로 이동
  void _navigateToReturnOrderView(BuildContext context) {
    CustomNavigationUtil.to(context, const AdminReturnOrderView());
  }

  /// 고객용 주문 목록 화면으로 이동
  void _navigateToCustomerOrderList(BuildContext context) {
    CustomNavigationUtil.to(context, const OrderListView());
  }

  /// 고객용 반품 목록 화면으로 이동
  void _navigateToCustomerReturnList(BuildContext context) {
    CustomNavigationUtil.to(context, const ReturnListView());
  }

  /// 검색 화면으로 이동
  void _navigateToSearchView(BuildContext context) {
    CustomNavigationUtil.to(context, const SearchView());
  }

  /// DB 초기화 및 더미 데이터 재삽입
  /// 
  /// 기존 DB를 삭제하고 새로 초기화한 후 더미 데이터를 삽입합니다.
  /// GetStorage의 초기화 플래그도 리셋합니다.
  Future<void> _reinitializeDatabase(BuildContext context) async {
    // 확인 다이얼로그 표시
    CustomDialog.show(
      context,
      title: 'DB 초기화',
      message: '데이터베이스를 초기화하고 더미 데이터를 재삽입하시겠습니까?\n\n⚠️ 기존의 모든 데이터가 삭제됩니다.',
      type: DialogType.dual,
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () {
        CustomNavigationUtil.back(context);
        _performDatabaseReinitialization(context);
      },
      onCancel: () {
        CustomNavigationUtil.back(context);
      },
    );
  }

  /// 실제 DB 초기화 작업 수행
  Future<void> _performDatabaseReinitialization(BuildContext context) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 데이터베이스 초기화
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, '${config.dbName}${config.dbFileExt}');
      
      // DatabaseManager 인스턴스 가져오기
      final dbManager = DatabaseManager();
      
      // 기존 DB 연결 닫기 및 리셋 (DB 삭제 전에 필수)
      await dbManager.closeAndReset();
      
      // 기존 DB 삭제
      await deleteDatabase(path);
      
      // DatabaseManager로 DB 초기화
      await dbManager.initializeDB();

      // 더미 데이터 삽입
      final dummyDataSetting = DummyDataSetting();
      await dummyDataSetting.insertAllDummyData();
      
      // 초기화 완료 플래그 저장
      final storage = GetStorage();
      await storage.write(config.storageKeyDBInitialized, true);

      // 로딩 닫기
      if (context.mounted) {
        CustomNavigationUtil.back(context);
      }

      // 성공 메시지 표시
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: '데이터베이스가 초기화되고 더미 데이터가 삽입되었습니다.',
        );
      }

      AppLogger.d('DB 초기화 및 더미 데이터 재삽입 완료', tag: 'TestNavigation');
    } catch (e, stackTrace) {
      // 로딩 닫기
      if (context.mounted) {
        CustomNavigationUtil.back(context);
      }

      AppLogger.e('DB 초기화 실패', tag: 'TestNavigation', error: e, stackTrace: stackTrace);
      
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: '데이터베이스 초기화 중 오류가 발생했습니다: $e',
        );
      }
    }
  }

  /// 등록된 모든 사용자를 터미널에 출력
  Future<void> _printRecentCustomers(BuildContext context) async {
    try {
      final customerHandler = CustomerHandler();

      print('\n${'=' * 60}');
      print('DB 조회 시작...');
      print('=' * 60);

      /// 모든 Customer 조회
      final allCustomers = await customerHandler.queryAll();

      print('조회된 사용자 수: ${allCustomers.length}');

      if (allCustomers.isEmpty) {
        print('=' * 60);
        print('등록된 사용자가 없습니다.');
        print('=' * 60);
        print('\n💡 팁: 회원가입 화면(더미 데이터) 버튼을 눌러 테스트 데이터를 추가하세요.');
        print('=' * 60 + '\n');
        CustomSnackBar.show(
          context,
          message: '등록된 사용자가 없습니다.\n회원가입 화면(더미 데이터) 버튼을 눌러 테스트 데이터를 추가하세요.',
        );
        return;
      }

      /// ID 기준으로 정렬 (내림차순: 최신순)
      allCustomers.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      print('\n${'=' * 60}');
      print('등록된 모든 사용자 (총 ${allCustomers.length}명)');
      print('=' * 60);
      
      for (int i = 0; i < allCustomers.length; i++) {
        final customer = allCustomers[i];
        print('\n[${i + 1}번째 사용자]');
        print('  ID: ${customer.id}');
        print('  이메일: ${customer.cEmail}');
        print('  전화번호: ${customer.cPhoneNumber}');
        print('  이름: ${customer.cName}');
        print('  비밀번호: ${customer.cPassword}');
        print('-' * 60);
      }
      
      print('\n총 ${allCustomers.length}명의 사용자가 등록되어 있습니다.');
      print('=' * 60 + '\n');

      CustomSnackBar.showSuccess(
        context,
        message: '터미널에 등록된 모든 사용자 ${allCustomers.length}명을 출력했습니다.',
      );
    } catch (e, stackTrace) {
      AppLogger.e('사용자 정보 조회 에러', tag: 'TestNavigation', error: e, stackTrace: stackTrace);
      print('error: $e');
      print('stackTrace: $stackTrace');
      print('---------------');
      print('\n${'=' * 60}');
      print('에러 발생: $e');
      print('스택 트레이스:');
      print(stackTrace);
      print('=' * 60 + '\n');
      CustomSnackBar.showError(
        context,
        message: '사용자 정보를 가져오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 등록된 모든 로그인 히스토리를 터미널에 출력
  Future<void> _printAllLoginHistory(BuildContext context) async {
    try {
      final loginHistoryHandler = LoginHistoryHandler();

      print('\n${'=' * 60}');
      print('로그인 히스토리 DB 조회 시작...');
      print('=' * 60);

      /// 모든 LoginHistory 조회
      final allLoginHistory = await loginHistoryHandler.queryAll();

      print('조회된 로그인 히스토리 수: ${allLoginHistory.length}');

      if (allLoginHistory.isEmpty) {
        print('=' * 60);
        print('등록된 로그인 히스토리가 없습니다.');
        print('=' * 60);
        print('\n💡 팁: 회원가입을 하면 로그인 히스토리가 자동으로 생성됩니다.');
        print('=' * 60 + '\n');
        CustomSnackBar.show(
          context,
          message: '등록된 로그인 히스토리가 없습니다.\n회원가입을 하면 로그인 히스토리가 자동으로 생성됩니다.',
        );
        return;
      }

      /// ID 기준으로 정렬 (내림차순: 최신순)
      allLoginHistory.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      print('\n${'=' * 60}');
      print('등록된 모든 로그인 히스토리 (총 ${allLoginHistory.length}개)');
      print('=' * 60);
      
      for (int i = 0; i < allLoginHistory.length; i++) {
        final history = allLoginHistory[i];
        // ISO 8601 형식을 yyyy-MM-dd HH:mm 형식으로 변환
        String formattedLoginTime;
        try {
          final loginDateTime = DateTime.parse(history.loginTime);
          formattedLoginTime = CustomCommonUtil.formatDate(loginDateTime, 'yyyy-MM-dd HH:mm');
        } catch (e) {
          formattedLoginTime = history.loginTime; // 파싱 실패 시 원본 표시
        }
        
        print('\n[${i + 1}번째 로그인 히스토리]');
        print('  ID: ${history.id}');
        print('  Customer ID (cid): ${history.cid}');
        print('  로그인 시간 (loginTime): $formattedLoginTime');
        print('  상태 (lStatus): ${history.lStatus}');
        print('  주소 (lAddress): "${history.lAddress}"');
        print('  결제 방법 (lPaymentMethod): "${history.lPaymentMethod}"');
        print('-' * 60);
      }
      
      print('\n총 ${allLoginHistory.length}개의 로그인 히스토리가 등록되어 있습니다.');
      print('=' * 60 + '\n');

      CustomSnackBar.showSuccess(
        context,
        message: '터미널에 등록된 모든 로그인 히스토리 ${allLoginHistory.length}개를 출력했습니다.',
      );
    } catch (e, stackTrace) {
      AppLogger.e('로그인 히스토리 조회 에러', tag: 'TestNavigation', error: e, stackTrace: stackTrace);
      print('error: $e');
      print('stackTrace: $stackTrace');
      print('---------------');
      print('\n${'=' * 60}');
      print('에러 발생: $e');
      print('스택 트레이스:');
      print(stackTrace);
      print('=' * 60 + '\n');
      CustomSnackBar.showError(
        context,
        message: '로그인 히스토리 정보를 가져오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  //----Function End----
  
  // Customer 테이블 검증 (주석 처리됨)
  // Future<void> _testCustomerTable(BuildContext context) async {
  //   try {
  //     final rdb = RDB();
  //     final db = await RDB.instance(dbName, dVersion);
  //     await rdb.validateTableColumns(
  //       db: db,
  //       tableName: config.kTableCustomer,
  //       expectedColumns: Customer.keys,
  //     );
  //     if (context.mounted) {
  //       CustomSnackBar.showSuccess(context, message: 'Customer 테이블 스키마 검증 성공!');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       final errorMessage = e.toString().contains('Actual:   []')
  //           ? 'Customer 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
  //           : 'Customer 테이블 검증 실패: $e';
  //       CustomSnackBar.showError(context, message: errorMessage);
  //     }
  //   }
  // }

  // Employee 테이블 검증
  // Future<void> _testEmployeeTable(BuildContext context) async {
  //   try {
  //     final rdb = RDB();
  //     final db = await RDB.instance(dbName, dVersion);
  //     await rdb.validateTableColumns(
  //       db: db,
  //       tableName: config.tTableEmployee,
  //       expectedColumns: Employee.keys,
  //     );
  //     if (context.mounted) {
  //       CustomSnackBar.showSuccess(context, message: 'Employee 테이블 스키마 검증 성공!');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       final errorMessage = e.toString().contains('Actual:   []')
  //           ? 'Employee 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
  //           : 'Employee 테이블 검증 실패: $e';
  //       CustomSnackBar.showError(context, message: errorMessage);
  //     }
  //   }
  // }

  //----Function End----
}
