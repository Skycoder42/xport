import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class ConsoleLogConsumer implements StreamConsumer<LogRecord> {
  const ConsoleLogConsumer();

  @override
  Future<void> addStream(Stream<LogRecord> stream) async {
    await for (final logRecord in stream) {
      final pen = switch (logRecord.level) {
        >= Level.SHOUT => AnsiPen()..magenta(),
        >= Level.SEVERE => AnsiPen()..red(),
        >= Level.WARNING => AnsiPen()..yellow(),
        >= Level.INFO => AnsiPen()..blue(),
        >= Level.CONFIG => AnsiPen()..cyan(),
        >= Level.FINE => AnsiPen()..green(),
        >= Level.FINER => AnsiPen()..white(),
        >= Level.FINEST => AnsiPen()..gray(),
        _ => AnsiPen(),
      };

      stdout.writeln(pen(logRecord));
      if (logRecord.error case final Object error) {
        stdout.writeln(pen(error));
      }
      if (logRecord.stackTrace case final StackTrace stackTrace) {
        stdout.writeln(pen(stackTrace));
      }
    }
  }

  @override
  Future<void> close() => Future.value();
}
