import 'package:my_first_app/features/auth/domain/models/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<void> signInAnonymously();
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password);
  Future<void> signOut();
}
