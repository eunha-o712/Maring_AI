import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../core/maring_repository.dart';
import '../models/maring_user.dart';

const _prefsUserIdKey = 'maring.userId';
const _prefsConversationIdKey = 'maring.conversationId';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final maringRepositoryProvider = Provider<MaringRepository>(
  (ref) => MaringRepository(ref.watch(apiClientProvider)),
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// 앱의 로그인/온보딩 세션 상태.
class SessionState {
  final bool loading;
  final MaringUser? user;
  final String? conversationId;
  final String? error;

  const SessionState({this.loading = true, this.user, this.conversationId, this.error});

  bool get isOnboarded => user != null && user!.hasMbti;

  SessionState copyWith({
    bool? loading,
    MaringUser? user,
    String? conversationId,
    String? error,
  }) {
    return SessionState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      conversationId: conversationId ?? this.conversationId,
      error: error,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final MaringRepository _repo;
  final Ref _ref;

  SessionNotifier(this._repo, this._ref) : super(const SessionState()) {
    _restore();
  }

  Future<SharedPreferences> get _prefs => _ref.read(sharedPreferencesProvider.future);

  Future<void> _restore() async {
    final prefs = await _prefs;
    final userId = prefs.getString(_prefsUserIdKey);
    final conversationId = prefs.getString(_prefsConversationIdKey);
    if (userId == null) {
      state = state.copyWith(loading: false);
      return;
    }
    try {
      final user = await _repo.getUser(userId);
      state = state.copyWith(loading: false, user: user, conversationId: conversationId);
    } catch (_) {
      // 저장된 사용자 ID가 더 이상 유효하지 않으면(예: 서버 DB 초기화) 세션을 비운다.
      await prefs.remove(_prefsUserIdKey);
      await prefs.remove(_prefsConversationIdKey);
      state = state.copyWith(loading: false);
    }
  }

  Future<void> startOnboarding(String nickname) async {
    final user = await _repo.createUser(nickname);
    final prefs = await _prefs;
    await prefs.setString(_prefsUserIdKey, user.id);
    state = state.copyWith(user: user, loading: false);
  }

  Future<void> chooseMbti(String mbtiType) async {
    final current = state.user;
    if (current == null) return;
    final updated = await _repo.setMbti(current.id, mbtiType);
    state = state.copyWith(user: updated);
  }

  Future<void> chooseSpeechStyle(SpeechStyle style) async {
    final current = state.user;
    if (current == null) return;
    final updated = await _repo.setSpeechStyle(current.id, style);
    state = state.copyWith(user: updated);
  }

  Future<String> ensureConversation() async {
    if (state.conversationId != null) return state.conversationId!;
    final user = state.user;
    if (user == null) throw StateError('사용자 세션이 없습니다.');
    final conversationId = await _repo.startConversation(user.id);
    final prefs = await _prefs;
    await prefs.setString(_prefsConversationIdKey, conversationId);
    state = state.copyWith(conversationId: conversationId);
    return conversationId;
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(maringRepositoryProvider), ref);
});
