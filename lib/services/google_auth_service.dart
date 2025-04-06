import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events'
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      print('Sign-in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<Map<String, String>> get authHeaders async {
    final user = _googleSignIn.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return await user.authHeaders;
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}