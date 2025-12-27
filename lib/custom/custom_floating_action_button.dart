import 'package:flutter/material.dart';

// FloatingActionButton 위젯
//
// 사용 예시:
// ```dart
// CustomFloatingActionButton(onPressed: () {}, icon: Icons.add)
// CustomFloatingActionButton.extended(onPressed: () {}, label: "추가", icon: Icons.add)
// ```
class CustomFloatingActionButton extends StatelessWidget {
  // 버튼 클릭 시 실행될 콜백 (필수)
  final VoidCallback? onPressed;

  // 버튼에 표시할 아이콘 (일반/작은 크기일 때 필수)
  final IconData? icon;

  // 버튼에 표시할 라벨 (확장형일 때 필수)
  final String? label;

  // 버튼 배경색
  final Color? backgroundColor;

  // 버튼 전경색/아이콘 색상
  final Color? foregroundColor;

  // 툴팁 메시지
  final String? tooltip;

  // 버튼 타입
  final FloatingActionButtonType type;

  // 버튼 위치 (기본값: FloatingActionButtonLocation.endFloat)
  final FloatingActionButtonLocation? location;

  // 원형 FloatingActionButton 생성자
  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.location,
  }) : type = FloatingActionButtonType.regular,
       label = null,
       assert(icon != null, 'icon은 필수입니다.');

  // 작은 크기의 FloatingActionButton 생성자
  const CustomFloatingActionButton.small({
    super.key,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.location,
  }) : type = FloatingActionButtonType.small,
       label = null,
       assert(icon != null, 'icon은 필수입니다.');

  // 확장형 FloatingActionButton 생성자
  const CustomFloatingActionButton.extended({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.location,
  }) : type = FloatingActionButtonType.extended;

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case FloatingActionButtonType.regular:
        button = FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          tooltip: tooltip,
          elevation: 12,
          highlightElevation: 16,
          shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
          child: icon != null ? Icon(icon) : null,
        );
        break;
      case FloatingActionButtonType.small:
        button = FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          tooltip: tooltip,
          elevation: 12,
          highlightElevation: 16,
          shape: CircleBorder(
            side: BorderSide(color: Colors.white, width: 2.5),
          ),
          child: icon != null ? Icon(icon) : null,
        );
        break;
      case FloatingActionButtonType.extended:
        button = FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          tooltip: tooltip,
          elevation: 12,
          highlightElevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white, width: 3),
          ),
          label: Text(label ?? ''),
          icon: icon != null ? Icon(icon) : null,
        );
        break;
    }

    return button;
  }
}

// FloatingActionButton 타입 enum
enum FloatingActionButtonType {
  // 일반 크기의 FloatingActionButton
  regular,

  // 작은 크기의 FloatingActionButton
  small,

  // 확장형 FloatingActionButton (라벨 포함)
  extended,
}
