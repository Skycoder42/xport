import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../models/cf_exception.dart';
import '../models/security_exception.dart';
import 'security_framework.dart';

class CFArena extends Arena {
  CFArena();

  Pointer<T> autoRelease<T extends NativeType>(Pointer<T> ref) =>
      this.using<CFTypeRef>(ref.cast(), CFRelease).cast();

  CFException toCFException(CFErrorRef cfError) {
    final code = CFErrorGetCode(cfError);
    final reason = autoRelease(CFErrorCopyFailureReason(cfError));
    final description = autoRelease(CFErrorCopyDescription(cfError));
    return CFException(code, toDartString(reason), toDartString(description));
  }

  SecurityException toSecurityException(int osStatus) {
    final message = autoRelease(SecCopyErrorMessageString(osStatus, nullptr));
    return SecurityException(osStatus, toDartString(message));
  }

  String toDartString(CFStringRef cfString) {
    final bufferSize =
        CFStringGetMaximumSizeForEncoding(
          CFStringGetLength(cfString),
          CFStringBuiltInEncodings.kCFStringEncodingUTF8.value,
        ) +
        1;
    final buffer = this<Char>(bufferSize);
    final result = CFStringGetCString(
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
      CFDataGetBytePtr(cfData).cast<Uint8>().asTypedList(
        CFDataGetLength(cfData),
        finalizer: Native.addressOf(CFRelease),
        token: cfData.cast(),
      );

  CFStringRef toCFString(String string) => autoRelease(
    CFStringCreateWithCString(
      nullptr,
      string.toNativeUtf8(allocator: this).cast(),
      CFStringBuiltInEncodings.kCFStringEncodingUTF8.value,
    ),
  );

  CFDateRef toCFDate(DateTime date) => autoRelease(
    CFDateCreate(
      nullptr,
      date.difference(DateTime.utc(2001)).inSeconds.toDouble(),
    ),
  );
}

T withArena<T>(T Function(CFArena arena) callback) {
  if (T case Future()) {
    throw UnsupportedError('withArena cannot be used for async operations');
  }

  final arena = CFArena();
  try {
    return callback(arena);
  } finally {
    arena.releaseAll();
  }
}
