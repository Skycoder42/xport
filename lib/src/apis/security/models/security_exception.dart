import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';

class SecurityException(final int osStatus, final String message)
    implements Exception {
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
