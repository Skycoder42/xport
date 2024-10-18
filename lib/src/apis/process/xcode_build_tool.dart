import 'dart:io';

import 'package:injectable/injectable.dart';

import 'process_runner.dart';

enum XCodeBuildMode {
  debug('Debug'),
  profile('Profile'),
  release('Release');

  final String value;

  const XCodeBuildMode(this.value);
}

enum XCodeBuildSDK {
  iPhoneOs('iphoneos'),
  iPhoneSimulator('iphonesimulator'),
  macOsx('macosx');

  final String value;

  const XCodeBuildSDK(this.value);
}

@injectable
class XCodeBuildTool {
  final ProcessRunner _processRunner;

  XCodeBuildTool(this._processRunner);

  Stream<String> call({
    required String command,
    required String workspace,
    required String scheme,
    XCodeBuildMode configuration = XCodeBuildMode.release,
    XCodeBuildSDK sdk = XCodeBuildSDK.iPhoneOs,
    String? derivedDataPath,
    Directory? workingDirectory,
  }) =>
      _processRunner.streamLines(
        'xcodebuild',
        [
          command,
          '-workspace',
          workspace,
          '-scheme',
          scheme,
          '-configuration',
          configuration.value,
          '-sdk',
          sdk.value,
          if (derivedDataPath != null) ...[
            '-derivedDataPath',
            derivedDataPath,
          ],
        ],
        workingDirectory: workingDirectory,
      );
}
