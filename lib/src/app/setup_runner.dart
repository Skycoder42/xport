import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:posix/posix.dart';

import '../apis/process/process_runner.dart';
import '../config/models/xport_config.dart';

@injectable
class SetupRunner {
  final XPortConfig _config;
  final ProcessRunner _processRunner;

  SetupRunner(
    this._config,
    this._processRunner,
  );

  Future<void> runSetupScript({Directory? workingDirectory}) async {
    final script = _config.setupScript;
    if (script == null) {
      return;
    }

    final tmpDir = await Directory.systemTemp.createTemp();
    try {
      final scriptFile = await File.fromUri(tmpDir.uri.resolve('setup.sh'))
          .create(exclusive: true);
      chmod(scriptFile.path, '700');
      await scriptFile.writeAsString(script, flush: true);
      await _processRunner.run(
        scriptFile.path,
        const [],
        workingDirectory: workingDirectory,
        runInShell: true,
      );
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }
}
