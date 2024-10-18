import 'dart:io';

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:logging/logging.dart';

part 'options.g.dart';

enum GithubSecretsTarget {
  org,
  repo,
  env;
}

@CliOptions()
class Options {
  static const _accessTokenEnvVar = 'GITHUB_ACCESS_TOKEN';

  @CliOption(
    abbr: 'd',
    valueHelp: 'path',
    help: 'The directory of the flutter project to '
        'extract the signing data from.',
    provideDefaultToOverride: true,
  )
  final String projectDir;

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
    abbr: 'T',
    defaultsTo: GithubSecretsTarget.repo,
    help: 'Specify where the secret files should be uploaded to.',
  )
  final GithubSecretsTarget secretsTarget;

  @CliOption(
    abbr: 'O',
    valueHelp: 'organization',
    help: 'The GitHub organization to publish the secrets to.\n'
        '(Required if secrets-target is "org")',
  )
  final String? org;

  @CliOption(
    abbr: 'R',
    valueHelp: 'repoSlug',
    help: 'The GitHub repository slug (<owner>/<repo>) to publish the secrets '
        'to.\n(Required if secrets-target is "repo" or "env")',
  )
  final String? repoSlug;

  @CliOption(
    abbr: 'E',
    valueHelp: 'environment',
    help: 'The GitHub repository environment to publish the secrets to.\n'
        '(Required if secrets-target is "env")',
  )
  final String? env;

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
    required this.projectDir,
    required this.accessToken,
    required this.secretsTarget,
    required this.org,
    required this.repoSlug,
    required this.env,
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
      projectDirDefaultOverride: Directory.current.path,
      logLevelDefaultOverride: defaultLevelOverride,
    );
  }
}

extension ArgResultsX on ArgResults {
  Options toOptions() => _$parseOptionsResult(this);
}

Level _stringToLevel(String name) =>
    Level.LEVELS.singleWhere((l) => l.name == name);
