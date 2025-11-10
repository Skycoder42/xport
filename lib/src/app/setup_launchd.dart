import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../apis/process/process_runner.dart';
import '../cli/options.dart';

class SetupLaunchd {
  static const _agentId = 'de.skycoder42.xport';
  static const _argumentsReplaceKey = '%{ARGUMENTS_PLACEHOLDER}';
  static const _logsDirReplaceKey = '%{LOGS_DIR_PLACEHOLDER}';
  static const _flutterPathReplaceKey = '%{FLUTTER_PATH_PLACEHOLDER}';
  static const _notifierPathReplaceKey = '%{NOTIFIER_PATH_PLACEHOLDER}';

  final ProcessRunner _processRunner;
  final _logger = Logger('SetupLaunchd');

  SetupLaunchd() : _processRunner = ProcessRunner();

  Future<void> setup(Options options) async {
    final home = Platform.environment['HOME']!;
    final pubCache =
        Platform.environment['PUB_CACHE'] ?? path.join(home, '.pub-cache');

    final logsDir = path.join(home, 'Library/Logs/xport');
    await Directory(logsDir).create(recursive: true);

    final flutterPath = await _getExecutableDirectory('flutter');
    final notifierPath = await _getExecutableDirectory('terminal-notifier');

    final arguments = [
      path.canonicalize(path.join(pubCache, 'bin', 'xport')),
      ..._mapArguments(options),
    ].map(_createArgument).join('\n');

    final launchFile = File(
      path.join(home, 'Library/LaunchAgents', '$_agentId.plist'),
    );
    final launchConfig = _launchConfigTemplate
        .replaceAll(_argumentsReplaceKey, arguments)
        .replaceAll(_logsDirReplaceKey, logsDir)
        .replaceAll(_flutterPathReplaceKey, flutterPath)
        .replaceAll(_notifierPathReplaceKey, notifierPath);
    await launchFile.writeAsString(launchConfig, flush: true);
    _logger.fine('Created launch agent at ${launchFile.path}');

    await _processRunner.run('launchctl', ['unload', launchFile.path]);
    await _processRunner.run('launchctl', ['load', launchFile.path]);
    _logger.fine('Reloaded launchd agent');
  }

  Iterable<String> _mapArguments(Options options) sync* {
    for (final projectDir in options.projectDirs) {
      yield '--project-dir';
      yield path.canonicalize(projectDir);
    }
    yield '--log-level';
    yield options.logLevel.name;
  }

  String _createArgument(String arg) => '    <string>$arg</string>';

  Future<String> _getExecutableDirectory(String name) async {
    final location = await _processRunner.streamLines('which', [name]).single;
    return path.canonicalize(path.dirname(location));
  }

  static const _launchConfigTemplate =
      '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$_agentId</string>
  <key>ProgramArguments</key>
  <array>
$_argumentsReplaceKey
  </array>
  <key>ProcessType</key>
  <string>Background</string>
  <key>StandardErrorPath</key>
  <string>$_logsDirReplaceKey/err.log</string>
  <key>StandardOutPath</key>
  <string>$_logsDirReplaceKey/out.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>$_flutterPathReplaceKey:$_notifierPathReplaceKey:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin</string>
  </dict>
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
