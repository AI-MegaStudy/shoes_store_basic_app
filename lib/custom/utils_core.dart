// 커스텀 유틸리티 라이브러리 (핵심 유틸리티만)
//
// 외부 패키지 의존성이 없는 순수 Dart 유틸리티만 export합니다.
// 네트워크나 스토리지 유틸리티가 필요 없는 경우 이 파일을 사용하세요.
//
// 사용 예시:
// ```dart
// import 'package:custom_test_app/custom/utils_core.dart';
//
// CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd');
// CustomCollectionUtil.unique([1, 2, 2, 3]);
// ```
library;

// ============================================
// 공용 유틸리티
// ============================================

// 공용 유틸리티 (날짜, 문자열, 검증, 포맷팅, 숫자 등)
export 'custom_common_util.dart';

// ============================================
// 추가 유틸리티 (의존성 없는 순수 Dart만)
// ============================================

// 컬렉션 유틸리티 (순수 Dart, 의존성 없음)
export 'util/collection/custom_collection_util.dart';

// JSON 변환 유틸리티 (순수 Dart, 의존성 없음)
export 'util/json/custom_json_util.dart';

// 타이머 유틸리티 (순수 Dart, 의존성 없음)
export 'util/timer/custom_timer_util.dart';

// 주소 파싱 유틸리티 (순수 Dart, 의존성 없음)
export 'util/address/custom_address_util.dart';

// 네비게이션 유틸리티 (Flutter Navigator 래핑)
export 'util/navigation/custom_navigation_util.dart';

// 로그 유틸리티는 lib/utils/app_logger.dart를 사용하도록 변경됨
// custom 폴더 내부에서만 필요할 경우 직접 import 가능
// export 'util/log/custom_log_util.dart';
