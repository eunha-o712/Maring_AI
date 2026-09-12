import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkin.dart';
import '../state/providers.dart';
import '../state/checkin_providers.dart';
import '../widgets/maring_character.dart';
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
        ref.invalidate(checkinHistoryProvider(user.id));
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
                child: ListView(children: [
                  Center(
                      child: MaringCharacter(
                          mood:
                              MaringMoodPresentation.forEmotion(_selected?.key),
                          size: 180)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: EmotionCard.all.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 92,
                    ),
                    itemBuilder: (context, index) {
                      final card = EmotionCard.all[index];
                      final selected = card.key == _selected?.key;
                      return Semantics(
                        selected: selected,
                        button: true,
                        label: card.label,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _submitting
                              ? null
                              : () => setState(() => _selected = card),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: MaringCharacter(
                                        mood: MaringMoodPresentation.forEmotion(
                                            card.key),
                                        size: 64,
                                        animate: false,
                                        showGlow: false,
                                        excludeSemantics: true)),
                                const SizedBox(height: 4),
                                Text(card.label,
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Text('강도: ${_intensity.round()} / 5'),
              Slider(
                value: _intensity,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged:
                    _submitting ? null : (v) => setState(() => _intensity = v),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed:
                    _selected == null || _submitting ? null : _submitAndChat,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('마링이에게 이야기하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
