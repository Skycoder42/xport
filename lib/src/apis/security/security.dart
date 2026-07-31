import 'dart:ffi';

import 'package:injectable/injectable.dart';

import 'ffi/cf_arena.dart';
import 'ffi/security_framework.dart';
import 'models/sec_identity.dart';

@injectable
class Security {
  SecIdentity? findIdentity({
    required String subject,
    required DateTime validOn,
  }) => withArena((arena) {
    final dict = arena.autoRelease(
      CFDictionaryCreateMutable(nullptr, 0, nullptr, nullptr),
    );

    CFDictionaryAddValue(dict, kSecClass.cast(), kSecClassIdentity.cast());
    CFDictionaryAddValue(
      dict,
      kSecUseDataProtectionKeychain.cast(),
      kCFBooleanFalse.cast(),
    );
    CFDictionaryAddValue(dict, kSecMatchLimit.cast(), kSecMatchLimitOne.cast());
    CFDictionaryAddValue(
      dict,
      kSecMatchSubjectContains.cast(),
      arena.toCFString(subject).cast(),
    );
    CFDictionaryAddValue(
      dict,
      kSecMatchValidOnDate.cast(),
      arena.toCFDate(validOn).cast(),
    );
    CFDictionaryAddValue(dict, kSecReturnRef.cast(), kCFBooleanTrue.cast());

    final typeRef = arena<CFTypeRef>();
    final result = SecItemCopyMatching(dict, typeRef);
    switch (result) {
      case errSecSuccess:
        return SecIdentity(typeRef.cast<SecIdentityRef>().value);
      case errSecItemNotFound:
        return null;
      default:
        throw arena.toSecurityException(result);
    }
  });
}
