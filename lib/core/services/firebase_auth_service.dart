import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:new_gym_app/core/models/user_model.dart' as app_model;
import 'package:new_gym_app/core/models/user_role.dart';

import '../../../firebase_options.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app_model.User? _cachedUser;

  Stream<app_model.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }
      _cachedUser = await _getUserFromFirestore(firebaseUser.uid);
      return _cachedUser;
    });
  }

  app_model.User? get currentUser {
    if (_firebaseAuth.currentUser == null) return null;
    return _cachedUser;
  }

  Future<app_model.User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _cachedUser = await _getUserFromFirestore(credential.user!.uid);
      return _cachedUser!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

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

      final user = app_model.User(
        uid: credential.user!.uid,
        name: name,
        email: email,
        photoUrl: 'assets/images/profile.png',
        role: role,
        personalTrainerId: personalTrainerId,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      _cachedUser = user;
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<app_model.User> registerStudentAsPersonal(
    String name,
    String email,
    String password,
    String personalTrainerId,
  ) async {
    firebase_auth.FirebaseAuth? secondaryAuth;
    FirebaseApp? secondaryApp;

    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('Personal Trainer não autenticado');
      }
      secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      secondaryAuth = firebase_auth.FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final studentUid = credential.user!.uid;

      final student = app_model.User(
        uid: studentUid,
        name: name,
        email: email,
        photoUrl: 'assets/images/profile.png',
        role: UserRole.student,
        personalTrainerId: personalTrainerId,
      );

      await _firestore.collection('users').doc(studentUid).set(student.toMap());

      await secondaryAuth.signOut();

      await secondaryApp.delete();

      return student;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (secondaryAuth != null) {
        await secondaryAuth.signOut();
      }
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (secondaryAuth != null) {
        await secondaryAuth.signOut();
      }
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      throw Exception('Erro ao cadastrar aluno: $e');
    }
  }

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
      _cachedUser = await _getUserFromFirestore(uid);
      return _cachedUser!;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> logout() async {
    _cachedUser = null;
    await _firebaseAuth.signOut();
  }

  Future<app_model.User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('Dados do usuário não encontrados no Firestore');
    }

    return app_model.User.fromMap(doc.data()!, uid);
  }

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
