import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithNationalId({
    required String nationalId,
    required String password,
    required String role,
  }) async {
    final email = '${role}_$nationalId@madrasati.edu';

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> adminLogin({
    required String schoolId,
    required String password,
  }) async {
    final email = 'admin@$schoolId.edu.jo';

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
