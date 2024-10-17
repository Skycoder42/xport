import 'dart:async';
import 'dart:developer';

import 'package:logging/logging.dart';

class DevLogConsumer implements StreamConsumer<LogRecord> {
  const DevLogConsumer();

  @override
  Future<void> addStream(Stream<LogRecord> stream) async {
    await for (final logRecord in stream) {
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
    }
  }

  @override
  Future<void> close() => Future.value();
}
