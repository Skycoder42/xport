import 'dart:ffi';

import '../ffi/security_framework.dart';

abstract base class CFType<T extends Pointer<NativeType>>(final T ref)
    implements Finalizable {
  static final _nativeFinalizer = NativeFinalizer(Native.addressOf(CFRelease));

  this {
    _nativeFinalizer.attach(this, ref.cast(), detach: this);
  }

  void dispose() {
    _nativeFinalizer.detach(this);
    CFRelease(ref.cast());
  }
}
