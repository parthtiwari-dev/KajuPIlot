import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/token_storage.dart';

const _onboardingCompleteKey = 'kajupilot_onboarding_complete';

abstract interface class OnboardingStorage {
  Future<bool> isComplete();
  Future<void> markComplete();
}

class SecureOnboardingStorage implements OnboardingStorage {
  const SecureOnboardingStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<bool> isComplete() async {
    return await _storage.read(key: _onboardingCompleteKey) == 'true';
  }

  @override
  Future<void> markComplete() {
    return _storage.write(key: _onboardingCompleteKey, value: 'true');
  }
}

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return SecureOnboardingStorage(ref.watch(flutterSecureStorageProvider));
});
