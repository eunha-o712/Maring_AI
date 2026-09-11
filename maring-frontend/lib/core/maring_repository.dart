import '../models/maring_user.dart';
import '../models/chat_models.dart';
import '../models/checkin.dart';
import 'api_client.dart';

/// 마링 백엔드 API 를 타입 있는 메서드로 감싼 저장소.
class MaringRepository {
  final ApiClient _api;

  MaringRepository(this._api);

  Future<MaringUser> createUser(String nickname, {String? email}) async {
    final json = await _api.post('/api/users', body: {
      if (email != null && email.isNotEmpty) 'email': email,
      'nickname': nickname,
    });
    return MaringUser.fromJson(json as Map<String, dynamic>);
  }

  Future<MaringUser> getUser(String userId) async {
    final json = await _api.get('/api/users/$userId');
    return MaringUser.fromJson(json as Map<String, dynamic>);
  }

  Future<MaringUser> setMbti(String userId, String mbtiType) async {
    final json =
        await _api.put('/api/users/$userId/mbti', body: {'mbtiType': mbtiType});
    return MaringUser.fromJson(json as Map<String, dynamic>);
  }

  Future<MaringUser> setSpeechStyle(String userId, SpeechStyle style) async {
    final json = await _api.put('/api/users/$userId/speech-style',
        body: {'speechStyle': style.apiValue});
    return MaringUser.fromJson(json as Map<String, dynamic>);
  }

  Future<String> startConversation(String userId) async {
    final json =
        await _api.post('/api/conversations', query: {'userId': userId});
    return (json as Map<String, dynamic>)['conversationId'] as String;
  }

  Future<ChatResponse> sendMessage(
      String conversationId, String message) async {
    final json = await _api.post('/api/conversations/$conversationId/messages',
        body: {'message': message});
    return ChatResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> conversationHistory(String conversationId) async {
    final json = await _api.get('/api/conversations/$conversationId/messages');
    return (json as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmotionCheckin> submitCheckin(
      String userId, String emotionCard, int intensity) async {
    final json = await _api.post('/api/checkins', body: {
      'userId': userId,
      'emotionCard': emotionCard,
      'intensity': intensity,
    });
    return EmotionCheckin.fromJson(json as Map<String, dynamic>);
  }

  Future<List<EmotionCheckin>> checkinHistory(String userId) async {
    final json = await _api.get('/api/checkins', query: {'userId': userId});
    return (json as List)
        .map((e) => EmotionCheckin.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CrisisResource>> crisisResources() async {
    final json = await _api.get('/api/safety/resources');
    return (json as List)
        .map((e) => CrisisResource.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
