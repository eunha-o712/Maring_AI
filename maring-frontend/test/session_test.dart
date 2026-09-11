import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maring_app/core/api_client.dart';
import 'package:maring_app/models/maring_user.dart';
import 'package:maring_app/state/providers.dart';

Map<String, Object?> userJson({String? mbti}) => {
      'id': 'user-1',
      'nickname': '테스트',
      'speechStyle': 'JONDAENMAL',
      'mbtiType': mbti,
    };

http.Response userResponse({String? mbti}) => http.Response.bytes(
      utf8.encode(jsonEncode(userJson(mbti: mbti))),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Future<void> restored(ProviderContainer container) async {
  final ready = Completer<void>();
  final subscription = container.listen(sessionProvider, (_, state) {
    if (!state.loading && !ready.isCompleted) ready.complete();
  }, fireImmediately: true);
  await ready.future;
  subscription.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('temporary server error preserves session and retry restores it',
      () async {
    SharedPreferences.setMockInitialValues(
        {'maring.userId': 'user-1', 'maring.conversationId': 'conversation-1'});
    var online = false;
    final api = ApiClient(
        client: MockClient((_) async =>
            online ? userResponse(mbti: 'INFP') : http.Response('{}', 503)));
    final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    addTearDown(api.close);
    await restored(container);
    expect(container.read(sessionProvider).error, isNotNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('maring.userId'), 'user-1');
    expect(prefs.getString('maring.conversationId'), 'conversation-1');
    online = true;
    await container.read(sessionProvider.notifier).retryRestore();
    expect(container.read(sessionProvider).isOnboarded, isTrue);
    expect(container.read(sessionProvider).error, isNull);
  });

  test('only a missing user clears persisted session', () async {
    SharedPreferences.setMockInitialValues({
      'maring.userId': 'old-user',
      'maring.conversationId': 'old-conversation'
    });
    final api =
        ApiClient(client: MockClient((_) async => http.Response('{}', 404)));
    final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    addTearDown(api.close);
    await restored(container);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('maring.userId'), isNull);
    expect(prefs.getString('maring.conversationId'), isNull);
    expect(container.read(sessionProvider).error, isNull);
  });

  test('failed speech-style save cannot complete onboarding; retry saves both',
      () async {
    SharedPreferences.setMockInitialValues({'maring.userId': 'user-1'});
    var failStyle = true;
    final writes = <String>[];
    final api = ApiClient(client: MockClient((request) async {
      if (request.method == 'PUT') {
        writes.add(request.url.path);
        if (request.url.path.endsWith('speech-style') && failStyle) {
          return http.Response('{}', 500);
        }
        return userResponse(
            mbti: request.url.path.endsWith('/mbti') ? 'INFP' : null);
      }
      return userResponse();
    }));
    final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    addTearDown(api.close);
    await restored(container);
    final session = container.read(sessionProvider.notifier);
    await expectLater(
        session.completeOnboarding('INFP', SpeechStyle.jondaenmal),
        throwsA(isA<ApiException>()));
    expect(container.read(sessionProvider).isOnboarded, isFalse);
    expect(writes, ['/api/users/user-1/speech-style']);
    failStyle = false;
    await session.completeOnboarding('INFP', SpeechStyle.jondaenmal);
    expect(container.read(sessionProvider).isOnboarded, isTrue);
    expect(writes.last, '/api/users/user-1/mbti');
  });
}
