import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/models/user_role.dart';
import 'package:new_gym_app/core/services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) => AsyncValue.data(user),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.login(email, password);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    UserRole role, {
    String? cref,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.register(name, email, password, role, cref: cref);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.changePassword(newPassword);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.logout();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserProfile(String newName, String newEmail) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final updatedUser = await authService.updateUserProfile(
        currentUser.uid,
        newName,
        newEmail,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).value;
});
