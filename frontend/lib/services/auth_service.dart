import 'package:ev_connect_india/models/user_model.dart';
import 'package:ev_connect_india/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final AppUser? user;
  final String? error;
  final bool isSuccess;
  final String? verificationId;

  const AuthResult({
    this.user,
    this.error,
    required this.isSuccess,
    this.verificationId,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  firebase.FirebaseAuth? _cachedAuth;

  firebase.FirebaseAuth? get firebaseAuth {
    if (_cachedAuth == null) {
      try {
        _cachedAuth = firebase.FirebaseAuth.instance;
      } catch (_) {
        return null;
      }
    }
    return _cachedAuth;
  }

  bool get _hasFirebase => firebaseAuth != null;

  firebase.User? get currentFirebaseUser => firebaseAuth?.currentUser;
  bool get isFirebaseUserLoggedIn => currentFirebaseUser != null;

  Stream<firebase.User?> get authStateChanges =>
      _hasFirebase ? firebaseAuth!.authStateChanges() : const Stream.empty();

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final auth = firebaseAuth;
      if (auth == null) {
        debugPrint('firebaseAuth is null - Firebase not initialized');
        return const AuthResult(
          error: 'Firebase not initialized. Please restart the app.',
          isSuccess: false,
        );
      }
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return const AuthResult(
          error: 'Sign in failed. Please try again.',
          isSuccess: false,
        );
      }

      final idToken = await credential.user!.getIdToken();
      if (idToken != null) {
        await _apiService.setToken(idToken);
      }

      final result = await _apiService.post('/auth/login', body: {
        'email': email.trim(),
        'firebase_uid': credential.user!.uid,
      });

      if (result.isSuccess && result.data != null) {
        final user = AppUser.fromJson(result.data!['user'] as Map<String, dynamic>);
        return AuthResult(user: user, isSuccess: true);
      }

      return AuthResult(
        error: result.error ?? 'Login failed',
        isSuccess: false,
      );
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(
        error: _mapFirebaseAuthError(e),
        isSuccess: false,
      );
    } catch (e) {
      debugPrint('signInWithEmail error: $e');
      return AuthResult(
        error: 'An unexpected error occurred',
        isSuccess: false,
      );
    }
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return const AuthResult(
          error: 'Registration failed. Please try again.',
          isSuccess: false,
        );
      }

      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();

      final idToken = await credential.user!.getIdToken();
      if (idToken != null) {
        await _apiService.setToken(idToken);
      }

      final result = await _apiService.post('/auth/register', body: {
        'email': email.trim(),
        'display_name': displayName.trim(),
        'firebase_uid': credential.user!.uid,
      });

      if (result.isSuccess && result.data != null) {
        final user = AppUser.fromJson(result.data!['user'] as Map<String, dynamic>);
        return AuthResult(user: user, isSuccess: true);
      }

      return AuthResult(
        error: result.error ?? 'Registration failed',
        isSuccess: false,
      );
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(
        error: _mapFirebaseAuthError(e),
        isSuccess: false,
      );
    } catch (e) {
      return AuthResult(
        error: 'An unexpected error occurred',
        isSuccess: false,
      );
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        return const AuthResult(
          error: 'Google sign in cancelled',
          isSuccess: false,
        );
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.idToken == null) {
        return const AuthResult(
          error: 'Failed to get Google auth credentials',
          isSuccess: false,
        );
      }

      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth!.signInWithCredential(credential);

      if (userCredential.user == null) {
        return const AuthResult(
          error: 'Sign in with Google failed',
          isSuccess: false,
        );
      }

      final idToken = await userCredential.user!.getIdToken();
      if (idToken != null) {
        await _apiService.setToken(idToken);
      }

      final result = await _apiService.post('/auth/google', body: {
        'email': userCredential.user!.email,
        'display_name': userCredential.user!.displayName,
        'photo_url': userCredential.user!.photoURL,
        'firebase_uid': userCredential.user!.uid,
      });

      if (result.isSuccess && result.data != null) {
        final user = AppUser.fromJson(result.data!['user'] as Map<String, dynamic>);
        return AuthResult(user: user, isSuccess: true);
      }

      return AuthResult(
        error: result.error ?? 'Google sign in failed',
        isSuccess: false,
      );
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(
        error: _mapFirebaseAuthError(e),
        isSuccess: false,
      );
    } catch (e) {
      return AuthResult(
        error: 'An unexpected error occurred',
        isSuccess: false,
      );
    }
  }

  Future<AuthResult> sendPhoneOtp({
    required String phoneNumber,
    required firebase.PhoneVerificationCompleted verificationCompleted,
    required firebase.PhoneVerificationFailed verificationFailed,
    required firebase.PhoneCodeSent codeSent,
    required firebase.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    try {
      await firebaseAuth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );

      return const AuthResult(isSuccess: true);
    } catch (e) {
      return AuthResult(
        error: 'Failed to send OTP: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  Future<AuthResult> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = firebase.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential =
          await firebaseAuth!.signInWithCredential(credential);

      if (userCredential.user == null) {
        return const AuthResult(
          error: 'Phone verification failed',
          isSuccess: false,
        );
      }

      final idToken = await userCredential.user!.getIdToken();
      if (idToken != null) {
        await _apiService.setToken(idToken);
      }

      final result = await _apiService.post('/auth/phone', body: {
        'phone_number': userCredential.user!.phoneNumber,
        'firebase_uid': userCredential.user!.uid,
      });

      if (result.isSuccess && result.data != null) {
        final user = AppUser.fromJson(result.data!['user'] as Map<String, dynamic>);
        return AuthResult(user: user, isSuccess: true);
      }

      return AuthResult(
        error: result.error ?? 'Phone verification failed',
        isSuccess: false,
      );
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(
        error: _mapFirebaseAuthError(e),
        isSuccess: false,
      );
    } catch (e) {
      return AuthResult(
        error: 'An unexpected error occurred',
        isSuccess: false,
      );
    }
  }

  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await firebaseAuth!.signInAnonymously();

      if (credential.user == null) {
        return const AuthResult(
          error: 'Anonymous sign in failed',
          isSuccess: false,
        );
      }

      final idToken = await credential.user!.getIdToken();
      if (idToken != null) {
        await _apiService.setToken(idToken);
      }

      return AuthResult(
        user: AppUser(
          id: credential.user!.uid,
          displayName: 'Guest',
          authProvider: AuthProvider.email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isSuccess: true,
      );
    } catch (e) {
      return AuthResult(
        error: 'Failed to sign in anonymously',
        isSuccess: false,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await firebaseAuth!.signOut();
      await _apiService.clearToken();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth!.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = firebaseAuth!.currentUser;
    if (user == null) return;

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
  }

  Future<void> deleteAccount() async {
    final user = firebaseAuth!.currentUser;
    if (user == null) return;

    await _apiService.delete('/auth/account');
    await user.delete();
    await _apiService.clearToken();
  }

  String _mapFirebaseAuthError(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
