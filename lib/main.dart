import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_first_app/app/app.dart';
import 'package:my_first_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:my_first_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:my_first_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // google_sign_in 7.x requires initialization before authenticate().
  // Web uses FirebaseAuth's popup flow instead.
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }
  runApp(TodoApp(home: AuthGate(authRepository: FirebaseAuthRepository())));
}
