import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'security_framework.dart';

class CFArena extends Arena {
  final SecurityFramework securityFramework;

  CFArena(this.securityFramework);

  Pointer<T> autoRelease<T extends NativeType>(Pointer<T> ref) =>
      this.using<CFTypeRef>(ref.cast(), securityFramework.CFRelease).cast();

  String toDartString(CFStringRef cfString) {
    final bufferSize = securityFramework.CFStringGetMaximumSizeForEncoding(
          securityFramework.CFStringGetLength(cfString),
          CFStringBuiltInEncodings.kCFStringEncodingUTF8.value,
        ) +
        1;
    final buffer = this<Char>(bufferSize);
    final result = securityFramework.CFStringGetCString(
      cfString,
      buffer,
      bufferSize,
      CFStringBuiltInEncodings.kCFStringEncodingUTF8.value,
    );
    if (result == 0) {
      return '';
    }
    return buffer.cast<Utf8>().toDartString();
  }

  CFStringRef toCFString(String string) => autoRelease(
        securityFramework.CFStringCreateWithCString(
          nullptr,
          string.toNativeUtf8(allocator: this).cast(),
          CFStringBuiltInEncodings.kCFStringEncodingUTF8.value,
        ),
      );

  CFDateRef toCFDate(DateTime date) => autoRelease(
        securityFramework.CFDateCreate(
          nullptr,
          date.difference(DateTime.utc(2001)).inSeconds.toDouble(),
        ),
      );
}

extension SecurityFrameworkX on SecurityFramework {
  T withArena<T>(T Function(CFArena arena) callback) {
    if (T case Future()) {
      throw UnsupportedError('withArena cannot be used for async operations');
    }

    final arena = CFArena(this);
    try {
      return callback(arena);
    } finally {
      arena.releaseAll();
    }
  }
}
