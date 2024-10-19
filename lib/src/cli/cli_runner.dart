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
import 'project_module.dart';

class CliRunner {
  final _logger = Logger('CliRunner');

  CliRunner();

  Future<void> call(List<String> args) async {
    final options = await _parseArguments(args);
    var failCnt = 0;
    for (final projectDir in options.projectDirs) {
      if (!await _runForProject(projectDir)) {
        ++failCnt;
      }
    }
    exitCode = failCnt;
  }

  Future<Options> _parseArguments(List<String> args) async {
    try {
      _configureLoggingPre();

      final parser = ArgParser(
        usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null,
      )..configure();

      final result = parser.parse(args);
      if (result['help'] as bool) {
        stdout.writeln(parser.usage);
        exit(0);
      }

      final options = result.toOptions();
      _configureLoggingPost(options);
      return options;
    } on ArgParserException catch (e) {
      stderr.writeln(e.message);
      await stderr.flush();
      exit(127);
    }
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

  Future<bool> _runForProject(String projectDir) async {
    final di = GetIt.asNewInstance();
    try {
      _logger.info('========== Processing $projectDir ==========');

      setProjectDir(Directory(projectDir));
      await di.init();
      await di.get<XPorter>().updateSecrets();
      return true;

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.shout('Unhandled exception', e, s);
      return false;
    } finally {
      await di.reset();
    }
  }
}
