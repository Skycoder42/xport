import 'dart:ffi';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:sodium/sodium.dart';

@module
abstract class SodiumModule {
  @singleton
  @preResolve
  Future<Sodium> get sodium => SodiumInit.init(() {
    final homebrewPrefix =
        Platform.environment['HOMEBREW_PREFIX'] ?? '/opt/homebrew';
    return DynamicLibrary.open('$homebrewPrefix/lib/libsodium.dylib');
  });
}
