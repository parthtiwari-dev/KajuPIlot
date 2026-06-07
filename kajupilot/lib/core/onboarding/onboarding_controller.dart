import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_storage.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(onboardingStorageProvider).isComplete();
  }

  Future<void> complete() async {
    state = const AsyncLoading();
    await ref.read(onboardingStorageProvider).markComplete();
    state = const AsyncData(true);
  }
}
