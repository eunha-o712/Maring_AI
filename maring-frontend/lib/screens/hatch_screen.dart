import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/maring_user.dart';
import '../state/providers.dart';

/// S-03 캐릭터 부화 — 온보딩 완료 연출.
/// 여기서 실제로 MBTI·말투를 서버에 저장한다(사용자가 부화 연출을 보고 나서 확정하는 흐름).
class HatchScreen extends ConsumerStatefulWidget {
  final String mbtiType;
  final SpeechStyle speechStyle;

  const HatchScreen({super.key, required this.mbtiType, required this.speechStyle});

  @override
  ConsumerState<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends ConsumerState<HatchScreen> {
  bool _hatched = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _hatched = true);
    });
  }

  Future<void> _confirmAndEnter() async {
    final notifier = ref.read(sessionProvider.notifier);
    await notifier.chooseMbti(widget.mbtiType);
    await notifier.chooseSpeechStyle(widget.speechStyle);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final nickname = ref.watch(sessionProvider).user?.nickname ?? '친구';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _hatched ? '🐥' : '🥚',
                  key: ValueKey(_hatched),
                  style: const TextStyle(fontSize: 96),
                ),
              ),
              const SizedBox(height: 24),
              if (_hatched) ...[
                Text(
                  '안녕, $nickname! 나는 마링이야.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.mbtiType} 성향이구나. 앞으로 같이 자라면서\n네 이야기를 들려줘.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _confirmAndEnter,
                  child: const Text('마링이와 시작하기'),
                ),
              ] else
                const Text('알이 움직이고 있어요...'),
            ],
          ),
        ),
      ),
    );
  }
}
