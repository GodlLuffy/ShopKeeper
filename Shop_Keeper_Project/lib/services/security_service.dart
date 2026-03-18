import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  SecurityService(this._storage);

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  Future<void> setPin(String uid, String pin) async {
    final hashedPin = _hashPin(pin);
    await _storage.write(key: 'pin_$uid', value: hashedPin);
    await _storage.write(key: 'is_pin_enabled_$uid', value: 'true');
  }

  Future<bool> verifyPin(String uid, String pin) async {
    final storedPin = await _storage.read(key: 'pin_$uid');
    return storedPin == _hashPin(pin);
  }

  Future<bool> isPinEnabled(String uid) async {
    try {
      final enabled = await _storage.read(key: 'is_pin_enabled_$uid').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> disablePin(String uid) async {
    await _storage.delete(key: 'pin_$uid');
    await _storage.write(key: 'is_pin_enabled_$uid', value: 'false');
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      return await _localAuth.authenticate(
        localizedReason: "Unlock your shop",
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

