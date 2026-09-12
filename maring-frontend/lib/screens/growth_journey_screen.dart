import 'package:flutter/material.dart';

import '../widgets/maring_character.dart';

class GrowthJourneyScreen extends StatelessWidget {
  final int checkinCount;

  const GrowthJourneyScreen({super.key, this.checkinCount = 0});

  @override
  Widget build(BuildContext context) {
    final current = MaringGrowthPresentation.forCheckinCount(checkinCount);
    final next = current.nextRequiredCheckins;

    return Scaffold(
      appBar: AppBar(title: const Text('마링이 성장')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '마음을 나눈 만큼 자라요',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '체크인한 날이 쌓이면 몸집이 커지고 색이 깊어져요.',
                textAlign: TextAlign.center,
              ),
              MaringCharacter(
                growthStage: current,
                size: 300,
              ),
              Text(
                current.label,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                current.colorStory,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: current.progressFor(checkinCount)),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? '모든 성장 단계를 만났어요.'
                    : '다음 성장까지 ${current.checkinsUntilNext(checkinCount)}일',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...MaringGrowthStage.values.map(
                (stage) => _GrowthStageCard(
                  stage: stage,
                  current: stage == current,
                  unlocked: checkinCount >= stage.requiredCheckins,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrowthStageCard extends StatelessWidget {
  final MaringGrowthStage stage;
  final bool current;
  final bool unlocked;

  const _GrowthStageCard({
    required this.stage,
    required this.current,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: current ? stage.glow.withValues(alpha: .45) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: current ? scheme.primary : const Color(0xFFECE6F5),
          width: current ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            MaringCharacter(
              growthStage: stage,
              size: 140,
              animate: false,
              showGlow: false,
              excludeSemantics: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${stage.index + 1}단계 · ${stage.label}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        unlocked ? Icons.lock_open_rounded : Icons.lock_outline,
                        color: unlocked ? scheme.primary : scheme.outline,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(stage.colorStory),
                  const SizedBox(height: 4),
                  Text(
                    stage.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.requiredCheckins == 0
                        ? '처음부터 함께해요'
                        : '체크인 ${stage.requiredCheckins}일에 성장',
                    style: TextStyle(
                      color: unlocked ? scheme.primary : scheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
