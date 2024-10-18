import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../models/cf_exception.dart';
import '../models/security_exception.dart';
import 'security_framework.dart';

class CFArena extends Arena {
  final SecurityFramework securityFramework;

  CFArena(this.securityFramework);

  Pointer<T> autoRelease<T extends NativeType>(Pointer<T> ref) =>
      this.using<CFTypeRef>(ref.cast(), securityFramework.CFRelease).cast();

  CFException toCFException(CFErrorRef cfError) {
    final code = securityFramework.CFErrorGetCode(cfError);
    final reason =
        autoRelease(securityFramework.CFErrorCopyFailureReason(cfError));
    final description =
        autoRelease(securityFramework.CFErrorCopyDescription(cfError));
    return CFException(code, toDartString(reason), toDartString(description));
  }

  SecurityException toSecurityException(int osStatus) {
    final message = autoRelease(
      securityFramework.SecCopyErrorMessageString(osStatus, nullptr),
    );
    return SecurityException(osStatus, toDartString(message));
  }

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

  Uint8List toUint8List(CFDataRef cfData) =>
      securityFramework.CFDataGetBytePtr(cfData).cast<Uint8>().asTypedList(
            securityFramework.CFDataGetLength(cfData),
            finalizer: securityFramework.CFReleasePtr,
            token: cfData.cast(),
          );

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
