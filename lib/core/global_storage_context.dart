import 'package:flutter/material.dart';
import 'global_storage.dart';

/// BuildContext 확장 – context.globalStorage로 전역 저장소 접근
extension GlobalStorageContext on BuildContext {
  GlobalStorage get globalStorage => GlobalStorage.instance;
}

