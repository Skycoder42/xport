import 'dart:io';

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:logging/logging.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(
    name: 'project-dir',
    abbr: 'd',
    valueHelp: 'path',
    help:
        'The directories of the flutter projects to '
        'extract the signing data from.',
    provideDefaultToOverride: true,
  )
  final List<String> projectDirs;

  @CliOption(
    negatable: false,
    help:
        'If specified, generate a launchd agent for the given projects '
        'and log level.',
  )
  final bool setupLaunchd;

  @CliOption(
    abbr: 'l',
    convert: _stringToLevel,
    allowed: [
      'ALL',
      'FINEST',
      'FINER',
      'FINE',
      'CONFIG',
      'INFO',
      'WARNING',
      'SEVERE',
      'SHOUT',
      'OFF',
    ],
    defaultsTo: 'INFO',
    valueHelp: 'level',
    help: 'The logging level to use.',
    provideDefaultToOverride: true,
  )
  final Level logLevel;

  @CliOption(abbr: 'h', negatable: false, help: 'Show this help.')
  final bool help;

  const Options({
    required this.projectDirs,
    required this.logLevel,
    this.setupLaunchd = false,
    this.help = false,
  });
}

extension ArgParserX on ArgParser {
  void configure() {
    String? defaultLevelOverride;
    // ignore: prefer_asserts_with_message for debug only code
    assert(() {
      defaultLevelOverride = Level.ALL.name;
      return true;
    }());
    _$populateOptionsParser(
      this,
      projectDirsDefaultOverride: [Directory.current.path],
      logLevelDefaultOverride: defaultLevelOverride,
    );
  }
}

extension ArgResultsX on ArgResults {
  Options toOptions() => _$parseOptionsResult(this);
}

Level _stringToLevel(String name) =>
    Level.LEVELS.singleWhere((l) => l.name == name);
