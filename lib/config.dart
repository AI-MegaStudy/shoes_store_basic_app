//  Configuration of the App


import 'package:flutter/material.dart';


const String dbName = 'shoes_store_db';
const String dbFileExt = '.db';
const int schemaVersion = 1;



//  Paths
const String imageAssetPath = 'images/';

//  DB Dummies
const int defaultUserId = -1;  //  UserID befor login
const String defaultProductImage = '${imageAssetPath}default.png';  //  Default image for ProductBase

//  Storage Keys
const String storageKeyDBInitialized = 'db_initialized';  //  DB 초기화 완료 여부 저장 키

//-----------------------------------------------------
//  Business Rules
/// 휴면 회원 판단 기준일 (일수) - 6개월 미접속 시 휴면 회원 처리
const int dormantAccountDays = 180;

/// 주문 자동 수령 완료 기준일 (일수) - 픽업 날짜로부터 30일 경과 시 자동 수령 완료 처리
const int autoCompleteOrderDays = 30;

//  UI Constants
/// 제품 상세 화면 이미지 높이 (픽셀)
const double productDetailImageHeight = 280.0;

/// 기본 버튼 높이 (픽셀)
const double defaultButtonHeight = 56.0;

/// 다이얼로그 최대 너비 (픽셀) - 로그인, 회원가입, 프로필 편집 등
const double dialogMaxWidth = 600.0;

/// 다이얼로그 최소 높이 (픽셀)
const double dialogMinHeight = 200.0;

/// 다이얼로그 최대 높이 (픽셀)
const double dialogMaxHeight = 400.0;

//  UI Spacing & Padding
/// 기본 화면 패딩 (픽셀) - 대부분의 화면에서 사용
const EdgeInsets screenPadding = EdgeInsets.all(16);

/// 작은 패딩 (픽셀) - 카드 내부, 작은 요소
const EdgeInsets smallPadding = EdgeInsets.all(8);

/// 중간 패딩 (픽셀) - 카드 내부
const EdgeInsets mediumPadding = EdgeInsets.all(12);

/// 큰 패딩 (픽셀) - 큰 카드, 중요한 섹션
const EdgeInsets largePadding = EdgeInsets.all(24);

/// 폼 화면 수평 패딩 (픽셀) - 로그인/회원가입 폼
const EdgeInsets formHorizontalPadding = EdgeInsets.symmetric(horizontal: 24);

/// 프로필 편집 화면 패딩 (픽셀) - 관리자 프로필 편집 화면
const EdgeInsets profileEditPadding = EdgeInsets.symmetric(horizontal: 48, vertical: 32);

/// 사용자 프로필 편집 화면 패딩 (픽셀) - 사용자 프로필 편집 화면
const EdgeInsets userProfileEditPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 32);

/// 기본 간격 (픽셀) - CustomColumn, CustomRow spacing
const double defaultSpacing = 16.0;

/// 작은 간격 (픽셀) - 카드 내부 요소 간격
const double smallSpacing = 8.0;

/// 중간 간격 (픽셀) - 카드 내부 요소 간격
const double mediumSpacing = 12.0;

/// 큰 간격 (픽셀) - 폼 화면 요소 간격
const double largeSpacing = 24.0;

/// 매우 큰 간격 (픽셀) - 섹션 간 수직 간격
const double extraLargeSpacing = 32.0;

/// 기본 SizedBox 높이 (픽셀) - 요소 간 수직 간격
const SizedBox defaultVerticalSpacing = SizedBox(height: 16);

/// 작은 SizedBox 높이 (픽셀) - 작은 요소 간 수직 간격
const SizedBox smallVerticalSpacing = SizedBox(height: 8);

/// 큰 SizedBox 높이 (픽셀) - 폼 요소 간 수직 간격
const SizedBox largeVerticalSpacing = SizedBox(height: 24);

//  UI Border Radius
/// 기본 BorderRadius - 대부분의 카드, 다이얼로그
const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(12));

/// 중간 BorderRadius - 큰 카드
const BorderRadius mediumBorderRadius = BorderRadius.all(Radius.circular(16));

/// 큰 BorderRadius - 검색바 등
const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(24));

/// BottomSheet 상단 BorderRadius - PaymentSheetContent 등
const BorderRadius bottomSheetTopBorderRadius = BorderRadius.vertical(top: Radius.circular(20));

/// 작은 BorderRadius - 작은 요소
const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(4));

/// 다이얼로그 기본 BorderRadius 값 (double) - CustomDialog borderRadius 파라미터용
const double defaultDialogBorderRadius = 12.0;

//  UI Text Styles
/// 큰 제목 텍스트 스타일 (프로필 화면 제목 등)
const TextStyle largeTitleStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

/// 제목 텍스트 스타일 (섹션 제목 등)
const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

/// 기본 텍스트 스타일 (본문)
const TextStyle bodyTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

/// 중간 텍스트 스타일 (중요한 정보)
const TextStyle mediumTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

/// 작은 텍스트 스타일 (부가 정보)
const TextStyle smallTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

//  UI Text Styles - AppBar & Form Labels
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle boldLabelStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);


//-----------------------------------------------------


//  Tables
const String tableCustomer = 'Customer';
const String tableProductImage = 'ProductImage';
const String tableProductBase = 'ProductBase';
const String tableManufacturer = 'Manufacturer';
const String tableProduct = 'Product';
const String tableEmployee = 'Employee';

const String tableLoginHistory = 'LoginHistory';
const String tablePurchaseItem = 'PurchaseItem';

//  Routes
const String routeLogin = '/';
const String routeCart = '/cart';
const String routeSearchView = '/searchview';
const String routePurchaseView = '/purchaseview';
const String routeAddressPayment = '/address-payment';
const String routeAdminLogin = '/admin-login';
const String routeAdminMobileBlock = '/admin-mobile-block';
const String routeAdminOrderView = '/admin-order-view';
const String routeAdminReturnOrderView = '/admin-return-order-view';
const String routeOrderListView = '/order-list-view';
const String routeReturnListView = '/return-list-view';
const String routeUserProfileEdit = '/user-profile-edit';
const String routeAdminProfileEdit = '/admin-profile-edit';
const String routeTestNavigationPage = '/test-navigation-page';

// Pickup 상태

Map pickupStatus = {
  0 : '제품 준비 중',
  1 : '제품 준비 완료',
  2 : '제품 수령 완료',
  3 : '반품 신청',
  4 : '반품 처리 중',
  5 : '반품 완료'
};

// 회원 상태 
Map loginStatus =  {
  0 : '활동 회원',
  1 : '휴면 회원',
  2 : '탈퇴 회원'
}; 

// 서울 내 자치구 리스트.
const List<String> district = [
  '강남구',
  '강동구',
  '강북구',
  '강서구',
  '관악구',
  '광진구',
  '구로구',
  '금천구',
  '노원구',
  '도봉구',
  '동대문구',
  '동작구',
  '마포구',
  '서대문구',
  '서초구',
  '성동구',
  '성북구',
  '송파구',
  '양천구',
  '영등포구',
  '용산구',
  '은평구',
  '종로구',
  '중구',
  '중랑구',
];
