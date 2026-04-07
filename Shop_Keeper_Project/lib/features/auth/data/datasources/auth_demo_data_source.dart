import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/features/auth/data/datasources/auth_remote_data_source.dart';

import 'package:shop_keeper_project/features/auth/data/models/user_model.dart';

class AuthDemoDataSourceImpl implements AuthRemoteDataSource {
  UserModel get _demoUser => UserModel(
        uid: 'demo_user_123',
        name: 'Demo Shopkeeper',
        shopName: 'ShopKeeper PRO Demo',
        phoneNumber: '+1234567890',
        email: 'demo@shopkeeper.pro',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    return _demoUser;
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    return "demo_verification_id";
  }

  @override
  Future<UserModel> verifyOtp(String verificationId, String smsCode) async {
    return _demoUser;
  }

  @override
  Future<UserModel> register(String name, String email, String password, String shopName) async {
    return _demoUser;
  }

  @override
  Future<void> logout() async {
    // No-op for demo
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _demoUser;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    // No-op for demo
  }

  @override
  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    // No-op for demo
  }

  @override
  Future<void> sendEmailVerification() async {
    // No-op for demo
  }
}
