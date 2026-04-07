import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class TerminalIdService {
  static const String _terminalIdKey = 'terminal_id';
  
  final FlutterSecureStorage _secureStorage;
  
  TerminalIdService(this._secureStorage);
  
  Future<String> getTerminalId([String? userId]) async {
    final key = userId != null ? '${_terminalIdKey}_$userId' : _terminalIdKey;
    final stored = await _secureStorage.read(key: key);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    
    final newId = _generateTerminalId();
    await _secureStorage.write(key: key, value: newId);
    return newId;
  }
  
  String _generateTerminalId() {
    const uuid = Uuid();
    final uniquePart = uuid.v4().substring(0, 8).toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
    
    String devicePrefix = 'SK';
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        devicePrefix = 'SA';
      } else if (Platform.isIOS) {
        devicePrefix = 'SI';
      } else if (Platform.isWindows) {
        devicePrefix = 'SW';
      } else if (Platform.isMacOS) {
        devicePrefix = 'SM';
      } else if (Platform.isLinux) {
        devicePrefix = 'SL';
      }
    }
    
    return '$devicePrefix-$uniquePart-$timestamp';
  }
  
  Future<bool> hasTerminalId() async {
    final stored = await _secureStorage.read(key: _terminalIdKey);
    return stored != null && stored.isNotEmpty;
  }
  
  Future<void> regenerateTerminalId() async {
    final newId = _generateTerminalId();
    await _secureStorage.write(key: _terminalIdKey, value: newId);
  }
  
  Future<Map<String, String>> getTerminalInfo() async {
    final terminalId = await getTerminalId();
    final platform = kIsWeb ? 'Web' : Platform.operatingSystem;
    final timestamp = DateTime.now().toIso8601String();
    
    return {
      'terminalId': terminalId,
      'platform': platform,
      'registeredAt': timestamp,
    };
  }
}
