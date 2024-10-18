import 'dart:ffi';

import 'package:injectable/injectable.dart';

import 'ffi/cf_arena.dart';
import 'ffi/security_framework.dart';
import 'models/sec_identity.dart';

@injectable
class Security {
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
            throw arena.toSecurityException(result);
        }
      });
}
