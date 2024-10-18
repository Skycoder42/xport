import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

@injectable
class ProcessRunner {
  Stream<String> streamLines(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
  }) async* {
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
      await stderrSub.asFuture<void>();

      final exitCode = await proc.exitCode;
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
