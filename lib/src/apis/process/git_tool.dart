import 'dart:io';

import 'package:injectable/injectable.dart';

import 'process_runner.dart';

@injectable
class GitTool {
  final ProcessRunner _processRunner;

  GitTool(this._processRunner);

  Future<void> pull({Directory? workingDirectory}) => _processRunner.run(
    'git',
    const ['pull'],
    workingDirectory: workingDirectory,
  );
}
