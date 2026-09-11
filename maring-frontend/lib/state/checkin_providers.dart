import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkin.dart';
import 'providers.dart';

/// 사용자의 감정 체크인 히스토리 (S-08 캘린더용).
final checkinHistoryProvider = FutureProvider.autoDispose
    .family<List<EmotionCheckin>, String>((ref, userId) {
  return ref.read(maringRepositoryProvider).checkinHistory(userId);
});
