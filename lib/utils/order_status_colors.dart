// Flutter imports
import 'package:flutter/material.dart';

// Local imports - Core
import 'package:shoes_store_basic_app/config.dart' as config;

/// 주문 상태별 색상 유틸리티
class OrderStatusColors {
  /// 상태 문자열에 따른 색상 반환
  static Color getStatusColor(String status) {
    // 반품 가능/불가 상태 처리
    if (status == '반품 가능') {
      return Colors.green;
    } else if (status == '반품 불가') {
      return Colors.grey;
    }
    
    for (var entry in config.pickupStatus.entries) {
      if (status == entry.value) {
        return _getColorByStatusNumber(entry.key);
      }
    }
    
    final lowerStatus = status.toLowerCase();
    
    if (lowerStatus.contains('반품 완료') || lowerStatus.contains('return done')) {
      return _getColorByStatusNumber(5);
    } else if (lowerStatus.contains('반품 처리') || lowerStatus.contains('return processing')) {
      return _getColorByStatusNumber(4);
    } else if (lowerStatus.contains('반품 신청') || lowerStatus.contains('return request')) {
      return _getColorByStatusNumber(3);
    } else if (lowerStatus.contains('수령 완료') || lowerStatus.contains('complete')) {
      return _getColorByStatusNumber(2);
    } else if (lowerStatus.contains('준비 완료') || lowerStatus.contains('ready') || lowerStatus.contains('onway')) {
      return _getColorByStatusNumber(1);
    } else if (lowerStatus.contains('준비 중') || lowerStatus.contains('대기')) {
      return _getColorByStatusNumber(0);
    }
    
    return Colors.grey;
  }

  /// 상태 번호에 따른 색상 반환
  static Color _getColorByStatusNumber(int statusNumber) {
    switch (statusNumber) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}

