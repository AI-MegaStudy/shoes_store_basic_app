import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';

/// 사용자 개인정보 수정 화면
/// 사용자가 자신의 개인정보를 수정할 수 있는 화면입니다.
/// 이메일은 아이디 역할을 하므로 수정할 수 없습니다.

class UserProfileEditView extends StatefulWidget {
  const UserProfileEditView({super.key});

  @override
  State<UserProfileEditView> createState() => _UserProfileEditViewState();
}

class _UserProfileEditViewState extends State<UserProfileEditView> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'UserProfileEditForm');

  /// 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  /// 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 비밀번호 확인 입력 컨트롤러
  final TextEditingController _passwordConfirmController = TextEditingController();

  /// 고객 핸들러
  final CustomerHandler _customerHandler = CustomerHandler();

  /// 현재 사용자 정보
  Customer? _currentCustomer;

  /// 이메일 (수정 불가, 읽기 전용)
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// 사용자 정보 로드 및 폼 채우기
  Future<void> _loadUserData() async {
    final customer = UserStorage.getUser();

    if (customer != null) {
      try {
        final latestCustomer = await _customerHandler.queryByEmail(customer.cEmail);
        
        if (latestCustomer != null) {
          setState(() {
            _currentCustomer = latestCustomer;
            _email = latestCustomer.cEmail;
            _nameController.text = latestCustomer.cName;
            _phoneController.text = latestCustomer.cPhoneNumber;
          });
        } else {
          CustomNavigationUtil.back(context);
          CustomSnackBar.showError(
            context,
            message: '사용자 정보를 찾을 수 없습니다.',
          );
        }
      } catch (error) {
        AppLogger.e('사용자 정보 로드 에러', tag: 'UserProfileEdit', error: error);
        CustomNavigationUtil.back(context);
        CustomSnackBar.showError(
          context,
          message: '사용자 정보를 불러오는 중 오류가 발생했습니다.',
        );
      }
    } else {
      CustomNavigationUtil.back(context);
      CustomSnackBar.showError(
        context,
        message: '로그인 정보를 찾을 수 없습니다.',
      );
    }
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
              title: '개인정보 수정',
              centerTitle: true,
              titleTextStyle: config.boldLabelStyle,
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
            ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: config.dialogMaxWidth),
                child: CustomPadding(
                  padding: config.userProfileEditPadding,
                  child: Form(
                    key: _formKey,
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: config.largeSpacing,
                      children: [
                        // 개인정보 수정 타이틀
                        CustomText(
                          '개인정보 수정',
                          style: config.largeTitleStyle,
                          textAlign: TextAlign.center,
                        ),

                        // 이메일 입력 필드 (읽기 전용, 수정 불가)
                        CustomTextField(
                          controller: TextEditingController(text: _email),
                          labelText: '이메일 (아이디)',
                          hintText: '이메일',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          enabled: false, // 수정 불가
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: p.chipUnselectedBg,
                          ),
                        ),

                        // 이름 입력 필드
                        CustomTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '이름을 입력하세요',
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.person),
                          required: true,
                          requiredMessage: '이름을 입력해주세요',
                        ),

                        // 전화번호 입력 필드
                        CustomTextField(
                          controller: _phoneController,
                          labelText: '전화번호',
                          hintText: '전화번호를 입력하세요',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          required: true,
                          requiredMessage: '전화번호를 입력해주세요',
                        ),

                        // 비밀번호 입력 필드
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          hintText: '새 비밀번호를 입력하세요 (변경하지 않으려면 비워두세요)',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock),
                        ),

                        // 비밀번호 확인 입력 필드
                        CustomTextField(
                          controller: _passwordConfirmController,
                          labelText: '비밀번호 확인',
                          hintText: '비밀번호를 다시 입력하세요 (변경하지 않으려면 비워두세요)',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),

                        // 수정하기 버튼
                        CustomButton(
                          btnText: '수정하기',
                          buttonType: ButtonType.elevated,
                          onCallBack: _handleUpdate,
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
          );
        },
      ),
    );
  }

  /// 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 수정하기 버튼 클릭 처리
  void _handleUpdate() {
    _unfocusKeyboard();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!CustomTextField.textCheck(context, _nameController)) {
      CustomSnackBar.showError(context, message: '이름을 입력해주세요');
      return;
    }

    if (!CustomTextField.textCheck(context, _phoneController)) {
      CustomSnackBar.showError(context, message: '전화번호를 입력해주세요');
      return;
    }

    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    if (password.isNotEmpty) {
      if (passwordConfirm.isEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호 확인을 입력해주세요');
        return;
      }
      if (password != passwordConfirm) {
        CustomSnackBar.showError(context, message: '비밀번호가 일치하지 않습니다');
        return;
      }
    } else {
      if (passwordConfirm.isNotEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호를 입력하지 않으려면 비밀번호 확인도 비워두세요');
        return;
      }
    }

    final scaffoldContext = context;

    CustomDialog.show(
      context,
      title: '개인정보 수정 확인',
      message: '정말 수정하시겠습니까?',
      type: DialogType.dual,
      confirmText: '확인',
      cancelText: '취소',
      borderRadius: config.defaultDialogBorderRadius,
      autoDismissOnConfirm: false,
      onConfirm: () async {
        try {
          final success = await _performUpdate();
          if (success) {
            // 다이얼로그 닫기
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            // 화면 닫기 (true 반환하여 상위 화면에 성공 알림)
            if (scaffoldContext.mounted) {
              Navigator.of(scaffoldContext).pop(true);
            }
          } else {
            // 실패 시 다이얼로그만 닫기
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        } catch (e, stackTrace) {
          AppLogger.e('업데이트 중 예외 발생', tag: 'UserProfileEdit', error: e, stackTrace: stackTrace);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          CustomSnackBar.showError(scaffoldContext, message: '업데이트 중 오류가 발생했습니다: $e');
        }
      },
      onCancel: () {},
    );
  }

  /// 실제 업데이트 수행
  Future<bool> _performUpdate() async {
    if (_currentCustomer == null || _currentCustomer!.id == null) {
      AppLogger.e('사용자 정보가 null입니다', tag: 'UserProfileEdit');
      CustomSnackBar.showError(context, message: '사용자 정보를 찾을 수 없습니다');
      return false;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final updatedCustomer = Customer(
        id: _currentCustomer!.id,
        cEmail: _email,
        cPhoneNumber: phone,
        cName: name,
        cPassword: password.isNotEmpty ? password : _currentCustomer!.cPassword,
      );
      
      await _customerHandler.updateData(updatedCustomer);
      UserStorage.saveUser(updatedCustomer);
      
      AppLogger.d('사용자 개인정보 수정 완료', tag: 'UserProfileEdit');

      CustomSnackBar.showSuccess(
        context,
        message: '개인정보가 수정되었습니다.',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.e('개인정보 수정 에러', tag: 'UserProfileEdit', error: e, stackTrace: stackTrace);
      CustomSnackBar.showError(context, message: '개인정보 수정 중 오류가 발생했습니다: $e');
      return false;
    }
  }
}

