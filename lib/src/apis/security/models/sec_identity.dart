import '../ffi/security_framework.dart';
import 'cf_type.dart';

class SecIdentity extends CFType<SecIdentityRef> {
  SecIdentity(super.securityFramework, super.ref);
}
