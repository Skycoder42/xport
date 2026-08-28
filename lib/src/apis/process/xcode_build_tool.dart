import 'dart:io';

import 'package:injectable/injectable.dart';

import 'process_runner.dart';

enum XCodeBuildMode {
  debug('Debug'),
  profile('Profile'),
  release('Release');

  final String value;

  new(this.value);
}

enum XCodeBuildSDK {
  iPhoneOs('iphoneos'),
  iPhoneSimulator('iphonesimulator'),
  macOsx('macosx');

  final String value;

  new(this.value);
}

@injectable
class XCodeBuildTool {
  final ProcessRunner _processRunner;

  new(this._processRunner);

  Stream<String> call({
    required String command,
    required String workspace,
    required String scheme,
    XCodeBuildMode configuration = XCodeBuildMode.release,
    XCodeBuildSDK sdk = XCodeBuildSDK.iPhoneOs,
    String destination = 'generic/platform=iOS',
    String? derivedDataPath,
    bool allowProvisioningUpdates = false,
    Directory? workingDirectory,
  }) => _processRunner.streamLines('xcodebuild', [
    command,
    '-workspace',
    workspace,
    '-scheme',
    scheme,
    '-configuration',
    configuration.value,
    '-sdk',
    sdk.value,
    '-destination',
    destination,
    if (derivedDataPath != null) ...['-derivedDataPath', derivedDataPath],
    if (allowProvisioningUpdates) '-allowProvisioningUpdates',
  ], workingDirectory: workingDirectory);
}
