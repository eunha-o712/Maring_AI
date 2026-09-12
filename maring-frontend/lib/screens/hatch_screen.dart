import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/maring_user.dart';
import '../state/providers.dart';
import '../widgets/maring_character.dart';

/// S-03 캐릭터 부화 — 온보딩 완료 연출.
/// 여기서 실제로 MBTI·말투를 서버에 저장한다(사용자가 부화 연출을 보고 나서 확정하는 흐름).
class HatchScreen extends ConsumerStatefulWidget {
  final String mbtiType;
  final SpeechStyle speechStyle;

  const HatchScreen(
      {super.key, required this.mbtiType, required this.speechStyle});

  @override
  ConsumerState<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends ConsumerState<HatchScreen> {
  bool _hatched = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _hatched = true);
    });
  }

  Future<void> _confirmAndEnter() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .completeOnboarding(widget.mbtiType, widget.speechStyle);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = '연결이 잠시 끊겼어요. 다시 시작해볼까요?');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nickname = ref.watch(sessionProvider).user?.nickname ?? '친구';
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _hatched
                    ? const MaringCharacter(
                        key: ValueKey('hatched'),
                        growthStage: MaringGrowthStage.seed,
                        size: 250)
                    : Container(
                        key: const ValueKey('egg'),
                        width: 180,
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(110),
                          gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFF5FA), Color(0xFFD6C5F8)]),
                          boxShadow: const [
                            BoxShadow(color: Color(0x337C6AE0), blurRadius: 32)
                          ],
                        ),
                        child: const Icon(Icons.favorite_outline,
                            color: Colors.white, size: 64),
                      ),
              ),
              const SizedBox(height: 24),
              if (_hatched) ...[
                Text(
                  '안녕, $nickname! 작은 마링이가 태어났어.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.mbtiType} 성향이구나. 마음을 나누는 날마다\n몸집과 색이 조금씩 자랄 거야.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!)),
                FilledButton(
                  onPressed: _saving ? null : _confirmAndEnter,
                  child: Text(_saving ? '마음을 연결하고 있어요…' : '마링이와 시작하기'),
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
