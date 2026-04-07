import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password);
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp(String verificationId, String smsCode);
  Future<Either<Failure, UserEntity>> register(String name, String email, String password, String shopName);
  Future<Either<Failure, void>> logout();
  Future<Option<UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> updateProfile(UserEntity user);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings});
}
