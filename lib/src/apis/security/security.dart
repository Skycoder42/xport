import 'dart:ffi';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import 'ffi/cf_arena.dart';
import 'ffi/security_framework.dart';
import 'models/sec_identity.dart';
import 'models/security_exception.dart';

@injectable
class Security {
  /// See /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework/Headers/SecImportExport.h:L147
  static const _secItemImportExportKeyParametersVersion = 0;

  final SecurityFramework _securityFramework;

  Security(this._securityFramework);

  SecIdentity? findIdentity({
    required String subject,
    required DateTime validOn,
  }) =>
      _securityFramework.withArena((arena) {
        final dict = arena.autoRelease(
          _securityFramework.CFDictionaryCreateMutable(
            nullptr,
            0,
            nullptr,
            nullptr,
          ),
        );

        _securityFramework
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecClass.cast(),
            _securityFramework.kSecClassIdentity.cast(),
          )
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecUseDataProtectionKeychain.cast(),
            _securityFramework.kCFBooleanFalse.cast(),
          )
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecMatchLimit.cast(),
            _securityFramework.kSecMatchLimitOne.cast(),
          )
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecMatchSubjectContains.cast(),
            arena.toCFString(subject).cast(),
          )
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecMatchValidOnDate.cast(),
            arena.toCFDate(validOn).cast(),
          )
          ..CFDictionaryAddValue(
            dict,
            _securityFramework.kSecReturnRef.cast(),
            _securityFramework.kCFBooleanTrue.cast(),
          );

        final typeRef = arena<CFTypeRef>();
        final result = _securityFramework.SecItemCopyMatching(dict, typeRef);
        switch (result) {
          case errSecSuccess:
            return SecIdentity(
              _securityFramework,
              typeRef.cast<SecIdentityRef>().value,
            );
          case errSecItemNotFound:
            return null;
          default:
            throw SecurityException.fromOsStatus(_securityFramework, result);
        }
      });

  Uint8List export(SecIdentity identity, String passphrase) =>
      _securityFramework.withArena((arena) {
        final pfx = arena<CFDataRef>();
        final params = arena<SecItemImportExportKeyParameters>();
        params.ref
          ..version = _secItemImportExportKeyParametersVersion
          ..flagsAsInt = 0
          ..passphrase = arena.toCFString(passphrase).cast();

        final result = _securityFramework.SecItemExport(
          identity.ref.cast(),
          SecExternalFormat.kSecFormatPKCS12,
          SecItemImportExportFlags.none,
          params,
          pfx,
        );
        if (result != errSecSuccess) {
          throw SecurityException.fromOsStatus(_securityFramework, result);
        }

        return _securityFramework.CFDataGetBytePtr(pfx.value)
            .cast<Uint8>()
            .asTypedList(
              _securityFramework.CFDataGetLength(pfx.value),
              finalizer: _securityFramework.CFReleasePtr,
              token: pfx.value.cast(),
            );
      });
}
