// 커스텀 위젯 및 유틸리티 라이브러리 (기본 버전)
//
// 외부 패키지 의존성 없는 위젯과 핵심 유틸리티만 export합니다.
// GetX처럼 하나의 import로 기본 기능을 사용할 수 있습니다.
//
// 주의: 이 파일은 storage/network를 export하지 않지만,
// storage/network 폴더가 존재하면 pubspec.yaml에 의존성을 추가해야 합니다.
// (export되지 않아도 파일이 존재하면 컴파일 시 의존성 체크를 합니다)
//
// StorageUtil이나 NetworkUtil이 필요한 경우 직접 import하거나 custom_full.dart를 사용하세요.
// 사용하지 않는 경우 storage/network 폴더를 삭제하거나 pubspec.yaml에 의존성을 추가하세요.
//
// 사용 예시:
// ```dart
// import 'package:custom_test_app/custom/custom.dart';
//
// // 위젯 사용
// CustomText("안녕하세요")
// CustomButton(btnText: "확인", onCallBack: () {})
//
// // 핵심 유틸리티 사용 (외부 패키지 의존성 없음)
// CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd');
// CustomCollectionUtil.unique([1, 2, 2, 3]);
// ```
//
// 선택적 import:
// - 위젯만 필요한 경우: `import 'package:custom_test_app/custom/widgets.dart';`
// - 핵심 유틸리티만: `import 'package:custom_test_app/custom/utils_core.dart';`
// - 전체 유틸리티 (외부 패키지 의존성 필요): `import 'package:custom_test_app/custom/custom_full.dart';`
// - 스토리지 유틸리티만: `import 'package:custom_test_app/custom/external_util/storage/custom_storage_util.dart';`
// - 네트워크 유틸리티만: `import 'package:custom_test_app/custom/external_util/network/custom_network_util.dart';`
library;

// 위젯 export
export 'widgets.dart';

// 핵심 유틸리티 export (외부 패키지 의존성 없음)
export 'utils_core.dart';
