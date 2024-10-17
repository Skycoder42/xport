import 'dart:ffi';

import '../ffi/security_framework.dart';

abstract class CFType<T extends Pointer<NativeType>> implements Finalizable {
  static final _nativeFinalizers = Expando<NativeFinalizer>(
    'CFType._nativeFinalizers',
  );

  final SecurityFramework securityFramework;
  final T ref;

  NativeFinalizer get _nativeFinalizer =>
      _nativeFinalizers[securityFramework] ??=
          NativeFinalizer(securityFramework.CFReleasePtr);

  CFType(this.securityFramework, this.ref) {
    _nativeFinalizer.attach(this, ref.cast(), detach: this);
  }

  void dispose() {
    _nativeFinalizer.detach(this);
    securityFramework.CFRelease(ref.cast());
  }
}
