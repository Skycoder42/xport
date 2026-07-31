#!/usr/bin/env -S dart run

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    output: Output(
      dartFile: packageRoot.resolve(
        'lib/src/apis/security/ffi/security_framework.dart',
      ),
      style: const NativeExternalBindings(
        assetId: 'package:xport/security_framework',
      ),
    ),
    headers: Headers(
      entryPoints: [
        macSdkUri.resolve(
          'System/Library/Frameworks/Security.framework/Headers/Security.h',
        ),
      ],
    ),
    functions: Functions(
      include: _includeMatching({
        'CFRelease',
        Glob('CFString*'),
        Glob('CFDate*'),
        Glob('CFDictionary*'),
        Glob('CFData*'),
        Glob('CFError*'),
        Glob('SecItem*'),
        Glob('SecIdentity*'),
        Glob('SecCertificate*'),
        'SecCopyErrorMessageString',
      }),
    ),
    structs: Structs(
      include: _includeMatching({
        Glob('CFString*'),
        Glob('CFDate*'),
        Glob('CFDictionary*'),
        Glob('CFData*'),
        Glob('CFError*'),
        Glob('SecItem*'),
        Glob('SecIdentity*'),
        Glob('SecCertificate*'),
      }),
    ),
    enums: Enums(
      include: _includeMatching({Glob('CFString*'), Glob('Sec*')}),
      silenceWarning: true,
    ),
    unnamedEnums: UnnamedEnums(include: _includeMatching({Glob('errSec*')})),
    globals: Globals(
      include: _includeMatching({
        Glob('kSec*'),
        Glob('kCFBoolean*'),
        Glob('kCFString*'),
        Glob('kCFDate*'),
        Glob('kCFDictionary*'),
        Glob('kCFData*'),
        Glob('kCFError*'),
      }),
    ),
    typedefs: Typedefs(
      include: _includeMatching({
        Glob('CFTypeRef*'),
        Glob('CFString*'),
        Glob('CFDate*'),
        Glob('CFDictionary*'),
        Glob('CFData*'),
        Glob('CFError*'),
        Glob('SecIdentity*'),
        Glob('SecCertificate*'),
      }),
    ),
    objectiveC: const ObjectiveC(),
  ).generate();
}

bool Function(Declaration declaration) _includeMatching(
  Set<Pattern> patterns,
) =>
    (declaration) => _isMatching(patterns, declaration);

bool _isMatching(Set<Pattern> patterns, Declaration declaration) {
  for (final pattern in patterns) {
    if (pattern is String) {
      if (pattern == declaration.originalName) {
        return true;
      }
    } else if (pattern.matchAsPrefix(declaration.originalName) != null) {
      return true;
    }
  }
  return false;
}
