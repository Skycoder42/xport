import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class LogConsumer implements StreamConsumer<LogRecord> {
  const LogConsumer();

  @override
  Future<void> addStream(Stream<LogRecord> stream) async {
    await for (final logRecord in stream) {
      if (extensionStreamHasListener) {
        log(
          logRecord.message,
          error: logRecord.error,
          level: logRecord.level.value,
          name: logRecord.loggerName,
          sequenceNumber: logRecord.sequenceNumber,
          stackTrace: logRecord.stackTrace,
          time: logRecord.time,
          zone: logRecord.zone,
        );
      } else {
        final pen = switch (logRecord.level) {
          _ when !stdout.hasTerminal => AnsiPen(),
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
  }

  @override
  Future<void> close() => Future.value();
}
