import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/checkin.dart';
import '../state/providers.dart';
import '../state/checkin_providers.dart';
import 'chat_screen.dart';
import '../widgets/maring_character.dart';

/// S-08 마음 기록 — 감정 캘린더(이번 달) + 대화 이어가기.
///
/// 명세의 "자동 감정 일기화(FR-C1)"는 LLM 요약 파이프라인이 필요해 이번 MVP 범위에서는
/// 제외했다. 대신 실제 저장된 감정 체크인 데이터를 달력으로 보여준다.
class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    if (user == null) return const SizedBox.shrink();

    final historyAsync = ref.watch(checkinHistoryProvider(user.id));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('마음 기록', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(DateFormat('yyyy년 M월').format(DateTime.now())),
          const SizedBox(height: 16),
          Expanded(
            child: historyAsync.when(
              data: (checkins) => _MonthCalendar(checkins: checkins),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('기록을 불러오지 못했어요.\n$e')),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('마링이와 대화 이어가기'),
          ),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final List<EmotionCheckin> checkins;

  const _MonthCalendar({required this.checkins});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7; // 일요일 시작

    final byDate = <int, EmotionCheckin>{
      for (final c in checkins)
        if (c.checkinDate.year == now.year && c.checkinDate.month == now.month)
          c.checkinDate.day: c,
    };

    return Column(
      children: [
        const Row(
          children: [
            _WeekdayLabel('일'),
            _WeekdayLabel('월'),
            _WeekdayLabel('화'),
            _WeekdayLabel('수'),
            _WeekdayLabel('목'),
            _WeekdayLabel('금'),
            _WeekdayLabel('토'),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final checkin = byDate[day];
              final isToday = day == now.day;
              final card = checkin == null
                  ? null
                  : EmotionCard.all.cast<EmotionCard?>().firstWhere(
                        (emotion) => emotion?.key == checkin.emotionCard,
                        orElse: () => null,
                      );
              final openDetail = checkin == null
                  ? null
                  : () => _showDetail(context, day, checkin);

              return Semantics(
                button: checkin != null,
                label: checkin == null
                    ? '$day일'
                    : '$day일 ${card?.label ?? '감정 기록'}, 강도 ${checkin.intensity}',
                onTap: openDetail,
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: openDetail,
                    customBorder: const CircleBorder(),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day', style: const TextStyle(fontSize: 11)),
                          if (checkin != null)
                            MaringCharacter(
                              mood: MaringMoodPresentation.forEmotion(
                                checkin.emotionCard,
                              ),
                              size: 30,
                              animate: false,
                              showGlow: false,
                              excludeSemantics: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, int day, EmotionCheckin checkin) {
    final card = EmotionCard.all.firstWhere(
      (e) => e.key == checkin.emotionCard,
      orElse: () => const EmotionCard('', '알 수 없음'),
    );
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${DateTime.now().month}월 $day일',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MaringCharacter(
                mood: MaringMoodPresentation.forEmotion(checkin.emotionCard),
                size: 160),
            Text('${card.label} · 강도 ${checkin.intensity}/5',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey))),
    );
  }
}
