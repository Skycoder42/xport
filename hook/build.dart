// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      switch (input.config.code.targetOS) {
        case .macOS:
          output.assets.code.add(
            CodeAsset(
              package: 'xport',
              name: 'security_framework',
              linkMode: LookupInProcess(),
            ),
          );
        case final os:
          throw UnsupportedError('Unsupported OS: ${os.name}.');
      }
    }
  });
}
