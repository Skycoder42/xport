#!/usr/bin/env -S dart run

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve(
          'lib/src/apis/security/ffi/security_framework.dart',
        ),
      ),
      style: const NativeExternalBindings(
        assetId: 'package:xport/security_framework',
      ),
    ),
    input: Input(
      entryPoints: [
        macSdkUri.resolve(
          'System/Library/Frameworks/Security.framework/Headers/Security.h',
        ),
      ],
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = _isMatching({
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
        }, node),
        struct: (node) => node.isIncluded = _isMatching({
          Glob('CFString*'),
          Glob('CFDate*'),
          Glob('CFDictionary*'),
          Glob('CFData*'),
          Glob('CFError*'),
          Glob('SecItem*'),
          Glob('SecIdentity*'),
          Glob('SecCertificate*'),
        }, node),
        enumClass: (node) => node
          ..isIncluded = _isMatching({Glob('CFString*'), Glob('Sec*')}, node)
          ..silenceWarning = true,
        unnamedEnumConstant: (node) =>
            node.isIncluded = _isMatching({Glob('errSec*')}, node),
        global: (node) => node.isIncluded = _isMatching({
          Glob('kSec*'),
          Glob('kCFBoolean*'),
          Glob('kCFString*'),
          Glob('kCFDate*'),
          Glob('kCFDictionary*'),
          Glob('kCFData*'),
          Glob('kCFError*'),
        }, node),
        typealias: (node) => node.isIncluded =
            _isMatching({
              Glob('CFTypeRef*'),
              Glob('CFString*'),
              Glob('CFDate*'),
              Glob('CFDictionary*'),
              Glob('CFData*'),
              Glob('CFError*'),
              Glob('SecIdentity*'),
              Glob('SecCertificate*'),
            }, node)
            ? TypealiasInclude.ifUsed
            : TypealiasInclude.never,
      ),
    ],
    objectiveC: const ObjectiveC(),
  ).generate();
}

bool _isMatching(Set<Pattern> patterns, NamedNode node) {
  for (final pattern in patterns) {
    if (pattern is String) {
      if (pattern == node.originalName) {
        return true;
      }
    } else if (pattern.matchAsPrefix(node.originalName) != null) {
      return true;
    }
  }
  return false;
}
