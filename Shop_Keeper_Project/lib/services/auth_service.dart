import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const String _continueUrl = 'https://shopkeeper-9f594.firebaseapp.com/login';
  static const String _androidPackageName = 'com.shopkeeper.app';
  static const String _androidMinimumVersion = '1';

  ActionCodeSettings get brandedActionCodeSettings {
    return ActionCodeSettings(
      url: _continueUrl,
      handleCodeInApp: false,
      androidPackageName: _androidPackageName,
      androidInstallApp: true,
      androidMinimumVersion: _androidMinimumVersion,
      iOSBundleId: _androidPackageName,
    );
  }

  Future<void> sendBrandedPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: brandedActionCodeSettings,
    );
  }

  Future<void> sendPasswordResetEmailWithCustomUrl(String email, String continueUrl) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: continueUrl,
        handleCodeInApp: false,
        androidPackageName: _androidPackageName,
        androidInstallApp: true,
        androidMinimumVersion: _androidMinimumVersion,
      ),
    );
  }

  String getFirebaseProjectDomain() {
    return 'shopkeeper-9f594.firebaseapp.com';
  }

  String getAndroidPackageName() {
    return _androidPackageName;
  }
}
