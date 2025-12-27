import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:shoes_store_basic_app/database/handlers/customer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/model/customer.dart';
import 'package:shoes_store_basic_app/model/login_history.dart';
import 'package:shoes_store_basic_app/utils/app_logger.dart';
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/screens/auth/login_view.dart';

/// 회원가입 화면
class SignUpView extends StatefulWidget {
  final Map<String, String>? testData;

  const SignUpView({super.key, this.testData});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'SignUpForm');

  // 이메일 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController();

  // 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  // 비밀번호 확인 입력 컨트롤러
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  // 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  // 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  // 약관 동의 상태
  bool _agreeAll = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  // 약관 에러 상태 (회원가입 버튼 클릭 시 체크되지 않은 필수 약관 표시)
  bool _termsError = false;
  bool _privacyError = false;

  /// 회원가입 진행 중 상태 (로딩 인디케이터 표시용)
  bool _isSigningUp = false;

  /// 고객 핸들러
  final CustomerHandler _customerHandler = CustomerHandler();
  
  /// 로그인 이력 핸들러
  final LoginHistoryHandler _loginHistoryHandler = LoginHistoryHandler();

  @override
  void initState() {
    super.initState();

    // 테스트용 더미 데이터가 제공되면 폼에 자동 입력
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.testData != null) {
        _fillFormWithTestData(widget.testData!);
      }
    });
  }

  /// 테스트용 더미 데이터로 폼을 자동으로 채우는 함수
  /// [testData] 테스트용 더미 데이터 맵 (email, password, name, phone 키 포함)
  void _fillFormWithTestData(Map<String, String> testData) {
    setState(() {
      // 이메일 자동 입력
      if (testData.containsKey('email')) {
        _emailController.text = testData['email']!;
      }
      // 비밀번호 자동 입력
      if (testData.containsKey('password')) {
        _passwordController.text = testData['password']!;
        _passwordConfirmController.text = testData['password']!;
      }
      // 이름 자동 입력
      if (testData.containsKey('name')) {
        _nameController.text = testData['name']!;
      }
      // 전화번호 자동 입력
      if (testData.containsKey('phone')) {
        _phoneController.text = testData['phone']!;
      }
      // 약관 동의 자동 체크 (테스트 편의를 위해)
      if (testData.containsKey('autoAgree') && testData['autoAgree'] == 'true') {
        _agreeAll = true;
        _agreeTerms = true;
        _agreePrivacy = true;
        _agreeMarketing = true;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque, // 자식 위젯이 터치를 소비해도 onTap이 호출되도록 설정
      child: Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: CustomAppBar(
              title: '회원가입',
              centerTitle: true,
              titleTextStyle: config.boldLabelStyle,
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
            ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: CustomPadding(
              padding: config.screenPadding,
              child: CustomColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  // 약관 동의 섹션
                  CustomCard(
                    padding: const EdgeInsets.all(10),
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 6,
                      children: [
                        // 전체 동의
                        CustomCheckbox(
                          value: _agreeAll,
                          onChanged: _handleAgreeAll,
                          label: '전체 동의',
                          spacing: 4,
                          labelStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(),

                        // 필수 약관: 이용약관
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: _termsError && !_agreeTerms
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: p.accent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : null,
                                child: CustomCheckbox(
                                  value: _agreeTerms,
                                  onChanged: (value) =>
                                      _handleIndividualAgree('terms', value),
                                  label: '이용약관 동의 (필수)',
                                  spacing: 2,
                                  activeColor: _termsError && _agreeTerms
                                      ? p.accent
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 50,
                              child: CustomButton(
                                btnText: '보기',
                                buttonType: ButtonType.text,
                                onCallBack: () => _viewTerms('terms'),
                                backgroundColor: Colors.transparent,
                                foregroundColor: p.primary,
                                textFontSize: 14,
                                textFontWeight: FontWeight.normal,
                                minimumSize: const Size(0, 0),
                                borderRadius: 0,
                              ),
                            ),
                          ],
                        ),

                        // 필수 약관: 개인정보 처리방침
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: _privacyError && !_agreePrivacy
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: p.accent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : null,
                                child: CustomCheckbox(
                                  value: _agreePrivacy,
                                  onChanged: (value) =>
                                      _handleIndividualAgree('privacy', value),
                                  label: '개인정보 처리방침 동의 (필수)',
                                  spacing: 2,
                                  activeColor: _privacyError && _agreePrivacy
                                      ? p.accent
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 50,
                              child: CustomButton(
                                btnText: '보기',
                                buttonType: ButtonType.text,
                                onCallBack: () => _viewTerms('privacy'),
                                backgroundColor: Colors.transparent,
                                foregroundColor: p.primary,
                                textFontSize: 14,
                                textFontWeight: FontWeight.normal,
                                minimumSize: const Size(0, 0),
                                borderRadius: 0,
                              ),
                            ),
                          ],
                        ),

                        // 선택 약관: 마케팅 정보 수신
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomCheckbox(
                                value: _agreeMarketing,
                                onChanged: (value) =>
                                    _handleIndividualAgree('marketing', value),
                                label: '마케팅 정보 수신 동의 (선택)',
                                spacing: 2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 50,
                              child: CustomButton(
                                btnText: '보기',
                                buttonType: ButtonType.text,
                                onCallBack: () => _viewTerms('marketing'),
                                backgroundColor: Colors.transparent,
                                foregroundColor: p.primary,
                                textFontSize: 14,
                                textFontWeight: FontWeight.normal,
                                minimumSize: const Size(0, 0),
                                borderRadius: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 입력 필드 섹션
                  Form(
                    key: _formKey,
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        // 이메일 입력 필드 (Form 검증)
                        CustomTextField(
                          controller: _emailController,
                          labelText: '이메일',
                          hintText: '이메일을 입력하세요',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          required: true,
                          requiredMessage: '이메일을 입력해주세요',
                        ),

                        // 비밀번호 입력 필드 (Form 검증)
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          hintText: '비밀번호를 입력하세요',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock),
                          required: true,
                          requiredMessage: '비밀번호를 입력해주세요',
                        ),

                        // 비밀번호 확인 입력 필드
                        CustomTextField(
                          controller: _passwordConfirmController,
                          labelText: '비밀번호 확인',
                          hintText: '비밀번호를 다시 입력하세요',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),

                        // 이름 입력 필드 (textCheck)
                        CustomTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '이름을 입력하세요',
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.badge),
                        ),

                        // 전화번호 입력 필드 (textCheck)
                        CustomTextField(
                          controller: _phoneController,
                          labelText: '전화번호',
                          hintText: '전화번호를 입력하세요',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 회원가입 버튼
                  // 회원가입 진행 중일 때는 버튼 비활성화 (onCallBack을 null로 설정하면 Flutter 기본 버튼이 자동으로 disabled 상태가 됨)
                  CustomButton(
                    btnText: '회원가입',
                    buttonType: ButtonType.elevated,
                    onCallBack: _isSigningUp ? null : _handleSignUp,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ],
              ),
            ),
          ),
        ),
          );
        },
      ),
    );
  }

  //----Function Start----

  // 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // 전체 동의 체크박스 변경 처리
  void _handleAgreeAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _agreeTerms = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeMarketing = _agreeAll;
      // 체크되면 에러 상태 해제
      if (_agreeAll) {
        _termsError = false;
        _privacyError = false;
      }
    });
  }

  // 개별 약관 동의 변경 처리
  void _handleIndividualAgree(String type, bool? value) {
    setState(() {
      switch (type) {
        case 'terms':
          _agreeTerms = value ?? false;
          // 체크되면 에러 상태 해제
          if (_agreeTerms) {
            _termsError = false;
          }
          break;
        case 'privacy':
          _agreePrivacy = value ?? false;
          // 체크되면 에러 상태 해제
          if (_agreePrivacy) {
            _privacyError = false;
          }
          break;
        case 'marketing':
          _agreeMarketing = value ?? false;
          break;
      }
      // 모든 개별 약관이 체크되면 전체 동의도 체크
      _agreeAll = _agreeTerms && _agreePrivacy;
    });
  }

  /// 회원가입 버튼 클릭 처리 함수
  /// 약관 동의 확인, 입력값 검증, 중복 확인 후 Customer DB에 저장합니다.
  Future<void> _handleSignUp() async {
    // 이미 회원가입 진행 중이면 중복 실행 방지
    if (_isSigningUp) {
      return;
    }

    // 키보드 내리기
    FocusScope.of(context).unfocus();

    // 필수 약관 동의 확인
    if (!_agreeTerms || !_agreePrivacy) {
      setState(() {
        // 체크되지 않은 필수 약관에 에러 상태 설정
        _termsError = !_agreeTerms;
        _privacyError = !_agreePrivacy;
      });
      CustomSnackBar.showError(context, message: '필수 약관에 동의해주세요');
      return;
    }

    // Form 검증 (이메일, 비밀번호)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 전화번호 textCheck 검증
    if (!CustomTextField.textCheck(context, _phoneController)) {
      CustomSnackBar.showError(context, message: '전화번호를 입력해주세요');
      return;
    }

    // 이름 textCheck 검증
    if (!CustomTextField.textCheck(context, _nameController)) {
      CustomSnackBar.showError(context, message: '이름을 입력해주세요');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // 이메일 형식 검증
    // CustomCommonUtil.isEmail() 함수를 사용하여 정규식으로 이메일 형식을 검증합니다.
    if (!CustomCommonUtil.isEmail(email)) {
      CustomSnackBar.showError(context, message: '올바른 이메일 형식을 입력해주세요');
      return;
    }

    // 비밀번호 일치 확인
    // 비밀번호와 비밀번호 확인 필드의 값이 일치하는지 확인합니다.
    if (password != passwordConfirm) {
      CustomSnackBar.showError(context, message: '비밀번호가 일치하지 않습니다');
      return;
    }

    /// 이메일 중복 확인
    try {
      final existingCustomer = await _customerHandler.queryByEmail(email);
      if (existingCustomer != null) {
        CustomSnackBar.showError(context, message: '이미 사용 중인 이메일입니다');
        return;
      }
    } catch (e) {
      AppLogger.e('이메일 중복 확인 에러', tag: 'SignUp', error: e);
      CustomSnackBar.showError(context, message: '회원가입 중 오류가 발생했습니다');
      return;
    }

    /// 전화번호 중복 확인
    try {
      final existingCustomer = await _customerHandler.queryByPhoneNumber(phone);
      if (existingCustomer != null) {
        CustomSnackBar.showError(context, message: '이미 사용 중인 전화번호입니다');
        return;
      }
    } catch (e) {
      AppLogger.e('전화번호 중복 확인 에러', tag: 'SignUp', error: e);
      CustomSnackBar.showError(context, message: '회원가입 중 오류가 발생했습니다');
      return;
    }

    // 회원가입 진행 중 상태로 변경 (로딩 인디케이터 표시)
    setState(() {
      _isSigningUp = true;
    });

    /// Customer 객체 생성 및 DB에 저장
    try {
      final newCustomer = Customer(
        cEmail: email,
        cPhoneNumber: phone,
        cName: name,
        cPassword: password,
      );

      final insertedId = await _customerHandler.insertData(newCustomer);

      if (insertedId > 0) {
        /// 로그인 히스토리 저장
        try {
          final loginHistory = LoginHistory(
            cid: insertedId,
            loginTime: DateTime.now().toIso8601String(),
            lStatus: config.loginStatus[0] as String, // '활동 회원'
            lAddress: '',
            lPaymentMethod: '',
          );
          
          await _loginHistoryHandler.insertData(loginHistory);
        } catch (e) {
          AppLogger.e('로그인 히스토리 저장 실패', tag: 'SignUp', error: e);
        }
      }

      if (insertedId > 0) {
        // 회원가입 성공 - SnackBar를 표시하고 바로 화면 이동
        // SnackBar는 화면 전환 후에도 계속 표시되므로 딜레이가 필요 없음
        CustomSnackBar.showSuccess(
          context,
          message: '회원가입이 완료되었습니다. 로그인해주세요.',
          duration: const Duration(seconds: 2),
        );

        // 화면이 즉시 이동하므로 _isSigningUp 상태를 되돌릴 필요 없음
        CustomNavigationUtil.offAll(context, const LoginView());
      } else {
        // 회원가입 실패 - 버튼 다시 활성화
        setState(() {
          _isSigningUp = false;
        });
        CustomSnackBar.showError(context, message: '회원가입에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      setState(() {
        _isSigningUp = false;
      });

      AppLogger.e('회원가입 실패', tag: 'SignUp', error: e);
      CustomSnackBar.showError(context, message: '회원가입 중 오류가 발생했습니다.');
    }
  }

  // 약관 보기 다이얼로그 표시
  void _viewTerms(String type) {
    String title;
    String content;

    switch (type) {
      case 'terms':
        title = '이용약관';
        content = _getTermsContent();
        break;
      case 'privacy':
        title = '개인정보 처리방침';
        content = _getPrivacyContent();
        break;
      case 'marketing':
        title = '마케팅 정보 수신 동의';
        content = _getMarketingContent();
        break;
      default:
        title = '약관';
        content = '약관 내용이 없습니다.';
    }

    CustomDialog.show(
      context,
      title: title,
      message: _buildTermsDialogContent(content),
      type: DialogType.single,
      confirmText: '확인',
      borderRadius: 12,
    );
  }

  // 약관 다이얼로그 내용 위젯 생성
  Widget _buildTermsDialogContent(String content) {
    return Container(
      constraints: BoxConstraints(maxHeight: config.dialogMaxHeight, minHeight: config.dialogMinHeight),
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: CustomText(
          content,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  // 이용약관 내용
  String _getTermsContent() {
    return '''제1조 (목적)
이 약관은 신발 가게(이하 "회사"라 함)가 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 신발 구매 및 관련 서비스를 의미합니다.
2. "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.
3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며, 회사가 제공하는 서비스를 계속적으로 이용할 수 있는 자를 말합니다.

제3조 (약관의 게시와 개정)
1. 회사는 이 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 초기 화면에 게시합니다.
2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다.
3. 회사가 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 서비스의 초기화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다.

제4조 (회원가입)
1. 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.
2. 회사는 제1항과 같이 회원가입을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다.
   가. 가입신청자가 이 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우
   나. 등록 내용에 허위, 기재누락, 오기가 있는 경우
   다. 기타 회원으로 등록하는 것이 회사의 기술상 현저히 지장이 있다고 판단되는 경우

제5조 (서비스의 제공 및 변경)
1. 회사는 다음과 같은 서비스를 제공합니다.
   가. 신발 구매 서비스
   나. 구매 내역 조회 서비스
   다. 대리점 방문 수령 서비스
   라. 기타 회사가 추가 개발하거나 제휴계약 등을 통해 회원에게 제공하는 일체의 서비스

제6조 (서비스의 중단)
1. 회사는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.

제7조 (회원의 의무)
1. 회원은 다음 행위를 하여서는 안 됩니다.
   가. 신청 또는 변경 시 허위내용의 등록
   나. 타인의 정보 도용
   다. 회사가 게시한 정보의 변경
   라. 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시
   마. 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해
   바. 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위

제8조 (개인정보보호)
1. 회사는 이용자의 개인정보 수집시 서비스제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집합니다.
2. 회사는 회원가입시 구매계약이행에 필요한 정보를 미리 수집하지 않습니다.

본 약관은 2025년 1월 1일부터 시행됩니다.''';
  }

  // 개인정보 처리방침 내용
  String _getPrivacyContent() {
    return '''제1조 (개인정보의 처리목적)
회사는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 개인정보 보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

1. 홈페이지 회원 가입 및 관리
   - 회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지 목적으로 개인정보를 처리합니다.

2. 재화 또는 서비스 제공
   - 물품배송, 서비스 제공, 계약서·청구서 발송, 콘텐츠 제공, 맞춤서비스 제공, 본인인증을 목적으로 개인정보를 처리합니다.

3. 마케팅 및 광고에의 활용
   - 신규 서비스(제품) 개발 및 맞춤 서비스 제공, 이벤트 및 광고성 정보 제공 및 참여기회 제공을 목적으로 개인정보를 처리합니다.

제2조 (개인정보의 처리 및 보유기간)
1. 회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.
2. 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.
   가. 홈페이지 회원 가입 및 관리: 회원 탈퇴시까지
   나. 재화 또는 서비스 제공: 재화·서비스 공급완료 및 요금결제·정산 완료시까지
   다. 마케팅 및 광고에의 활용: 회원 탈퇴시까지

제3조 (처리하는 개인정보의 항목)
회사는 다음의 개인정보 항목을 처리하고 있습니다.

1. 홈페이지 회원 가입 및 관리
   - 필수항목: 아이디, 비밀번호, 이름, 전화번호
   - 선택항목: 없음

2. 재화 또는 서비스 제공
   - 필수항목: 이름, 전화번호, 배송주소
   - 선택항목: 없음

제4조 (개인정보의 제3자 제공)
회사는 정보주체의 개인정보를 제1조(개인정보의 처리목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

제5조 (개인정보처리의 위탁)
1. 회사는 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다.
   - 위탁받는 자(수탁자): 없음
   - 위탁하는 업무의 내용: 없음

제6조 (정보주체의 권리·의무 및 행사방법)
1. 정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.
   가. 개인정보 처리정지 요구
   나. 개인정보 열람요구
   다. 개인정보 정정·삭제요구
   라. 개인정보 처리정지 요구

제7조 (개인정보의 파기)
1. 회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

제8조 (개인정보 보호책임자)
1. 회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.
   - 개인정보 보호책임자: 홍길동
   - 연락처: 02-1234-5678

본 방침은 2025년 1월 1일부터 시행됩니다.''';
  }

  // 마케팅 정보 수신 동의 내용
  String _getMarketingContent() {
    return '''제1조 (목적)
본 마케팅 정보 수신 동의는 신발 가게(이하 "회사"라 함)가 제공하는 마케팅 정보 수신에 대한 이용자의 동의를 받기 위한 것입니다.

제2조 (마케팅 정보 수신 동의)
1. 회사는 이용자에게 다양한 혜택 정보, 이벤트 정보, 신상품 정보 등의 마케팅 정보를 제공할 수 있습니다.
2. 마케팅 정보 수신 동의는 선택사항이며, 동의하지 않아도 서비스 이용에는 제한이 없습니다.
3. 마케팅 정보 수신에 동의한 경우에도 언제든지 동의를 철회할 수 있습니다.

제3조 (마케팅 정보 제공 방법)
회사는 다음과 같은 방법으로 마케팅 정보를 제공할 수 있습니다.
1. 이메일
2. SMS
3. 앱 푸시 알림
4. 전화

제4조 (마케팅 정보 수신 거부)
1. 이용자는 마케팅 정보 수신에 동의한 후에도 언제든지 수신을 거부할 수 있습니다.
2. 마케팅 정보 수신 거부는 회원정보 수정 페이지에서 변경할 수 있습니다.

제5조 (개인정보 보호)
1. 회사는 마케팅 정보 제공을 위해 수집한 개인정보를 마케팅 목적 이외의 용도로 사용하지 않습니다.
2. 개인정보 보호에 관한 사항은 개인정보 처리방침에 따릅니다.

본 동의는 2025년 1월 1일부터 시행됩니다.''';
  }

  //----Function End----
}
