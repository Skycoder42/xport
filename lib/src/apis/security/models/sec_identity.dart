import 'dart:ffi';

import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';
import 'sec_certificate.dart';
import 'sec_item.dart';
import 'security_exception.dart';

final class SecIdentity extends SecItem<SecIdentityRef> {
  SecIdentity(super.ref);

  SecCertificate copyCertificate() => withArena((arena) {
    final certRefPtr = arena<SecCertificateRef>();
    final result = SecIdentityCopyCertificate(ref, certRefPtr);
    SecurityException.validateStatus(arena, result);
    return SecCertificate(certRefPtr.value);
  });
}
