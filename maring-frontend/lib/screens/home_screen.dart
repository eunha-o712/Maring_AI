import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../state/checkin_providers.dart';
import '../widgets/maring_character.dart';
import 'character_gallery_screen.dart';
import 'checkin_screen.dart';
import 'chat_screen.dart';
import 'diary_screen.dart';
import 'growth_journey_screen.dart';

/// S-04 홈(마링이 방) — 하단 탭(홈·기록·관계·상점)의 컨테이너.
/// 관계·상점은 명세상 P2/P3+ 범위라 이번 MVP 에서는 자리만 두고 "준비 중"으로 안내한다.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTab(),
      const DiaryScreen(),
      const _ComingSoonTab(
        label: '관계·코칭',
        icon: Icons.favorite_outline,
      ),
      const _ComingSoonTab(label: '상점', icon: Icons.storefront_outlined),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '홈'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: '기록'),
          NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: '관계'),
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: '상점'),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;

    final checkins = user == null
        ? null
        : ref.watch(checkinHistoryProvider(user.id)).valueOrNull;
    final now = DateTime.now();
    final today = checkins?.where((c) =>
        c.checkinDate.year == now.year &&
        c.checkinDate.month == now.month &&
        c.checkinDate.day == now.day);
    final mood = MaringMoodPresentation.forEmotion(
      today != null && today.isNotEmpty ? today.first.emotionCard : null,
    );
    final checkinCount = checkins?.length ?? 0;
    final growth = MaringGrowthPresentation.forCheckinCount(checkinCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text('${user?.nickname ?? ''}, 안녕!',
                    style: Theme.of(context).textTheme.headlineSmall)),
            IconButton(
              tooltip: '마링이 표정 모아보기',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CharacterGalleryScreen())),
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
            IconButton(
              tooltip: '마링이 성장 보기',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GrowthJourneyScreen(
                    checkinCount: checkinCount,
                  ),
                ),
              ),
              icon: const Icon(Icons.spa_outlined),
            ),
          ]),
          const SizedBox(height: 4),
          Text('오늘 마링이는 ${growth.label}으로 자라고 있어.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                LayoutBuilder(
                    builder: (context, constraints) => MaringCharacter(
                          growthStage: growth,
                          size: constraints.maxWidth.clamp(160.0, 300.0),
                        )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Chip(label: Text('${growth.label} · 체크인 $checkinCount일')),
                    if (today != null && today.isNotEmpty)
                      Chip(label: Text('오늘의 마음 · ${mood.label}')),
                    Chip(label: Text(user?.mbtiType ?? '')),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 280,
                  child: LinearProgressIndicator(
                    value: growth.progressFor(checkinCount),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  growth.nextRequiredCheckins == null
                      ? '마링이가 가장 빛나는 모습까지 자랐어요.'
                      : '다음 성장까지 ${growth.checkinsUntilNext(checkinCount)}일',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CheckinScreen()),
            ),
            icon: const Icon(Icons.emoji_emotions_outlined),
            label: const Text('오늘 감정 체크인 하기'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('마링이와 이야기하기'),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ComingSoonTab({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MaringCharacter(
            mood: MaringMood.calm,
            size: 160,
            animate: false,
          ),
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('$label 기능은 준비 중이에요'),
        ],
      ),
    );
  }
}
