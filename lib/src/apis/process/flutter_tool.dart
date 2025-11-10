import 'dart:io';

import 'package:injectable/injectable.dart';

import 'process_runner.dart';

enum FlutterBuildMode {
  debug('--debug'),
  profile('--profile'),
  release('--release');

  final String option;

  const FlutterBuildMode(this.option);
}

@injectable
class FlutterTool {
  final ProcessRunner _processRunner;

  FlutterTool(this._processRunner);

  Future<void> pub(String command, {Directory? workingDirectory}) =>
      _run(['pub', command], workingDirectory: workingDirectory);

  Future<void> build(
    String buildTarget, {
    bool configOnly = false,
    FlutterBuildMode mode = FlutterBuildMode.release,
    File? target,
    Directory? workingDirectory,
  }) => _run(
    ['build', buildTarget],
    options: {
      mode.option: null,
      if (configOnly) '--config-only': null,
      if (target != null) '--target': target.path,
    },
    workingDirectory: workingDirectory,
  );

  Future<void> _run(
    List<String> command, {
    Map<String, String?> options = const {},
    Directory? workingDirectory,
  }) => _processRunner.run('flutter', [
    ...command,
    for (final MapEntry(key: option, value: value) in options.entries) ...[
      option,
      ?value,
    ],
  ], workingDirectory: workingDirectory);
}
