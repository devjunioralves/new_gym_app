import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:new_gym_app/core/models/user_model.dart' as app_model;
import 'package:new_gym_app/core/models/user_role.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream do estado de autenticação
  Stream<app_model.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  // Usuário atual
  app_model.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    // Retorna null para buscar assincronamente do Firestore
    return null;
  }

  // Login
  Future<app_model.User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserFromFirestore(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro
  Future<app_model.User> register(
    String name,
    String email,
    String password,
    UserRole role, {
    String? personalTrainerId,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cria documento do usuário no Firestore
      final user = app_model.User(
        uid: credential.user!.uid,
        name: name,
        email: email,
        photoUrl: 'assets/images/profile.png',
        role: role,
        personalTrainerId: personalTrainerId,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Atualizar perfil
  Future<app_model.User> updateUserProfile(
    String uid,
    String name,
    String email,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return await _getUserFromFirestore(uid);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Buscar dados do usuário no Firestore
  Future<app_model.User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('Dados do usuário não encontrados no Firestore');
    }

    return app_model.User.fromMap(doc.data()!, uid);
  }

  // Tratamento de erros do Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
