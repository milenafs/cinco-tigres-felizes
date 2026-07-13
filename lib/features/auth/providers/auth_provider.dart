import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';

/// Controla o estado de autenticação para a interface sem acessar Firebase diretamente.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    currentUser = _authRepository.currentUser;
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authRepository.signInWithGoogle();

      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Erro ao entrar com Google';
    } catch (_) {
      errorMessage = 'Não foi possível entrar com Google';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signIn(email: email, password: password);
      currentUser = _authRepository.currentUser;
    } on FirebaseAuthException catch (exception) {
      errorMessage = exception.message ?? _fallbackMessage(exception.code);
    } catch (_) {
      errorMessage = 'Não foi possível fazer login.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      currentUser = _authRepository.currentUser;
    } on FirebaseAuthException catch (exception) {
      errorMessage = exception.message ?? _fallbackMessage(exception.code);
    } catch (_) {
      errorMessage = 'Não foi possível criar a conta.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signOut();
      currentUser = null;
    } on FirebaseAuthException catch (exception) {
      errorMessage = exception.message ?? _fallbackMessage(exception.code);
    } catch (_) {
      errorMessage = 'Não foi possível sair da conta.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
  }

  String _fallbackMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Ocorreu um erro de autenticação.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
