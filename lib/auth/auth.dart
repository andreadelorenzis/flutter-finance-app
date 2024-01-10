import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finance_app/auth/AuthMethod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';

class Auth{
  Auth._privateConstructor();

  static final Auth _instance = Auth._privateConstructor();

  factory Auth() {
    return _instance;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;
    GoogleSignInAuthentication? googleAuth;

    // Inizia il flusso di autenticazione per il Web
    googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  bool isWeb() {
    return UniversalPlatform.isWeb;
  }

  bool isAndroid() {
    return UniversalPlatform.isAndroid;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword({
    required String email
  }) async {
    return await _firebaseAuth.sendPasswordResetEmail(email: email);
  }



  User? getCurrentUser() {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    return currentUser;
  }

  Future<void> updateDisplayName(String name) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.updateDisplayName(name);
    } else {
      throw Exception('User not authenticate');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.verifyBeforeUpdateEmail(newEmail);
    } else {
      throw Exception('User not authenticate');
    }
  }

  AuthMethod getAuthMethod() {
    User? user = getCurrentUser();

    // Controlla se l'utente è autenticato tramite email/password
    bool isEmailPasswordUser = user?.providerData.any((provider) => provider.providerId == 'password') ?? false;

    // Controlla se l'utente è autenticato tramite Google
    bool isGoogleUser = user?.providerData.any((provider) => provider.providerId == 'google.com') ?? false;

    if (isEmailPasswordUser) {
      return AuthMethod.emailPassword;
    } else if (isGoogleUser) {
      return AuthMethod.google;
    } else {
      return AuthMethod.unknown;
    }

  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();

    return user?.emailVerified ?? false;
  }



}