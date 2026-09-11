class CrisisResource {
  final String name;
  final String number;
  final String hours;

  const CrisisResource(
      {required this.name, required this.number, required this.hours});

  factory CrisisResource.fromJson(Map<String, dynamic> json) => CrisisResource(
        name: json['name'] as String? ?? '',
        number: json['number'] as String? ?? '',
        hours: json['hours'] as String? ?? '',
      );
}

enum ChatRole { user, assistant }

class ChatMessage {
  final String? id;
  final ChatRole role;
  final String content;
  final String riskLevel;
  final DateTime? createdAt;

  const ChatMessage({
    required this.role,
    required this.content,
    this.id,
    this.riskLevel = 'NONE',
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String?,
        role: (json['role'] as String?) == 'USER'
            ? ChatRole.user
            : ChatRole.assistant,
        content: json['content'] as String? ?? '',
        riskLevel: json['riskLevel'] as String? ?? 'NONE',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class ChatResponse {
  final String reply;
  final String riskLevel;
  final bool safetyTriggered;
  final List<CrisisResource> crisisResources;

  const ChatResponse({
    required this.reply,
    required this.riskLevel,
    required this.safetyTriggered,
    required this.crisisResources,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        reply: json['reply'] as String? ?? '',
        riskLevel: json['riskLevel'] as String? ?? 'NONE',
        safetyTriggered: json['safetyTriggered'] as bool? ?? false,
        crisisResources: ((json['crisisResources'] as List?) ?? [])
            .map((e) => CrisisResource.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
