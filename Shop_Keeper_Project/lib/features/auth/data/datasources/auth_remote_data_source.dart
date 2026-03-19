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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth? firebaseAuth;
  final FirebaseFirestore? firestore;

  AuthRemoteDataSourceImpl({
    this.firebaseAuth,
    this.firestore,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    if (firebaseAuth == null) {
      return const UserModel(uid: 'demo_user', name: 'Anup', shopName: 'Anup Store', phoneNumber: '', email: 'gundelwaranup119@gmail.com');
    }
    final result = await firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserFromFirestore(result.user!.uid);
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    if (firebaseAuth == null) return 'demo_id';
    
    final completer = Completer<String>();
    
    await firebaseAuth!.verifyPhoneNumber(
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
    if (firebaseAuth == null) {
      return const UserModel(uid: 'demo_user', name: 'Anup', shopName: 'Anup Store', phoneNumber: '', email: 'gundelwaranup119@gmail.com');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await firebaseAuth!.signInWithCredential(credential);
    return _getUserFromFirestore(result.user!.uid);
  }

  @override
  Future<UserModel> register(String name, String email, String password, String shopName) async {
    if (firebaseAuth == null) {
      return UserModel(uid: 'demo_user', name: name.isEmpty ? 'Anup' : name, shopName: shopName.isEmpty ? 'Anup Store' : shopName, phoneNumber: '', email: email.isEmpty ? 'gundelwaranup119@gmail.com' : email);
    }
    final result = await firebaseAuth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final newUser = UserModel(
      uid: result.user!.uid,
      name: name,
      shopName: shopName,
      phoneNumber: '',
      email: email,
    );
    
    if (firestore != null) {
      await firestore!.collection('users').doc(newUser.uid).set(newUser.toMap());
    }
    
    return newUser;
  }

  @override
  Future<void> logout() async {
    if (firebaseAuth != null) await firebaseAuth!.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (firebaseAuth == null) {
      return const UserModel(uid: 'demo_user', name: 'Anup', shopName: 'Anup Store', phoneNumber: '', email: 'gundelwaranup119@gmail.com');
    }
    final user = firebaseAuth!.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid);
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    if (firebaseAuth == null || firestore == null) return;
    await firestore!.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    if (firestore == null) {
      return UserModel(uid: uid, name: 'Anup', shopName: 'Anup Store', phoneNumber: '', email: 'gundelwaranup119@gmail.com');
    }
    final doc = await firestore!.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    } else {
      final defaultUser = UserModel(
        uid: uid,
        name: 'Shopkeeper',
        shopName: 'My Shop',
        phoneNumber: firebaseAuth?.currentUser?.phoneNumber ?? '',
        email: firebaseAuth?.currentUser?.email ?? '',
      );
      await firestore!.collection('users').doc(uid).set(defaultUser.toMap());
      return defaultUser;
    }
  }
}
