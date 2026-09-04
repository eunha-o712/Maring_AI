import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'checkin_screen.dart';
import 'chat_screen.dart';
import 'diary_screen.dart';

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
      const _ComingSoonTab(label: '관계·코칭', emoji: '🤝'),
      const _ComingSoonTab(label: '상점', emoji: '🛍️'),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: '기록'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: '관계'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: '상점'),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${user?.nickname ?? ''}, 안녕!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('오늘 마링이는 너를 기다리고 있어.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text('🐥', style: TextStyle(fontSize: 120)),
                const SizedBox(height: 8),
                Chip(label: Text(user?.mbtiType ?? '')),
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
  final String emoji;

  const _ComingSoonTab({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('$label 기능은 준비 중이에요'),
        ],
      ),
    );
  }
}
