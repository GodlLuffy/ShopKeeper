import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  final FlutterSecureStorage _storage;

  PinService(this._storage);

  Future<void> setPin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    return storedPin == pin;
  }

  Future<bool> hasPin() async {
    final storedPin = await _storage.read(key: 'user_pin');
    return storedPin != null && storedPin.isNotEmpty;
  }
}
