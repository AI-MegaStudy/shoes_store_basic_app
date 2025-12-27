import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/handlers/employee_handler.dart';
import 'package:shoes_store_basic_app/model/employee.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/admin_storage.dart';
import 'package:shoes_store_basic_app/utils/admin_tablet_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_mobile_block_view.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_order_view.dart';

/// 관리자 로그인 화면
/// 태블릿에서 가로 모드로 강제 표시되는 관리자 전용 로그인 화면입니다.
/// 관리자는 회원가입이 불가능하며 로그인만 가능합니다.

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'AdminLoginForm');

  /// 이메일 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 직원 핸들러
  final EmployeeHandler _employeeHandler = EmployeeHandler();

  @override
  void initState() {
    super.initState();

    /// 태블릿이 아니면 모바일 차단 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTablet(context)) {
        CustomNavigationUtil.off(context, const AdminMobileBlockView());
      } else {
        lockTabletLandscape(context);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    unlockAllOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '관리자 로그인',
          centerTitle: true,
          toolbarHeight: 48,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: config.dialogMaxWidth),
                child: CustomPadding(
                  padding: config.profileEditPadding,
                  child: Form(
                    key: _formKey,
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: config.largeSpacing,
                      children: [
                        CustomText(
                          '관리자 로그인',
                          style: config.largeTitleStyle,
                          textAlign: TextAlign.center,
                        ),

                        CustomText(
                          '태블릿에서만 접근 가능합니다',
                          style: config.bodyTextStyle,
                          fontWeight: FontWeight.normal,
                          textAlign: TextAlign.center,
                          color: Colors.grey[600],
                        ),

                        CustomTextField(
                          controller: _emailController,
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

                        CustomButton(
                          btnText: '로그인',
                          buttonType: ButtonType.elevated,
                          onCallBack: _handleLogin,
                          minimumSize: Size(double.infinity, config.defaultButtonHeight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 로그인 버튼 클릭 처리
  void _handleLogin() async {
    _unfocusKeyboard();

    if (!_formKey.currentState!.validate()) return;

    final input = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final isEmail = CustomCommonUtil.isEmail(input);

    try {
      Employee? employee;
      
      if (isEmail) {
        employee = await _employeeHandler.queryByEmail(input);
      } else {
        employee = await _employeeHandler.queryByPhoneNumber(input);
      }

      if (employee == null || employee.ePassword != password) {
        CustomSnackBar.showError(
          context,
          message: '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      AppLogger.d('관리자 로그인 성공: ${employee.eName}', tag: 'AdminLogin');
      
      AdminStorage.saveAdmin(employee);
      
      CustomSnackBar.showSuccess(
        context,
        message: '${employee.eName}님 환영합니다!',
      );
      CustomNavigationUtil.off(context, const AdminOrderView());
    } catch (error) {
      AppLogger.e('로그인 에러', tag: 'AdminLogin', error: error);
      CustomSnackBar.showError(
        context,
        message: '로그인 중 오류가 발생했습니다.',
      );
    }
  }
}

