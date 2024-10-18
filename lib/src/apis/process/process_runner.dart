import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

@injectable
class ProcessRunner {
  final _logger = Logger('ProcessRunner');

  Stream<String> streamLines(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
  }) async* {
    _logger.finer('Running $executable ${arguments.join(' ')}');
    final proc = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
    );
    final stderrSub = proc.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(stderr.writeln);
    try {
      yield* proc.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      final exitCode = await proc.exitCode;
      _logger.finest('$executable finished with exit code $exitCode');
      if (exitCode != 0) {
        throw ProcessException(
          executable,
          arguments,
          'Process failed with exit code $exitCode',
          exitCode,
        );
      }
    } finally {
      await stderrSub.cancel();
    }
  }

  Future<void> run(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
  }) async =>
      await streamLines(
        executable,
        arguments,
        workingDirectory: workingDirectory,
      ).drain();
}
