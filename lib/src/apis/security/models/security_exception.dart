import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';

class SecurityException implements Exception {
  final int osStatus;
  final String message;

  SecurityException(this.osStatus, this.message);

  @override
  String toString() => 'SecurityException($osStatus): $message';

  static void validateStatus(CFArena arena, int osStatus) {
    switch (osStatus) {
      case errSecSuccess:
        break;
      default:
        throw arena.toSecurityException(osStatus);
    }
  }
}
