import 'dart:io';

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:logging/logging.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  static const _accessTokenEnvVar = 'GITHUB_ACCESS_TOKEN';

  @CliOption(
    abbr: 't',
    valueHelp: 'token',
    help: 'The personal access <token> that should be used access GitHub. '
        'If not specified, the tool looks for an environment variable named '
        '"$_accessTokenEnvVar".',
    provideDefaultToOverride: true,
  )
  final String accessToken;

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

  @CliOption(
    abbr: 'h',
    negatable: false,
    help: 'Show this help.',
  )
  final bool help;

  const Options({
    required this.accessToken,
    required this.logLevel,
    this.help = false,
  });
}

extension ArgParserX on ArgParser {
  void configure() {
    String? defaultLevelOverride;
    assert(() {
      defaultLevelOverride = Level.ALL.name;
      return true;
    }());
    _$populateOptionsParser(
      this,
      accessTokenDefaultOverride:
          Platform.environment[Options._accessTokenEnvVar],
      logLevelDefaultOverride: defaultLevelOverride,
    );
  }
}

extension ArgResultsX on ArgResults {
  Options toOptions() => _$parseOptionsResult(this);
}

Level _stringToLevel(String name) =>
    Level.LEVELS.singleWhere((l) => l.name == name);
