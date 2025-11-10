import 'dart:ffi';
import 'dart:typed_data';

import '../ffi/cf_arena.dart';
import '../ffi/security_framework.dart';
import 'cf_type.dart';
import 'security_exception.dart';

abstract base class SecItem<T extends Pointer<NativeType>> extends CFType<T> {
  /// See /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework/Headers/SecImportExport.h:L147
  static const _secItemImportExportKeyParametersVersion = 0;

  SecItem(super.securityFramework, super.ref);

  Uint8List export(String passphrase) => securityFramework.withArena((arena) {
    final pfx = arena<CFDataRef>();
    final params = arena<SecItemImportExportKeyParameters>();
    params.ref
      ..version = _secItemImportExportKeyParametersVersion
      ..flags = 0
      ..passphrase = arena.toCFString(passphrase).cast();

    final result = securityFramework.SecItemExport(
      ref.cast(),
      SecExternalFormat.kSecFormatPKCS12,
      0,
      params,
      pfx,
    );
    SecurityException.validateStatus(arena, result);
    return arena.toUint8List(pfx.value);
  });
}
