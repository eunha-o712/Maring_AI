import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/maring_user.dart';
import 'hatch_screen.dart';

const _mbtiTypes = [
  'INTJ',
  'INTP',
  'ENTJ',
  'ENTP',
  'INFJ',
  'INFP',
  'ENFJ',
  'ENFP',
  'ISTJ',
  'ISFJ',
  'ESTJ',
  'ESFJ',
  'ISTP',
  'ISFP',
  'ESTP',
  'ESFP',
];

/// S-02 간이 MBTI 설정.
///
/// 명세(FR-A2)의 12~16문항 진단 퀴즈는 아직 콘텐츠가 준비되지 않아,
/// MVP 에서는 "유형 직접 입력" 경로만 우선 구현했다. 진단 퀴즈는 후속 작업.
class OnboardingMbtiScreen extends ConsumerStatefulWidget {
  const OnboardingMbtiScreen({super.key});

  @override
  ConsumerState<OnboardingMbtiScreen> createState() =>
      _OnboardingMbtiScreenState();
}

class _OnboardingMbtiScreenState extends ConsumerState<OnboardingMbtiScreen> {
  String? _selectedType;
  SpeechStyle _speechStyle = SpeechStyle.banmal;

  void _next() {
    if (_selectedType == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            HatchScreen(mbtiType: _selectedType!, speechStyle: _speechStyle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 MBTI 유형')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('네 MBTI 유형을 알려줘. 그에 맞는 톤으로 이야기할게!'),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _mbtiTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final type = _mbtiTypes[index];
                    final selected = type == _selectedType;
                    return ChoiceChip(
                      label: Text(type),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedType = type),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text('말투 선택', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<SpeechStyle>(
                segments: const [
                  ButtonSegment(value: SpeechStyle.banmal, label: Text('반말')),
                  ButtonSegment(
                      value: SpeechStyle.jondaenmal, label: Text('존댓말')),
                ],
                selected: {_speechStyle},
                onSelectionChanged: (s) =>
                    setState(() => _speechStyle = s.first),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _selectedType == null ? null : _next,
                child: const Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
