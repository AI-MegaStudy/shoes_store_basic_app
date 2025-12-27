import 'package:flutter/material.dart';

import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/custom/custom.dart';
import 'package:shoes_store_basic_app/view/cheng/widgets/customer/customer_info_card.dart';
import 'package:shoes_store_basic_app/utils/order_utils.dart';

/// 주문 상세 정보 뷰
/// 주문 관리 화면의 우측에 표시되는 주문 상세 정보를 보여주는 위젯입니다.
/// 주문자 정보, 주문 상품 목록, 총 가격, 픽업 완료 버튼을 포함합니다.
class OrderDetailView extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;

  const OrderDetailView({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: DB에서 주문 상세 정보 가져오기
    // 임시 데이터 - 실제 구현 시 DB에서 조회한 데이터로 교체 필요
    final customerInfo = {
      'name': '홍길동',
      'phone': '010-1234-5678',
      'email': 'hong@example.com',
    };

    // 주문 상품 목록 (임시 데이터)
    final orderItems = [
      {
        'productName': '나이키 에어맥스',
        'size': '265',
        'color': '블랙',
        'quantity': 1,
        'price': 120000,
      },
      {
        'productName': '아디다스 스탠스미스',
        'size': '270',
        'color': '화이트',
        'quantity': 2,
        'price': 150000,
      },
    ];

    // 주문 상품들의 총 가격 계산
    final totalPrice = orderItems.fold<int>(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
    );

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: config.defaultSpacing,
      children: [
        // 주문자 상세 정보 카드
        CustomerInfoCard(
          name: customerInfo['name'] as String,
          phone: customerInfo['phone'] as String,
          email: customerInfo['email'] as String,
        ),

        // 주문 상품들
        CustomText('주문 상품들', style: config.titleStyle),

        // 주문 상품 리스트 (각 상품을 카드로 표시)
        ...orderItems.map((item) {
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: config.mediumPadding,
            child: CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 상품명 (가장 넓은 영역)
                Expanded(
                  flex: 2,
                  child: CustomText(
                    item['productName'] as String,
                    style: config.bodyTextStyle,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                // 사이즈 표시
                SizedBox(
                  width: 60,
                  child: CustomText(
                    '${item['size']}',
                    style: config.bodyTextStyle,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 색상 표시
                SizedBox(
                  width: 60,
                  child: CustomText(
                    item['color'] as String,
                    style: config.bodyTextStyle,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 수량 표시
                SizedBox(
                  width: 40,
                  child: CustomText(
                    '${item['quantity']}',
                    style: config.bodyTextStyle,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 가격 표시 (오른쪽 정렬)
                SizedBox(
                  width: 100,
                  child: CustomText(
                    '${OrderUtils.formatPrice(item['price'] as int)}원',
                    style: config.bodyTextStyle,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),

        // 총 가격 표시 (오른쪽 정렬)
        CustomRow(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              '총 가격: ${OrderUtils.formatPrice(totalPrice)}원',
              style: config.mediumTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // 픽업 완료 버튼 (주문 처리가 완료되었을 때 클릭)
        CustomButton(
          btnText: '픽업 완료',
          buttonType: ButtonType.elevated,
          onCallBack: () {
            // TODO: 픽업 완료 함수 호출 - DB 업데이트 및 상태 변경 필요
            print('픽업 완료: $orderId');
          },
          minimumSize: const Size(double.infinity, 50),
        ),
      ],
    );
  }
}

