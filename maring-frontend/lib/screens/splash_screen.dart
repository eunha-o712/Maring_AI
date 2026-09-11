import 'package:flutter/material.dart';
import '../widgets/maring_character.dart';

/// S-01 스플래시. 세션 로드가 끝날 때까지 보여준다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MaringCharacter(size: 180, mood: MaringMood.calm),
            const SizedBox(height: 16),
            Text('마링', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
