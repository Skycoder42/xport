import 'dart:ffi';
import 'dart:typed_data';

import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';
import 'sec_item.dart';

final class SecCertificate extends SecItem<SecCertificateRef> {
  SecCertificate(super.securityFramework, super.ref);

  Uint8List get serialNumber => securityFramework.withArena((arena) {
    final error = arena<CFErrorRef>();
    final data = securityFramework.SecCertificateCopySerialNumberData(
      ref,
      error,
    );

    if (error.value != nullptr) {
      arena.autoRelease(data);
      throw arena.toCFException(arena.autoRelease(error.value));
    }

    return arena.toUint8List(data);
  });
}
