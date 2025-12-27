import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/employee_handler.dart';
import 'package:shoes_store_basic_app/model/employee.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/admin_storage.dart';
import 'package:shoes_store_basic_app/utils/admin_tablet_utils.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/admin/admin_mobile_block_view.dart';

/// 관리자 개인정보 수정 화면
/// 관리자가 자신의 개인정보를 수정할 수 있는 화면입니다.
/// 이메일은 아이디 역할을 하므로 수정할 수 없습니다.

class AdminProfileEditView extends StatefulWidget {
  const AdminProfileEditView({super.key});

  @override
  State<AdminProfileEditView> createState() => _AdminProfileEditViewState();
}

class _AdminProfileEditViewState extends State<AdminProfileEditView> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'AdminProfileEditForm');

  /// 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  /// 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 비밀번호 확인 입력 컨트롤러
  final TextEditingController _passwordConfirmController = TextEditingController();

  /// 직원 핸들러
  final EmployeeHandler _employeeHandler = EmployeeHandler();

  /// 현재 관리자 정보
  Employee? _currentAdmin;

  /// 이메일 (수정 불가, 읽기 전용)
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    unlockAllOrientations();
    super.dispose();
  }

  /// 관리자 정보 로드 및 폼 채우기
  void _loadAdminData() {
    final admin = AdminStorage.getAdmin();
    if (admin != null) {
      setState(() {
        _currentAdmin = admin;
        _email = admin.eEmail;
        _nameController.text = admin.eName;
        _phoneController.text = admin.ePhoneNumber;
      });
    } else {
      CustomNavigationUtil.back(context);
      CustomSnackBar.showError(
        context,
        message: '관리자 정보를 찾을 수 없습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return GestureDetector(
      // 키보드 내리기
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '개인정보 수정',
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
      ),
    );
  }

  //----Function Start----

  /// 키보드 내리기 함수
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 수정하기 버튼 클릭 처리 함수
  /// 다이얼로그로 확인 후 DB와 get_storage를 업데이트합니다.
  void _handleUpdate() {
    // 키보드 내리기
    _unfocusKeyboard();

    // Form 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 이름과 전화번호 필수 검증
    if (!CustomTextField.textCheck(context, _nameController)) {
      CustomSnackBar.showError(context, message: '이름을 입력해주세요');
      return;
    }

    if (!CustomTextField.textCheck(context, _phoneController)) {
      CustomSnackBar.showError(context, message: '전화번호를 입력해주세요');
      return;
    }

    // 비밀번호 입력 여부 확인 및 일치 확인
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    // 비밀번호를 입력한 경우에만 비밀번호 확인 검증
    if (password.isNotEmpty) {
      // 비밀번호가 입력되었으면 비밀번호 확인도 입력되어야 함
      if (passwordConfirm.isEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호 확인을 입력해주세요');
        return;
      }
      // 비밀번호와 비밀번호 확인이 일치하는지 확인
      if (password != passwordConfirm) {
        CustomSnackBar.showError(context, message: '비밀번호가 일치하지 않습니다');
        return;
      }
    } else {
      // 비밀번호를 입력하지 않은 경우, 비밀번호 확인 필드도 비어있어야 함
      if (passwordConfirm.isNotEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호를 입력하지 않으려면 비밀번호 확인도 비워두세요');
        return;
      }
    }

    // 원래 Scaffold의 context 저장 (다이얼로그 닫은 후 사용)
    final scaffoldContext = context;

    // 다이얼로그로 확인
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
          AppLogger.e('업데이트 중 예외 발생', tag: 'AdminProfileEdit', error: e, stackTrace: stackTrace);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          CustomSnackBar.showError(scaffoldContext, message: '업데이트 중 오류가 발생했습니다: $e');
        }
      },
      onCancel: () {
        // 취소 버튼 클릭 시 다이얼로그만 닫기 (저장하지 않음)
      },
    );
  }

  /// 실제 업데이트 수행
  Future<bool> _performUpdate() async {
    if (_currentAdmin == null || _currentAdmin!.id == null) {
      AppLogger.e('관리자 정보가 null입니다', tag: 'AdminProfileEdit');
      CustomSnackBar.showError(context, message: '관리자 정보를 찾을 수 없습니다');
      return false;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final updatedEmployee = Employee(
        id: _currentAdmin!.id,
        eEmail: _email,
        ePhoneNumber: phone,
        eName: name,
        ePassword: password.isNotEmpty ? password : _currentAdmin!.ePassword,
        eRole: _currentAdmin!.eRole,
      );
      
      await _employeeHandler.updateData(updatedEmployee);
      AdminStorage.saveAdmin(updatedEmployee);
      
      AppLogger.d('관리자 개인정보 수정 완료', tag: 'AdminProfileEdit');

      CustomSnackBar.showSuccess(
        context,
        message: '개인정보가 수정되었습니다.',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.e('개인정보 수정 에러', tag: 'AdminProfileEdit', error: e, stackTrace: stackTrace);
      CustomSnackBar.showError(context, message: '개인정보 수정 중 오류가 발생했습니다: $e');
      return false;
    }
  }
}

