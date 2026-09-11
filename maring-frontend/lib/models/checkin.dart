class EmotionCheckin {
  final String id;
  final String emotionCard;
  final int intensity;
  final DateTime checkinDate;

  const EmotionCheckin({
    required this.id,
    required this.emotionCard,
    required this.intensity,
    required this.checkinDate,
  });

  factory EmotionCheckin.fromJson(Map<String, dynamic> json) => EmotionCheckin(
        id: json['id'] as String,
        emotionCard: json['emotionCard'] as String,
        intensity: json['intensity'] as int,
        checkinDate: DateTime.parse(json['checkinDate'] as String),
      );
}

/// S-05 감정 체크인에서 고를 수 있는 감정 카드.
class EmotionCard {
  final String key;
  final String label;

  const EmotionCard(this.key, this.label);

  static const List<EmotionCard> all = [
    EmotionCard('joy', '기쁨'),
    EmotionCard('calm', '평온'),
    EmotionCard('tired', '지침'),
    EmotionCard('sad', '슬픔'),
    EmotionCard('anxious', '불안'),
    EmotionCard('angry', '화남'),
    EmotionCard('lonely', '외로움'),
    EmotionCard('confused', '혼란'),
  ];
}
