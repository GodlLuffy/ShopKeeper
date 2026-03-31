# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.x (latest) | ✅ Yes |
| < 1.0 | ❌ No |

## Reporting a Vulnerability

If you discover a security vulnerability within ShopKeeper, please follow responsible disclosure:

1. **Do NOT** open a public GitHub issue.
2. Email the maintainer directly at **gundelwaranup119@gmail.com**.
3. Include a clear description of the vulnerability and steps to reproduce.
4. Allow up to **48 hours** for an initial response.

We take all security reports seriously. Thank you for helping keep ShopKeeper and its users safe. 🛡️

## Security Measures

ShopKeeper implements the following security practices:

- **4-digit PIN Lock** with session grace period
- **Biometric Authentication** (Fingerprint / FaceID) via `local_auth`
- **Firebase Authentication** with email verification
- **Encrypted local storage** via Hive
- **Cloud data encryption** in transit and at rest via Firebase/Firestore
