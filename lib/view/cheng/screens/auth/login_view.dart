import 'dart:async';
import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/model/login_history.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';
import 'package:shoes_store_basic_app/utils/admin_tablet_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/customer/search_view.dart' as cheng_search;
import 'package:shoes_store_basic_app/view/cheng/screens/auth/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'LoginForm');

  /// 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();
  
  /// 고객 핸들러
  final CustomerHandler _customerHandler = CustomerHandler();
  
  /// 로그인 이력 핸들러
  final LoginHistoryHandler _loginHistoryHandler = LoginHistoryHandler();

  /// 관리자 진입을 위한 로고 탭 횟수
  int _adminTapCount = 0;
  
  /// 관리자 진입을 위한 타이머 (2초)
  Timer? _adminTapTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _adminTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CustomAppBar(
              title: '로그인',
              centerTitle: true,
              titleTextStyle: config.boldLabelStyle,
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
            ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: CustomColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              CustomPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: config.largeSpacing,
                ),
                child: GestureDetector(
                  onTap: _handleLogoTap,
                  child: Image.asset(
                    'images/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return CustomText(
                        'SHOE KING',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
              CustomPadding(
                padding: config.formHorizontalPadding,
                child: Form(
                  key: _formKey,
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: config.defaultSpacing,
                    children: [
                      CustomTextField(
                        controller: _idController,
                        labelText: '이메일 또는 전화번호',
                        hintText: '이메일 또는 전화번호를 입력하세요',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person),
                        required: true,
                        requiredMessage: '이메일 또는 전화번호를 입력해주세요',
                      ),

                      CustomTextField(
                        controller: _passwordController,
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock),
                        required: true,
                        requiredMessage: '비밀번호를 입력해주세요',
                      ),
                      config.largeVerticalSpacing,

                      CustomButton(
                        btnText: '로그인',
                        buttonType: ButtonType.elevated,
                        onCallBack: _handleLogin,
                        minimumSize: Size(double.infinity, config.defaultButtonHeight),
                      ),

                      config.defaultVerticalSpacing,

                      CustomButton(
                        btnText: '회원가입',
                        buttonType: ButtonType.outlined,
                        onCallBack: _navigateToSignUp,
                        minimumSize: Size(double.infinity, config.defaultButtonHeight),
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        btnText: '테스트 페이지로 이동',
                        buttonType: ButtonType.outlined,
                        onCallBack: _navigateToTestPage,
                        minimumSize: Size(double.infinity, config.defaultButtonHeight),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
          );
        },
      ),
    );
  }

  /// 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 로그인 성공 후 처리
  void _handleLoginSuccess(Customer customer) {
    UserStorage.saveUser(customer);
    CustomSnackBar.showSuccess(
      context,
      message: '${customer.cName}님 환영합니다!',
    );
    CustomNavigationUtil.offAll(context, const cheng_search.SearchView());
  }

  /// 로그인 차단 처리
  void _blockLogin(String message) {
    CustomDialog.show(
      context,
      title: '로그인 불가',
      message: message,
      type: DialogType.single,
      confirmText: '확인',
    );
  }

  /// 상태 키 변환 함수
  /// DB에 숫자(0, 1, 2) 또는 문자열("0", "1", "2", "활동 회원", "휴면 회원", "탈퇴 회원")로 저장될 수 있음
  int? _parseStatusKey(String currentStatus) {
    for (var entry in config.loginStatus.entries) {
      final key = entry.key;
      final value = entry.value;
      final keyAsString = key.toString();
      
      if (currentStatus == keyAsString || 
          currentStatus == value || 
          currentStatus == key.toString() ||
          (int.tryParse(currentStatus) != null && int.parse(currentStatus) == key)) {
        return key;
      }
    }
    return null;
  }

  /// 6개월 미접속 체크 및 휴면 회원 처리
  /// 반환값: true면 휴면 처리되어 로그인 차단, false면 정상 진행
  Future<bool> _checkDormantAccount(LoginHistory loginHistory, Customer customer) async {
    try {
      // ISO 8601 형식으로 통일되었으므로 직접 파싱 가능
      final lastLoginDateTime = DateTime.parse(loginHistory.loginTime);
      final now = DateTime.now();
      final daysDifference = now.difference(lastLoginDateTime).inDays;
      
      AppLogger.d('마지막 로그인: $lastLoginDateTime, 현재: $now, 차이: $daysDifference일', tag: 'Login');
      
      if (daysDifference >= config.dormantAccountDays) {
        AppLogger.w('6개월 이상 미접속 - 휴면 회원 처리', tag: 'Login', error: 'Customer ID: ${customer.id}');
        
        await _loginHistoryHandler.updateStatusByCustomerId(
          customer.id!,
          config.loginStatus[1] as String, // '휴면 회원'
        );
        
        _blockLogin('장기간 미접속으로 ${config.loginStatus[1]} 처리 되었습니다.'); // '휴면 회원'
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.e('마지막 로그인 시간 파싱 실패', tag: 'Login', error: e, stackTrace: stackTrace);
      return false; // 에러 발생 시 로그인 진행
    }
  }

  /// 로그인 시간 업데이트
  Future<void> _updateLoginTime(Customer customer) async {
    try {
      await _loginHistoryHandler.updateLoginTimeByCustomerId(
        customer.id!,
        DateTime.now().toIso8601String(),
      );
      
      AppLogger.d('로그인 히스토리 업데이트 성공 - Customer ID: ${customer.id}', tag: 'Login');
    } catch (e, stackTrace) {
      AppLogger.e('로그인 히스토리 업데이트 실패', tag: 'Login', error: e, stackTrace: stackTrace);
    }
  }

  /// 상태별 로그인 처리
  Future<bool> _handleStatusBasedLogin(int? statusKey, String currentStatus, Customer customer, LoginHistory loginHistory) async {
    if (statusKey == 0) {
      final isDormant = await _checkDormantAccount(loginHistory, customer);
      if (isDormant) {
        return false;
      }
      
      await _updateLoginTime(customer);
      _handleLoginSuccess(customer);
      return true;
    } else if (statusKey == 1) {
      AppLogger.w('휴면 회원 로그인 시도 - Customer ID: ${customer.id}', tag: 'Login');
      _blockLogin('${config.loginStatus[1]}입니다.'); // '휴면 회원'
      return false;
    } else if (statusKey == 2) {
      AppLogger.w('탈퇴 회원 로그인 시도 - Customer ID: ${customer.id}', tag: 'Login');
      _blockLogin('${config.loginStatus[2]}입니다.'); // '탈퇴 회원'
      return false;
    } else if (statusKey == null) {
      if (currentStatus == config.loginStatus[2] || currentStatus == '2' || currentStatus.contains('탈퇴')) { // '탈퇴 회원'
        AppLogger.w('탈퇴 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}', tag: 'Login');
        _blockLogin('${config.loginStatus[2]}입니다.'); // '탈퇴 회원'
        return false;
      } else if (currentStatus == config.loginStatus[1] || currentStatus == '1' || currentStatus.contains('휴면')) { // '휴면 회원'
        AppLogger.w('휴면 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}', tag: 'Login');
        _blockLogin('${config.loginStatus[1]}입니다.'); // '휴면 회원'
        return false;
      } else if (currentStatus == config.loginStatus[0] || currentStatus == '0' || currentStatus.contains('활동')) { // '활동 회원'
        await _updateLoginTime(customer);
        _handleLoginSuccess(customer);
        return true;
      } else {
        AppLogger.e('알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: "$currentStatus"', tag: 'Login');
        CustomSnackBar.showError(
          context,
          message: '로그인 상태를 확인할 수 없습니다.',
        );
        return false;
      }
    } else {
      AppLogger.e('알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: "$currentStatus", StatusKey: $statusKey', tag: 'Login');
      CustomSnackBar.showError(
        context,
        message: '로그인 상태를 확인할 수 없습니다.',
      );
      return false;
    }
  }

  /// 로고 탭 처리
  /// 2초 안에 5번 탭하면 관리자 진입 모드 활성화
  void _handleLogoTap() {
    _adminTapTimer?.cancel();

    setState(() {
      _adminTapCount++;
    });

    if (_adminTapCount >= 5) {
      _adminTapCount = 0;
      _adminTapTimer?.cancel();

      final isTabletDevice = isTablet(context);
      
      if (isTabletDevice) {
        CustomNavigationUtil.toNamed(context, config.routeAdminLogin);
      } else {
        CustomNavigationUtil.toNamed(context, config.routeAdminMobileBlock);
      }
      return;
    }

    _adminTapTimer = Timer(const Duration(seconds: 2), () {
      _adminTapTimer?.cancel();
      setState(() {
        _adminTapCount = 0;
      });
    });
  }

  /// 로그인 버튼 클릭 처리
  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final input = _idController.text.trim();
    final password = _passwordController.text.trim();
    final isEmail = CustomCommonUtil.isEmail(input);

    try {
      Customer? customer;
      
      if (isEmail) {
        customer = await _customerHandler.queryByEmail(input);
      } else {
        customer = await _customerHandler.queryByPhoneNumber(input);
      }

      if (customer == null || customer.cPassword != password) {
        AppLogger.d('로그인 실패 - 입력값과 일치하는 고객 정보 없음', tag: 'Login');
        CustomSnackBar.showError(
          context,
          message: '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }
      
      if (customer.id == null) {
        AppLogger.e('Customer ID가 null입니다 - 로그인 처리 불가', tag: 'Login');
        CustomSnackBar.showError(
          context,
          message: '로그인 처리 중 오류가 발생했습니다.',
        );
        return;
      }

      AppLogger.d('로그인 성공 - Customer ID: ${customer.id}, 이름: ${customer.cName}', tag: 'Login');
      
      try {
        final loginHistories = await _loginHistoryHandler.queryByCustomerId(customer.id!);
        
        if (loginHistories.isNotEmpty) {
          final loginHistory = loginHistories.first;
          final currentStatus = loginHistory.lStatus;
          final statusKey = _parseStatusKey(currentStatus);
          
          await _handleStatusBasedLogin(statusKey, currentStatus, customer, loginHistory);
        } else {
          AppLogger.d('로그인 히스토리가 없음 - 신규 생성 시도', tag: 'Login');
          await _createLoginHistory(customer);
          _handleLoginSuccess(customer);
        }
      } catch (e, stackTrace) {
        AppLogger.e('로그인 히스토리 조회 중 예상치 못한 에러 발생', tag: 'Login', error: e, stackTrace: stackTrace);
        await _createLoginHistory(customer);
        _handleLoginSuccess(customer);
      }
    } catch (error, stackTrace) {
      AppLogger.e('로그인 처리 중 예외 발생', tag: 'Login', error: error, stackTrace: stackTrace);
      CustomSnackBar.showError(
        context,
        message: '로그인 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그인 히스토리 생성
  Future<void> _createLoginHistory(Customer customer) async {
    final newLoginHistory = LoginHistory(
      cid: customer.id,
      loginTime: DateTime.now().toIso8601String(),
      lStatus: config.loginStatus[0] as String, // '활동 회원'
      lAddress: '',
      lPaymentMethod: '',
    );
    
    try {
      await _loginHistoryHandler.insertData(newLoginHistory);
      AppLogger.d('로그인 히스토리 생성 성공 - Customer ID: ${customer.id}', tag: 'Login');
    } catch (e, stackTrace) {
      AppLogger.e('로그인 히스토리 생성 실패', tag: 'Login', error: e, stackTrace: stackTrace);
    }
  }

  /// 회원가입 화면으로 이동
  void _navigateToSignUp() {
    CustomNavigationUtil.to(context, const SignUpView());
  }

  /// 테스트 페이지로 이동
  void _navigateToTestPage() {
    CustomNavigationUtil.toNamed(context, config.routeTestNavigationPage);
  }
}
