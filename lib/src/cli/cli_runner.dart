import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:args/args.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import '../app/xporter.dart';
import '../logging/console_log_consumer.dart';
import '../logging/dev_log_consumer.dart';
import 'dependencies.config.dart';
import 'options.dart';
import 'options_module.dart';

class CliRunner {
  final GetIt _di;
  final _logger = Logger('CliRunner');

  CliRunner([GetIt? di]) : _di = di ?? GetIt.I;

  Future<void> call(List<String> args) async {
    _configureLoggingPre();
    try {
      final options = _parseArgs(args);
      _configureLoggingPost(options);
      await _configureDi(options);

      await _di.get<XPorter>().updateSecrets();

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.shout('Unhandled exception', e, s);
    }
  }

  Options _parseArgs(List<String> args) {
    final parser = ArgParser(
      usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null,
    )..configure();

    final result = parser.parse(args);
    if (result['help'] as bool) {
      stdout.writeln(parser.usage);
      exit(0);
    }

    return result.toOptions();
  }

  void _configureLoggingPre() {
    final logConsumer = extensionStreamHasListener
        ? const DevLogConsumer()
        : const ConsoleLogConsumer();

    Logger.root.level = Level.WARNING;
    unawaited(Logger.root.onRecord.pipe(logConsumer));
  }

  void _configureLoggingPost(Options options) {
    Logger.root.level = options.logLevel;
  }

  Future<void> _configureDi(Options options) async {
    setOptions(options);
    await _di.init();
  }
}
