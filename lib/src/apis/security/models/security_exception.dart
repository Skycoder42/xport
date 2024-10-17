import 'dart:ffi';

import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';

class SecurityException implements Exception {
  final int osStatus;
  final String message;

  SecurityException(this.osStatus, this.message);

  @override
  String toString() => 'SecurityException($osStatus): $message';

  factory SecurityException.fromOsStatus(
    SecurityFramework securityFramework,
    int osStatus,
  ) {
    final arena = CFArena(securityFramework);
    try {
      final message = arena.autoRelease(
        securityFramework.SecCopyErrorMessageString(osStatus, nullptr),
      );
      return SecurityException(osStatus, arena.toDartString(message));
    } finally {
      arena.releaseAll();
    }
  }
}
