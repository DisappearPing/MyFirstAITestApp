import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_first_app/features/auth/data/repositories/auth_repository.dart';
import 'package:my_first_app/features/auth/domain/models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;
  AppUser? _user;
  bool _isInitializing = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isInitializing => _isInitializing;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void initialize() {
    _subscription ??= _repository.authStateChanges.listen((user) {
      _user = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  Future<void> continueAsGuest() => _run(_repository.signInAnonymously);
  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);
  Future<void> signOut() => _run(_repository.signOut);
  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _repository.signInWithEmail(email, password));
  Future<void> registerWithEmail(String email, String password) =>
      _run(() => _repository.registerWithEmail(email, password));

  Future<void> _run(Future<void> Function() action) async {
    _errorMessage = null;
    _isSubmitting = true;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _errorMessage = switch (error.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'Email 或密碼不正確。',
        'email-already-in-use' => '這個 Email 已被註冊。',
        'weak-password' => '密碼至少需要 6 個字元。',
        'invalid-email' => '請輸入正確的 Email。',
        _ => error.message ?? '登入失敗，請稍後再試。',
      };
    } on GoogleSignInException catch (error) {
      _errorMessage = 'Google 登入未完成：${error.code.name}。';
    } catch (_) {
      _errorMessage = '操作失敗，請稍後再試。';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
