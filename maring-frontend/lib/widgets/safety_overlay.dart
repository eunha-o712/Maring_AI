import 'package:flutter/material.dart';

import '../models/chat_models.dart';

/// S-07 안전 안내 오버레이. 위기 감지(safetyTriggered) 시 채팅 화면 위에 띄운다.
/// 명세상 긴급 연락처는 탭하면 바로 전화 연결이 되어야 하지만(FR-G2),
/// 이번 MVP 에는 url_launcher 등 외부 의존성을 추가하지 않아 번호 표시까지만 구현했다.
Future<void> showSafetyOverlay(BuildContext context, ChatResponse response) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Text('💛', style: TextStyle(fontSize: 40)),
      title: const Text('지금 많이 힘드시군요'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('혼자가 아니에요. 아래 전문 상담 자원과 바로 연결할 수 있어요.'),
          const SizedBox(height: 16),
          ...response.crisisResources.map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${r.name}  ${r.number}  (${r.hours})',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('곁에 있어줘서 고마워요'),
        ),
      ],
    ),
  );
}
