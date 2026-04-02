import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shop_keeper_project/features/auth/domain/entities/user_entity.dart';
import 'package:shop_keeper_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_keeper_project/services/pin_service.dart';
import 'package:shop_keeper_project/services/biometric_auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final PinService pinService;
  final BiometricAuthService biometricService;
  final bool isDemoMode;
  
  DateTime? _lastUnlockTime;
  static const _pinGraceDuration = Duration(minutes: 10);

  AuthCubit({
    required this.authRepository,
    required this.pinService,
    required this.biometricService,
    this.isDemoMode = false,
  }) : super(AuthInitial());

  Future<void> checkAuth() async {
    try {
      final userOption = await authRepository.getCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Auth check timed out');
        },
      );
      userOption.fold(
        () => emit(Unauthenticated()),
        (user) => _handleSuccessfulAuth(user),
      );
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _handleSuccessfulAuth(UserEntity user) async {
    final isVerified = await _checkEmailVerification();
    final userWithVerification = user.copyWith(isEmailVerified: isVerified);
    
    if (!isVerified) {
      emit(EmailVerificationPending(userWithVerification));
      return;
    }

    try {
      final pinEnabled = await pinService.hasPin();
      if (pinEnabled) {
        if (_lastUnlockTime != null && 
            DateTime.now().difference(_lastUnlockTime!) < _pinGraceDuration) {
          emit(Authenticated(userWithVerification));
          return;
        }

        final bioSuccess = await biometricService.authenticate();
        if (bioSuccess) {
          _lastUnlockTime = DateTime.now();
          emit(Authenticated(userWithVerification));
        } else {
          emit(PinRequired(userWithVerification));
        }
      } else {
        emit(Authenticated(userWithVerification));
      }
    } catch (e) {
      emit(Authenticated(userWithVerification));
    }
  }

  Future<bool> _checkEmailVerification() async {
    if (isDemoMode) return true;
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      return firebaseUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshEmailVerification() async {
    if (isDemoMode) return;
    if (state is EmailVerificationPending) {
      final user = (state as EmailVerificationPending).user;
      try {
        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        await firebaseUser?.reload();
        
        final isVerified = firebaseUser?.emailVerified ?? false;
        if (isVerified) {
          await _handleSuccessfulAuth(user.copyWith(isEmailVerified: true));
        }
      } catch (e) {
        debugPrint('AUTH: Error refreshing verification: $e');
      }
    }
  }

  Future<void> resendVerificationEmail() async {
    if (isDemoMode) return;
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      emit(const AuthError('Check your inbox or try again in a minute.'));
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    final result = await authRepository.loginWithEmail(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => _handleSuccessfulAuth(user),
    );
  }

  Future<void> loginWithPhone(String phoneNumber) async {
    emit(AuthLoading());
    
    // Auto-format for India (+91) if only 10 digits provided
    String formattedPhone = phoneNumber.trim();
    if (formattedPhone.length == 10 && !formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone';
    } else if (!formattedPhone.startsWith('+')) {
      // If it doesn't start with +, and isn't 10 digits, it might still fail, 
      // but let's try to be helpful. 
      // Most users in India forget the +91.
      if (formattedPhone.length > 5) {
        formattedPhone = '+91$formattedPhone';
      }
    }

    final result = await authRepository.loginWithPhone(formattedPhone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verificationId) => emit(OtpSent(verificationId)),
    );
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(verificationId, smsCode);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => _handleSuccessfulAuth(user),
    );
  }

  Future<void> register(String name, String email, String password, String shopName) async {
    emit(AuthLoading());
    final result = await authRepository.register(name, email, password, shopName);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => _handleSuccessfulAuth(user),
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(Unauthenticated());
  }

  void requirePin() {
    if (state is Authenticated) {
      _lastUnlockTime = null; // Reset session when explicitly locking
      emit(PinRequired((state as Authenticated).user));
    }
  }

  void unlockApp() {
    if (state is PinRequired) {
      _lastUnlockTime = DateTime.now(); // Set session on unlock
      emit(Authenticated((state as PinRequired).user));
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String shopName,
    required String phoneNumber,
    required String email,
  }) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      final updatedUser = UserEntity(
        uid: currentUser.uid,
        name: name,
        shopName: shopName,
        phoneNumber: phoneNumber,
        email: email,
      );

      emit(AuthLoading());
      final result = await authRepository.updateProfile(updatedUser);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(Authenticated(updatedUser)),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());
    final result = await authRepository.sendPasswordResetEmail(email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSent()),
    );
  }
}
