import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:retrofit/retrofit.dart';

class LoggingParserErrorLogger implements ParseErrorLogger {
  final Logger _logger;

  LoggingParserErrorLogger(String name) : _logger = Logger(name);

  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options,
  ) =>
      _logger.severe(
        'Failed to decode ${options.responseType.name} response',
        error,
        stackTrace,
      );
}
