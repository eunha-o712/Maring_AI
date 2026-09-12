import 'package:flutter/material.dart';

import '../widgets/maring_character.dart';
import 'growth_journey_screen.dart';

/// A real app surface for inspecting every bundled expression and its animation.
class CharacterGalleryScreen extends StatefulWidget {
  const CharacterGalleryScreen({super.key});

  @override
  State<CharacterGalleryScreen> createState() => _CharacterGalleryScreenState();
}

class _CharacterGalleryScreenState extends State<CharacterGalleryScreen> {
  MaringMood _mood = MaringMood.neutral;
  bool _animate = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('마링이의 마음')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('어떤 마음이든, 함께',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('표정을 눌러 마링이를 만나봐요.', textAlign: TextAlign.center),
                Center(
                    child: LayoutBuilder(
                        builder: (context, constraints) => MaringCharacter(
                              mood: _mood,
                              size: constraints.maxWidth.clamp(180.0, 320.0),
                              animate: _animate,
                            ))),
                Text(_mood.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
                SwitchListTile(
                  title: const Text('살랑살랑 움직이기'),
                  value: _animate,
                  onChanged: (value) => setState(() => _animate = value),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GrowthJourneyScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.spa_outlined),
                  label: const Text('작은 마링이부터 성장 단계 보기'),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: MaringMood.values
                      .map((mood) => SizedBox(
                            width: 94,
                            child: Semantics(
                              selected: mood == _mood,
                              button: true,
                              label: mood.label,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => setState(() => _mood = mood),
                                child: Ink(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: mood == _mood
                                        ? mood.glow
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: mood == _mood
                                            ? const Color(0xFF7C6AE0)
                                            : const Color(0xFFECE6F5)),
                                  ),
                                  child: Column(children: [
                                    MaringCharacter(
                                        mood: mood,
                                        size: 78,
                                        animate: false,
                                        showGlow: false,
                                        excludeSemantics: true),
                                    Text(mood.label),
                                  ]),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
}
