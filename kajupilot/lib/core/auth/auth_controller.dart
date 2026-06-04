import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'token_storage.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  return AuthController(
    tokenStorage: ref.watch(tokenStorageProvider),
    apiClient: ref.watch(apiClientProvider),
  )..load();
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController({
    required TokenStorage tokenStorage,
    required KajuApiClient apiClient,
  })  : _tokenStorage = tokenStorage,
        _apiClient = apiClient,
        super(const AsyncLoading());

  final TokenStorage _tokenStorage;
  final KajuApiClient _apiClient;

  Future<void> load() async {
    try {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        state = const AsyncData(null);
        return;
      }

      state = AsyncData(AuthSession(deviceToken: token));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setupOwner({
    required String setupCode,
    String? name,
    String? businessName,
  }) async {
    state = const AsyncLoading();

    try {
      final session = await _apiClient.setupOwner(
        setupCode: setupCode,
        name: name,
        businessName: businessName,
      );
      await _tokenStorage.writeToken(session.deviceToken);
      state = AsyncData(session);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    await _tokenStorage.clearToken();
    state = const AsyncData(null);
  }
}
