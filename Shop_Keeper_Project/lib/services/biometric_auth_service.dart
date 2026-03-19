import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Unlock app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
