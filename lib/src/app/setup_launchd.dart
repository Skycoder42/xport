import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../apis/process/process_runner.dart';
import '../cli/options.dart';

class SetupLaunchd {
  static const _agentId = 'de.skycoder42.xport';
  static const _templateReplaceKey = '%{ARGUMENTS_PLACEHOLDER}';

  final ProcessRunner _processRunner;
  final _logger = Logger('SetupLaunchd');

  SetupLaunchd() : _processRunner = ProcessRunner();

  Future<void> setup(Options options) async {
    final home = Platform.environment['HOME']!;
    final launchFile = File(
      path.join(
        home,
        'Library/LaunchAgents',
        '$_agentId.plist',
      ),
    );
    final launchConfig = _launchConfigTemplate.replaceFirst(
      _templateReplaceKey,
      _mapArguments(options).join('\n'),
    );
    await launchFile.writeAsString(launchConfig, flush: true);
    _logger.fine('Created launch agent at ${launchFile.path}');

    await _processRunner.run('launchctl', ['unload', launchFile.path]);
    await _processRunner.run('launchctl', ['load', launchFile.path]);
    _logger.fine('Reloaded launchd agent');
  }

  Iterable<String> _mapArguments(Options options) sync* {
    for (final projectDir in options.projectDirs) {
      yield _createArgument('--project-dir');
      yield _createArgument(path.canonicalize(projectDir));
    }
    yield _createArgument('--log-level');
    yield _createArgument(options.logLevel.name);
  }

  String _createArgument(String arg) => '		<string>$arg</string>';

  static final _launchConfigTemplate = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$_agentId</string>
	<key>Program</key>
  <string>${Platform.resolvedExecutable}</string>
	<key>ProgramArguments</key>
	<array>
$_templateReplaceKey
	</array>
	<key>ProcessType</key>
	<string>Background</string>
	<key>StandardErrorPath</key>
	<string>\$HOME/Library/Logs/xport/err.log</string>
	<key>StandardOutPath</key>
	<string>\$HOME/Library/Logs/xport/out.log</string>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>10</integer>
    <key>Minute</key>
    <integer>30</integer>
  </dict>
</dict>
</plist>
''';
}
