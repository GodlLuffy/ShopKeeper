import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<String> loginWithPhone(String phoneNumber);
  Future<UserModel> verifyOtp(String verificationId, String smsCode);
  Future<UserModel> register(String name, String email, String password, String shopName);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile(UserModel user);
  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings});
  Future<void> sendEmailVerification();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserFromFirestore(result.user!.uid);
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    final completer = Completer<String>();
    
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // This can automatically sign in on some devices
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );
    
    return completer.future;
  }

  @override
  Future<UserModel> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await firebaseAuth.signInWithCredential(credential);
    return _getUserFromFirestore(result.user!.uid);
  }

  @override
  Future<UserModel> register(String name, String email, String password, String shopName) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await result.user!.sendEmailVerification();
      
      final newUser = UserModel(
        uid: result.user!.uid,
        name: name,
        shopName: shopName,
        phoneNumber: '',
        email: email,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );
      
      await firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      
      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('The email address is already in use by another account.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'weak-password':
          throw Exception('The password is too weak.');
        case 'operation-not-allowed':
          throw Exception('Email/Password accounts are not enabled in Firebase Console.');
        default:
          throw Exception(e.message ?? 'An unexpected error occurred during registration.');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid);
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  @override
  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    await firebaseAuth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    await firebaseAuth.currentUser?.sendEmailVerification();
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    } else {
      final defaultUser = UserModel(
        uid: uid,
        name: 'Shopkeeper',
        shopName: 'My Shop',
        phoneNumber: firebaseAuth.currentUser?.phoneNumber ?? '',
        email: firebaseAuth.currentUser?.email ?? '',
        isEmailVerified: firebaseAuth.currentUser?.emailVerified ?? false,
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc(uid).set(defaultUser.toMap());
      return defaultUser;
    }
  }
}
