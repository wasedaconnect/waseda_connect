import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateTimeTableProvider = StateProvider<bool>((ref) {
  return false; // 初期値はfalse
});

final notificationProvider = StateProvider<String>((ref) {
  return '';
});
