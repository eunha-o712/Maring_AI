import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_models.dart';
import '../state/providers.dart';
import '../state/chat_providers.dart';
import '../widgets/safety_overlay.dart';
import '../widgets/maring_character.dart';

/// S-06 상담 대화 (핵심). 대화 세션을 보장한 뒤 채팅 UI 를 그린다.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final Future<String> _conversationIdFuture;

  @override
  void initState() {
    super.initState();
    _conversationIdFuture =
        ref.read(sessionProvider.notifier).ensureConversation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마링이와 대화')),
      body: FutureBuilder<String>(
        future: _conversationIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text('대화를 시작하지 못했어요.\n${snapshot.error ?? ''}'));
          }
          return _ChatBody(conversationId: snapshot.data!);
        },
      ),
    );
  }
}

class _ChatBody extends ConsumerStatefulWidget {
  final String conversationId;

  const _ChatBody({required this.conversationId});

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    if (ref.read(chatProvider(widget.conversationId)).sending ||
        ref.read(chatProvider(widget.conversationId)).loadingHistory) {
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await ref.read(chatProvider(widget.conversationId).notifier).send(text);
    if (mounted) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.conversationId));

    ref.listen(chatProvider(widget.conversationId), (previous, next) {
      if (previous?.lastSafety != next.lastSafety && next.lastSafety != null) {
        showSafetyOverlay(context, next.lastSafety!).then((_) {
          if (mounted) {
            ref
                .read(chatProvider(widget.conversationId).notifier)
                .dismissSafetyOverlay();
          }
        });
      }
      if (previous?.messages.length != next.messages.length) _scrollToBottom();
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            MaringCharacter(
                mood: chatState.sending
                    ? MaringMood.thinking
                    : MaringMood.empathy,
                size: 88),
            const SizedBox(width: 12),
            Expanded(
                child: Text(chatState.sending
                    ? '네 이야기를 곰곰이 듣고 있어…'
                    : '천천히 이야기해도 괜찮아.')),
          ]),
        ),
        Expanded(
          child: chatState.loadingHistory
              ? const Center(child: CircularProgressIndicator())
              : chatState.messages.isEmpty
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('오늘 어떤 하루를 보냈어?\n떠오르는 한마디부터 들려줘.',
                              textAlign: TextAlign.center)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) =>
                          _MessageBubble(message: chatState.messages[index]),
                    ),
        ),
        if (chatState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(chatState.error!,
                style: const TextStyle(color: Colors.red)),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '지금 마음을 편하게 이야기해줘',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: chatState.sending || chatState.loadingHistory
                      ? null
                      : _send,
                  icon: chatState.sending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
              color: isUser ? colorScheme.onPrimary : colorScheme.onSurface),
        ),
      ),
    );
  }
}
