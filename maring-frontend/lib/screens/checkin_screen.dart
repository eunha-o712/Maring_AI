import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkin.dart';
import '../state/providers.dart';
import 'chat_screen.dart';

/// S-05 감정 체크인 — 대화 진입점(FR-B1). 선택 후 상담 대화로 이어진다.
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  EmotionCard? _selected;
  double _intensity = 3;
  bool _submitting = false;

  Future<void> _submitAndChat() async {
    final selected = _selected;
    final user = ref.read(sessionProvider).user;
    if (selected == null || user == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(maringRepositoryProvider)
          .submitCheckin(user.id, selected.key, _intensity.round());
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('체크인 저장에 실패했어요. ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 감정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('지금 마음에 가장 가까운 감정을 골라줘.'),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: EmotionCard.all.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final card = EmotionCard.all[index];
                    final selected = card.key == _selected?.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = card),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(card.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(card.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text('강도: ${_intensity.round()} / 5'),
              Slider(
                value: _intensity,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _intensity = v),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selected == null || _submitting ? null : _submitAndChat,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('마링이에게 이야기하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
