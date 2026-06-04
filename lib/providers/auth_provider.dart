import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AdminAuthProvider extends ChangeNotifier {
  bool _isAdminMode = false;
  bool _isSigningIn = false;
  User? _user;
  bool _isAdmin = false;
  String? _errorMessage;

  bool get isAdminMode => _isAdminMode;
  bool get isSigningIn => _isSigningIn;
  User? get user => _user;
  bool get isAdmin => _isAdmin;
  String? get errorMessage => _errorMessage;

  /// Débloque le mode administrateur (appelé après l'easter egg des 7 taps)
  void unlockAdminMode() {
    if (_isAdminMode) return;
    _isAdminMode = true;
    notifyListeners();
  }

  /// Connexion avec Google + Firebase Auth
  Future<void> signInWithGoogle() async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lancement du flow Google Sign-In
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // L'utilisateur a annulé
        _isSigningIn = false;
        notifyListeners();
        return;
      }

      // Récupération des credentials Google
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connexion Firebase avec les credentials Google
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;

      // Vérification des custom claims pour déterminer le statut admin
      await _checkAdminClaims();
    } catch (e) {
      _errorMessage = 'Erreur de connexion : ${e.toString()}';
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  /// Déconnexion : retour au compte anonyme
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      // Reconnexion anonyme après déconnexion
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      _errorMessage = 'Erreur de déconnexion : ${e.toString()}';
    }

    _user = null;
    _isAdmin = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Vérifie les custom claims Firebase pour le statut admin
  Future<void> _checkAdminClaims() async {
    if (_user == null) {
      _isAdmin = false;
      return;
    }

    try {
      final idTokenResult = await _user!.getIdTokenResult(true);
      _isAdmin = idTokenResult.claims?['admin'] == true;
    } catch (e) {
      _isAdmin = false;
    }
  }
}