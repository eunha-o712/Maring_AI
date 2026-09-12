import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_models.dart';

/// S-07 안전 안내 오버레이. 위기 감지(safetyTriggered) 시 채팅 화면 위에 띄운다.
Future<void> showSafetyOverlay(BuildContext context, ChatResponse response) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.favorite_rounded,
        size: 40,
        color: Color(0xFFFFB74D),
      ),
      title: const Text('지금 많이 힘드시군요'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('혼자가 아니에요. 아래 전문 상담 자원과 바로 연결할 수 있어요.'),
          const SizedBox(height: 16),
          ...response.crisisResources.map((resource) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.phone_in_talk_outlined),
                  title: Text(
                    resource.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${resource.number} · ${resource.hours}'),
                  trailing: const Icon(Icons.call_outlined),
                  onTap: () => _callResource(context, resource),
                ),
              )),
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

Future<void> _callResource(
  BuildContext context,
  CrisisResource resource,
) async {
  final number = resource.number.replaceAll(RegExp(r'[^0-9+]'), '');
  final messenger = ScaffoldMessenger.maybeOf(context);

  try {
    final launched = await launchUrl(
      Uri(scheme: 'tel', path: number),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      messenger?.showSnackBar(
        SnackBar(content: Text('${resource.number} 번호로 연결할 수 없어요.')),
      );
    }
  } catch (_) {
    messenger?.showSnackBar(
      SnackBar(content: Text('${resource.number} 번호로 연결할 수 없어요.')),
    );
  }
}
