import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// 백엔드 호출 실패(네트워크 오류, 4xx/5xx)를 감싸는 예외.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 마링 백엔드용 최소 HTTP 클라이언트.
class ApiClient {
  final http.Client _client;
  final Duration timeout;

  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 45)})
      : _client = client ?? http.Client();

  void close() => _client.close();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalized').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _client
        .get(_uri(path, query), headers: _headers)
        .timeout(timeout);
    return _decode(res);
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, Map<String, dynamic>? query}) async {
    final res = await _client
        .post(
          _uri(path, query),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    return _decode(res);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final res = await _client
        .put(
          _uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = '요청 실패 (${res.statusCode})';
      try {
        final parsed = jsonDecode(utf8.decode(res.bodyBytes));
        if (parsed is Map && parsed['error'] != null) {
          message = parsed['error'].toString();
        }
      } catch (_) {
        // 응답 본문이 JSON 이 아니면 기본 메시지 사용
      }
      throw ApiException(message, statusCode: res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }
}
