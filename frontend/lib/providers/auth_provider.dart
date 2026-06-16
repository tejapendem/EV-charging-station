import 'package:ev_connect_india/models/user_model.dart';
import 'package:ev_connect_india/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;
  final bool isOnboardingComplete;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isOnboardingComplete = false,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? error,
    bool? isOnboardingComplete,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      final firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isOnboardingComplete: onboardingComplete,
          user: AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            phoneNumber: firebaseUser.phoneNumber,
            displayName: firebaseUser.displayName ?? 'User',
            photoUrl: firebaseUser.photoURL,
            isEmailVerified: firebaseUser.emailVerified,
            authProvider: AuthProvider.email,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isOnboardingComplete: onboardingComplete,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Sign in failed',
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Registration failed',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInWithGoogle();

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Google sign in failed',
      );
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInAnonymously();

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Anonymous sign in failed',
      );
    }
  }

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required firebase.PhoneVerificationCompleted verificationCompleted,
    required firebase.PhoneVerificationFailed verificationFailed,
    required firebase.PhoneCodeSent codeSent,
    required firebase.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.sendPhoneOtp(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );

    if (result.isSuccess) {
      state = state.copyWith(status: AuthStatus.initial);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Failed to send OTP',
      );
    }
  }

  Future<void> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'OTP verification failed',
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      error: null,
    );
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    state = state.copyWith(isOnboardingComplete: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> updateUser(AppUser user) async {
    state = state.copyWith(user: user);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});

final authStateProvider = Provider<AuthState?>((ref) {
  return ref.watch(authProvider);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});
