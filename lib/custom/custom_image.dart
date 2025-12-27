import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // PaletteContext extension 사용

// 테마 색상 지원 (선택적)
// 다른 앱에서도 사용 가능하도록 try-catch로 처리
Color? _getThemeTextSecondaryColor(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey[300];
  }
}

Color? _getThemeTextSecondaryColorDark(BuildContext context) {
  try {
    return context.palette.textSecondary;
  } catch (e) {
    // PaletteContext가 없는 경우 Material Theme 기본값 사용
    return Colors.grey[600];
  }
}

// Image.asset, Image.file, 또는 Image.memory 위젯
//
// 사용 예시:
// ```dart
// // Asset 이미지 사용
// CustomImage("assets/images/logo.png")
// CustomImage("assets/images/logo.png", width: 100, height: 100, fit: BoxFit.cover)
//
// // File 이미지 사용
// CustomImage.file(File("/path/to/image.png"))
// CustomImage.file(File("/path/to/image.png"), width: 100, height: 100)
//
// // Memory 이미지 사용
// CustomImage.memory(Uint8List.fromList([...]))
// CustomImage.memory(imageBytes, width: 100, height: 100)
// ```
class CustomImage extends StatelessWidget {
  // 이미지 경로 (asset 이미지 사용 시)
  final String? path;

  // 이미지 파일 (file 이미지 사용 시)
  final File? file;

  // 이미지 바이트 데이터 (memory 이미지 사용 시)
  final Uint8List? bytes;

  // 이미지 너비
  final double? width;

  // 이미지 높이
  final double? height;

  // 이미지 크기 조정 방식 (기본값: BoxFit.contain)
  final BoxFit? fit;

  // 이미지가 로드되지 않을 때 표시할 위젯
  final Widget? errorWidget;

  // 이미지가 로드 중일 때 표시할 위젯
  final Widget? loadingWidget;

  // 이미지 색상 필터
  final Color? color;

  // 이미지 색상 블렌드 모드
  final BlendMode? colorBlendMode;

  // 이미지 반복 방식
  final ImageRepeat? repeat;

  // 이미지 정렬 방식
  final AlignmentGeometry? alignment;

  // Asset 이미지를 위한 생성자
  const CustomImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
    this.color,
    this.colorBlendMode,
    this.repeat,
    this.alignment,
  }) : file = null,
       bytes = null,
       assert(path != null, 'path는 필수입니다.');

  // File 이미지를 위한 생성자
  const CustomImage.file(
    this.file, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
    this.color,
    this.colorBlendMode,
    this.repeat,
    this.alignment,
  }) : path = null,
       bytes = null,
       assert(file != null, 'file은 필수입니다.');

  // Memory 이미지를 위한 생성자
  const CustomImage.memory(
    this.bytes, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
    this.color,
    this.colorBlendMode,
    this.repeat,
    this.alignment,
  }) : path = null,
       file = null,
       assert(bytes != null, 'bytes는 필수입니다.');

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: _getThemeTextSecondaryColor(context) ?? Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              color:
                  _getThemeTextSecondaryColorDark(context) ?? Colors.grey[600],
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.5 : height! * 0.5)
                  : 48,
            ),
          );
    }

    Widget frameBuilder(
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronouslyLoaded,
    ) {
      if (wasSynchronouslyLoaded) {
        return child;
      }
      if (frame == null && loadingWidget != null) {
        return loadingWidget!;
      }
      return child;
    }

    Widget image;
    if (bytes != null) {
      // Memory 이미지 사용
      image = Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
        colorBlendMode: colorBlendMode,
        repeat: repeat ?? ImageRepeat.noRepeat,
        alignment: alignment ?? Alignment.center,
        errorBuilder: errorBuilder,
        frameBuilder: frameBuilder,
      );
    } else if (file != null) {
      // File 이미지 사용
      image = Image.file(
        file!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
        colorBlendMode: colorBlendMode,
        repeat: repeat ?? ImageRepeat.noRepeat,
        alignment: alignment ?? Alignment.center,
        errorBuilder: errorBuilder,
        frameBuilder: frameBuilder,
      );
    } else {
      // Asset 이미지 사용
      image = Image.asset(
        path!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
        colorBlendMode: colorBlendMode,
        repeat: repeat ?? ImageRepeat.noRepeat,
        alignment: alignment ?? Alignment.center,
        errorBuilder: errorBuilder,
        frameBuilder: frameBuilder,
      );
    }

    // width나 height가 지정된 경우 SizedBox로 감싸기
    if (width != null || height != null) {
      image = SizedBox(width: width, height: height, child: image);
    }

    return image;
  }
}
