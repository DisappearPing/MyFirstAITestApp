import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_first_app/features/auth/data/repositories/auth_repository.dart';
import 'package:my_first_app/features/auth/domain/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.userChanges().map(_toAppUser);

  @override
  Future<void> signInAnonymously() => _firebaseAuth.signInAnonymously();

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser?.isAnonymous ?? false) {
        await currentUser!.linkWithPopup(provider);
      } else {
        await _firebaseAuth.signInWithPopup(provider);
      }
      return;
    }

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    await _linkAnonymousAccountIfNeeded(credential);
  }

  @override
  Future<void> signInWithEmail(String email, String password) => _firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> registerWithEmail(String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser?.isAnonymous ?? false) {
      await currentUser!.linkWithCredential(credential);
    } else {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName: user.displayName,
    );
  }

  Future<void> _linkAnonymousAccountIfNeeded(AuthCredential credential) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser?.isAnonymous ?? false) {
      try {
        await currentUser!.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use') rethrow;

        // The user chose an account that already exists. Do not try to link it
        // to this new guest account; switch to the existing account instead.
        await _firebaseAuth.signOut();
        await _firebaseAuth.signInWithCredential(credential);
      }
      return;
    }
    await _firebaseAuth.signInWithCredential(credential);
  }
}
