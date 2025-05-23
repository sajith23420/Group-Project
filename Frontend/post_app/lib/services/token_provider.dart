// lib/services/token_provider.dart

import 'package:firebase_auth/firebase_auth.dart';

class TokenProvider {
  final FirebaseAuth _firebaseAuth;

  TokenProvider(this._firebaseAuth);

  Future<String?> getIdToken() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null; // Or throw an exception if token is always expected
    }
    try {
      final idToken = await currentUser.getIdToken(true); // Force refresh if needed
      return idToken;
    } catch (e) {
      print("Error getting ID token: $e");
      return null; // Or rethrow
    }
  }
}