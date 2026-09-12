import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_nickname_screen.dart';
import 'screens/onboarding_mbti_screen.dart';
import 'screens/home_screen.dart';
import 'screens/character_gallery_screen.dart';

void main() {
  runApp(const ProviderScope(child: MaringApp()));
}

/// 마링 브랜드 컬러 — 부드러운 라벤더 톤.
const maringPrimary = Color(0xFF7C6AE0);

class MaringApp extends StatelessWidget {
  const MaringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마링 Maring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: maringPrimary),
        scaffoldBackgroundColor: const Color(0xFFFAFAFF),
      ),
      home: const bool.fromEnvironment('MARING_CHARACTER_PREVIEW')
          ? const CharacterGalleryScreen()
          : const SessionGate(),
    );
  }
}

/// 세션 상태(로딩/미가입/온보딩 필요/완료)에 따라 첫 화면을 분기한다.
class SessionGate extends ConsumerWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session.loading) {
      return const SplashScreen();
    }
    if (session.error != null && session.user == null) {
      return Scaffold(
          body: Center(
              child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(session.error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: () =>
                  ref.read(sessionProvider.notifier).retryRestore(),
              child: const Text('다시 연결하기')),
        ]),
      )));
    }
    if (session.user == null) {
      return const OnboardingNicknameScreen();
    }
    if (!session.user!.hasMbti) {
      return const OnboardingMbtiScreen();
    }
    return const HomeScreen();
  }
}
