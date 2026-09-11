import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/maring_character.dart';

/// S-01 온보딩 시작 — 닉네임 입력 + 약관/비의료 고지 동의(FR-A1, FR-A4).
class OnboardingNicknameScreen extends ConsumerStatefulWidget {
  const OnboardingNicknameScreen({super.key});

  @override
  ConsumerState<OnboardingNicknameScreen> createState() =>
      _OnboardingNicknameScreenState();
}

class _OnboardingNicknameScreenState
    extends ConsumerState<OnboardingNicknameScreen> {
  final _nicknameController = TextEditingController();
  bool _agreed = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() => _error = '닉네임을 입력해줘.');
      return;
    }
    if (!_agreed) {
      setState(() => _error = '약관과 비의료 서비스 고지에 동의해야 시작할 수 있어요.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).startOnboarding(nickname);
    } catch (e) {
      if (mounted) setState(() => _error = '시작하지 못했어요. 서버 연결을 확인해줘.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Center(child: MaringCharacter(size: 180)),
              const SizedBox(height: 16),
              Text('안녕, 나는 마링이야',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('너와 같이 자라는 친구가 되고 싶어. 부르고 싶은 이름을 알려줄래?'),
              const SizedBox(height: 24),
              TextField(
                controller: _nicknameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '(필수) 이용약관·개인정보 처리방침에 동의하며, 마링은 진단·치료를 제공하지 않는 비의료 서비스임을 확인했어요.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
