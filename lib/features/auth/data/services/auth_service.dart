import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Faz a comunicação direta com Firebase Auth e Firestore.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-user-null',
        message: 'Usuário Google não encontrado.',
      );
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      final now = Timestamp.now();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'onboardingCompleted': false,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    return userCredential;
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Não foi possível criar o usuário.',
      );
    }

    final now = Timestamp.now();
    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      photoUrl: null,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userCredential;
  }

  Future<UserCredential> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
}
