import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../apis/process/flutter_tool.dart';
import '../apis/process/git_tool.dart';
import '../apis/process/xcode_build_tool.dart';
import '../cli/dependencies.dart';
import 'models/signing_config.dart';
import 'models/signing_config_missing_exception.dart';
import 'setup_runner.dart';

@injectable
class SigningConfigLoader {
  static final _signingIdRegExp = RegExp(r'Signing Identity:\s+"(.*)"');
  static final _provisioningProfileIdRegExp = RegExp(
    r'\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)',
    caseSensitive: false,
  );

  final GitTool _gitTool;
  final SetupRunner _setupRunner;
  final FlutterTool _flutterTool;
  final XCodeBuildTool _xCodeBuildTool;
  final Directory _projectDir;
  final _logger = Logger('SigningConfigLoader');

  SigningConfigLoader(
    this._gitTool,
    this._setupRunner,
    this._flutterTool,
    this._xCodeBuildTool,
    @projectDirRef this._projectDir,
  );

  Future<void> configureProject() async {
    _logger.info('Pulling and updating project configuration');
    await _gitTool.pull(workingDirectory: _projectDir);
    await _setupRunner.runSetupScript(workingDirectory: _projectDir);
    await _flutterTool.pub('get', workingDirectory: _projectDir);
    await _flutterTool.build(
      'ios',
      configOnly: true,
      workingDirectory: _projectDir,
    );
  }

  Future<SigningConfig> getBuildConfig() async {
    _logger.info('Collecting signing information for primary target');
    final lines = _xCodeBuildTool(
      command: 'build',
      scheme: 'Runner',
      workspace: 'Runner.xcworkspace',
      allowProvisioningUpdates: true,
      workingDirectory: Directory.fromUri(_projectDir.uri.resolve('ios')),
    );

    var nextIsProfileId = false;
    String? signingIdentity;
    String? profileId;
    await for (final line in lines) {
      if (nextIsProfileId) {
        nextIsProfileId = false;
        final match = _provisioningProfileIdRegExp.firstMatch(line);
        if (match != null) {
          _logger.fine('Found Provisioning Profile: ${match[1]}');
          profileId = match[1];
        }
      } else if (_signingIdRegExp.firstMatch(line) case final Match match) {
        _logger.fine('Found Signing Identity: ${match[1]}');
        signingIdentity = match[1];
      } else if (line.contains('Provisioning Profile')) {
        nextIsProfileId = true;
      }
    }

    if (signingIdentity == null) {
      throw SigningConfigMissingException.build(
        SigningConfigKind.signingIdentity,
      );
    }
    if (profileId == null) {
      throw SigningConfigMissingException.build(
        SigningConfigKind.provisioningProfile,
      );
    }

    return SigningConfig(
      signingIdentity: signingIdentity,
      provisioningProfileId: profileId,
    );
  }
}
