import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Encapsula o serviço de autenticação e mantém a camada de dados isolada.
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<UserCredential> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _authService.signUp(name: name, email: email, password: password);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email, password);
  }

  Future<void> signOut() => _authService.signOut();

  User? get currentUser => _authService.currentUser;

  Stream<User?> authStateChanges() => _authService.authStateChanges();
}
