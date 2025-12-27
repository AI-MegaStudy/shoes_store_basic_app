import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 관리자 화면 태블릿 관련 유틸리티 함수들
/// 관리자 화면에서 공통으로 사용하는 태블릿 관련 기능을 제공합니다.

/// 태블릿 여부를 확인하는 함수
/// 화면의 가장 짧은 변의 길이와 플랫폼을 기준으로 태블릿 여부를 판단합니다.
/// 
/// 아이패드의 창 모드(Stage Manager/Split View)를 고려하여,
/// iOS 디바이스인 경우 더 낮은 기준을 적용합니다.
/// 
/// [context] BuildContext
/// 반환값: 태블릿이면 true, 모바일이면 false
bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final shortestSide = size.shortestSide;
  
  // iOS/iPad인 경우 창 모드를 고려하여 더 낮은 기준 적용
  // 아이패드 미니나 창 모드에서도 태블릿으로 인식되도록 함
  if (Platform.isIOS) {
    // iPad는 일반적으로 600px 이상이지만,
    // 창 모드(Stage Manager/Split View)에서는 화면 크기가 작게 측정될 수 있음
    // 따라서 iOS인 경우 더 낮은 기준(500px)을 적용하여 아이패드로 인식
    return shortestSide >= 500;
  }
  
  // Android의 경우 기존 기준 유지
  // 600px 이상이면 태블릿으로 간주
  return shortestSide >= 600;
}

/// 태블릿에서 가로 모드로 고정하는 함수
/// 관리자 화면에서 태블릿일 때 가로 모드로 강제 고정합니다.
/// initState에서 호출하여 사용합니다.
void lockTabletLandscape(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (isTablet(context)) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  });
}

/// 모든 화면 방향을 허용하도록 복구하는 함수
/// dispose에서 호출하여 사용합니다.
void unlockAllOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

