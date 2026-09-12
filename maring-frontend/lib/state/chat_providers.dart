import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_models.dart';
import 'providers.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool loadingHistory;
  final bool sending;
  final ChatResponse? lastSafety;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.loadingHistory = true,
    this.sending = false,
    this.lastSafety,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loadingHistory,
    bool? sending,
    ChatResponse? lastSafety,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loadingHistory: loadingHistory ?? this.loadingHistory,
      sending: sending ?? this.sending,
      lastSafety: lastSafety,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final String conversationId;

  ChatNotifier(this._ref, this.conversationId) : super(const ChatState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _ref
          .read(maringRepositoryProvider)
          .conversationHistory(conversationId);
      if (!mounted) return;
      state = state.copyWith(messages: history, loadingHistory: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(loadingHistory: false, error: '대화 기록을 불러오지 못했어요.');
    }
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.sending || state.loadingHistory) return;
    final userMessage = ChatMessage(role: ChatRole.user, content: text);
    state = state.copyWith(
        messages: [...state.messages, userMessage], sending: true, error: null);

    try {
      final response = await _ref
          .read(maringRepositoryProvider)
          .sendMessage(conversationId, text);
      if (!mounted) return;
      final assistantMessage = ChatMessage(
        role: ChatRole.assistant,
        content: response.reply,
        riskLevel: response.riskLevel,
      );
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        sending: false,
        lastSafety: response.safetyTriggered ? response : null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
          sending: false, error: '마링이가 응답하지 못했어요. 잠시 후 다시 시도해줘.');
    }
  }

  void dismissSafetyOverlay() {
    state = state.copyWith(lastSafety: null);
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
        (ref, conversationId) {
  return ChatNotifier(ref, conversationId);
});
