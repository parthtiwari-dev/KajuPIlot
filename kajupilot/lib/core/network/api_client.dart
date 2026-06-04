import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ),
  );
});

final apiClientProvider = Provider<KajuApiClient>((ref) {
  return KajuApiClient(ref.watch(dioProvider));
});

class KajuApiClient {
  KajuApiClient(this._dio);

  final Dio _dio;

  Future<AuthSession> setupOwner({
    required String setupCode,
    String? name,
    String? businessName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/setup',
      data: {
        'setupCode': setupCode,
        if (name != null && name.isNotEmpty) 'name': name,
        if (businessName != null && businessName.isNotEmpty)
          'businessName': businessName,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Setup returned no data.');
    }

    return AuthSession.fromJson(data);
  }
}

class AuthSession {
  const AuthSession({
    this.userId,
    required this.deviceToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as String?,
      deviceToken: json['deviceToken'] as String,
    );
  }

  final String? userId;
  final String deviceToken;
}
