import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shop_keeper_project/features/auth/data/models/user_model.dart';
import 'package:shop_keeper_project/features/auth/domain/entities/user_entity.dart';
import 'package:shop_keeper_project/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password) async {
    try {
      final user = await remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber) async {
    try {
      final verificationId = await remoteDataSource.loginWithPhone(phoneNumber);
      return Right(verificationId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String verificationId, String smsCode) async {
    try {
      final user = await remoteDataSource.verifyOtp(verificationId, smsCode);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String name, String email, String password, String shopName) async {
    try {
      final user = await remoteDataSource.register(name, email, password, shopName);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    return user != null ? Some(user) : const None();
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await remoteDataSource.updateProfile(userModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
