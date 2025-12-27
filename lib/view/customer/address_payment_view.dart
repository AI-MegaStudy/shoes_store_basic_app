import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/handlers/login_history_handler.dart';
import 'package:shoes_store_basic_app/model/login_history.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/user_storage.dart';
import 'package:shoes_store_basic_app/custom/custom_snack_bar.dart';
import 'package:shoes_store_basic_app/custom/custom_dialog.dart';
import 'package:shoes_store_basic_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 주소 및 결제 방법 설정 화면
/// 
/// 배송지 주소와 결제 방법을 입력하여 LoginHistory에 저장할 수 있는 화면입니다.
class AddressPaymentView extends StatefulWidget {
  const AddressPaymentView({super.key});

  @override
  State<AddressPaymentView> createState() => _AddressPaymentViewState();
}

class _AddressPaymentViewState extends State<AddressPaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _loginHistoryHandler = LoginHistoryHandler();

  // config.dart에 정의된 서울 내 자치구 리스트 사용
  final List<String> districts = config.district;
  String? selectedDistrict;
  
  late TextEditingController _paymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDistrict = districts.first; // 기본값으로 첫 번째 자치구 선택
    _paymentController = TextEditingController();
    _loadSavedData();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  /// 저장된 주소와 결제 방법 불러오기
  Future<void> _loadSavedData() async {
    final userId = UserStorage.getUserId();
    if (userId == null) return;

    try {
      final histories = await _loginHistoryHandler.queryByCustomerId(userId);
      if (histories.isNotEmpty) {
        final latest = histories.first;
        // lAddress에서 district 추출 (district만 저장하므로 그대로 사용)
        if (latest.lAddress.isNotEmpty) {
          final savedDistrict = latest.lAddress.trim();
          if (districts.contains(savedDistrict)) {
            setState(() {
              selectedDistrict = savedDistrict;
            });
          }
        }
        if (latest.lPaymentMethod.isNotEmpty) {
          _paymentController.text = latest.lPaymentMethod;
        }
      }
    } catch (e) {
      print('저장된 데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('주소 / 결제방법', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('수령 지점(자치구)', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                config.smallVerticalSpacing,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.divider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedDistrict,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12), // TextField 전용 패딩이므로 상수화하지 않음
                    ),
                    style: config.boldLabelStyle.copyWith(color: p.textPrimary),
                    items: districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d, style: config.boldLabelStyle.copyWith(color: p.textPrimary))))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '자치구를 선택해주세요.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text('Payment method', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                config.smallVerticalSpacing,
                TextFormField(
                  controller: _paymentController,
                  style: config.boldLabelStyle.copyWith(color: p.textPrimary),
                  decoration: InputDecoration(
                    hintText: '예) 신한카드 ****-****-****-1234',
                    border: OutlineInputBorder(
                      borderRadius: config.defaultBorderRadius,
                    ),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '결제 방법을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _onSavePressed,
            child: Text('변경하기', style: config.boldLabelStyle.copyWith(color: p.textOnPrimary)),
          ),
        ),
      ),
    );
  }

  /// 저장 버튼 클릭 처리
  /// 
  /// 선택한 자치구(district)와 결제 방법을 LoginHistory에 저장합니다.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserStorage.getUserId();
    if (userId == null) {
      CustomSnackBar.showError(
        context,
        message: '로그인된 사용자 정보가 없습니다.',
      );
      return;
    }

    // district만 저장 (상세 주소 없음)
    final String district = selectedDistrict ?? districts.first;
    final String payment = _paymentController.text.trim();

    try {
      // LoginHistory 객체 생성 및 저장
      final loginHistory = LoginHistory(
        cid: userId,
        lAddress: district, // district만 저장
        lPaymentMethod: payment,
        loginTime: DateTime.now().toIso8601String(),
        lStatus: 'active', // 기본 상태값
      );

      await _loginHistoryHandler.insertData(loginHistory);

      CustomDialog.show(
        context,
        title: '입력 성공',
        message: '수령 지점: $district\n결제 방법: $payment',
        type: DialogType.single,
        confirmText: '확인',
        onConfirm: () {
          _paymentController.text = '';
          CustomNavigationUtil.back(context);
          CustomNavigationUtil.back(context);
        },
      );
    } catch (e) {
      CustomDialog.show(
        context,
        title: '입력 실패',
        message: '입력에 실패하였습니다: $e',
        type: DialogType.single,
        confirmText: '확인',
      );
    }
  }
}
