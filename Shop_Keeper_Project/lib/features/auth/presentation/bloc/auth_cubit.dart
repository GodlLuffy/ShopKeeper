import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/auth/domain/entities/user_entity.dart';
import 'package:shop_keeper_project/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuth() async {
    final userOption = await authRepository.getCurrentUser();
    userOption.fold(
      () => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    final result = await authRepository.loginWithEmail(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
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
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> register(String name, String email, String password, String shopName) async {
    emit(AuthLoading());
    final result = await authRepository.register(name, email, password, shopName);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(Unauthenticated());
  }
}
