enum SpeechStyle { banmal, jondaenmal }

extension SpeechStyleX on SpeechStyle {
  String get apiValue => this == SpeechStyle.banmal ? 'BANMAL' : 'JONDAENMAL';
  String get label => this == SpeechStyle.banmal ? '반말' : '존댓말';

  static SpeechStyle fromApi(String value) =>
      value == 'JONDAENMAL' ? SpeechStyle.jondaenmal : SpeechStyle.banmal;
}

class MaringUser {
  final String id;
  final String? email;
  final String nickname;
  final SpeechStyle speechStyle;
  final String? mbtiType;

  const MaringUser({
    required this.id,
    required this.nickname,
    required this.speechStyle,
    this.email,
    this.mbtiType,
  });

  bool get hasMbti => mbtiType != null && mbtiType!.isNotEmpty;

  factory MaringUser.fromJson(Map<String, dynamic> json) {
    return MaringUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      nickname: json['nickname'] as String,
      speechStyle:
          SpeechStyleX.fromApi(json['speechStyle'] as String? ?? 'BANMAL'),
      mbtiType: json['mbtiType'] as String?,
    );
  }

  MaringUser copyWith({String? mbtiType, SpeechStyle? speechStyle}) {
    return MaringUser(
      id: id,
      email: email,
      nickname: nickname,
      speechStyle: speechStyle ?? this.speechStyle,
      mbtiType: mbtiType ?? this.mbtiType,
    );
  }
}
