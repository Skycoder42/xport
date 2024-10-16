import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import '../logging/log_consumer.dart';
import 'dependencies.config.dart';
import 'dependencies.dart';
import 'options.dart';

class CliRunner {
  final GetIt _di;

  CliRunner([GetIt? di]) : _di = di ?? GetIt.I;

  Future<void> call(List<String> args) async {
    final options = _parseArgs(args);
    _configureLogging(options);
    _configureDi(options);
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

  void _configureLogging(Options options) {
    Logger.root.level = options.logLevel;
    unawaited(Logger.root.onRecord.pipe(const LogConsumer()));
  }

  void _configureDi(Options options) {
    _di
      ..registerSingleton(
        options.accessToken,
        instanceName: gitHubAccessToken.name,
      )
      ..init();
  }
}
