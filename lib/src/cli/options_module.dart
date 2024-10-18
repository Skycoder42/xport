import 'package:args/args.dart';
import 'package:injectable/injectable.dart';

import '../app/models/github_target.dart';
import 'dependencies.dart';
import 'options.dart';

void setOptions(Options options) => OptionsModule._options = options;

@module
abstract class OptionsModule {
  static late final Options _options;

  @injectable
  @accessToken
  String get accessTokenRef => _options.accessToken;

  @injectable
  @projectDir
  String get projectDirRef => _options.projectDir;

  @injectable
  @gitHubTarget
  GitHubTarget get gitHubTargetRef {
    switch (_options.secretsTarget) {
      case GithubSecretsTarget.org:
        if (_options.org case final String org) {
          return GitHubTarget.org(org);
        }

        throw ArgParserException(
          'Argument "org" is required if "secrets-target" is set to "org"',
          null,
          'org',
        );
      case GithubSecretsTarget.repo:
        final (owner, repo) = _splitRepoSlug();
        return GitHubTarget.repo(owner, repo);
      case GithubSecretsTarget.env:
        final (owner, repo) = _splitRepoSlug();
        if (_options.env case final String env) {
          return GitHubTarget.env(owner, repo, env);
        }

        throw ArgParserException(
          'Argument "env" is required if "secrets-target" is set to "env"',
          null,
          'env',
        );
    }
  }

  (String, String) _splitRepoSlug() {
    if (_options.repoSlug case final String repoSlug) {
      final segments = repoSlug.split('/');
      if (segments.length != 2) {
        throw ArgParserException(
          'Argument "repo-slug" must be in the format "<owner>/<repo>"',
          null,
          'repo-slug',
        );
      }

      final [owner, repo] = segments;
      return (owner, repo);
    }

    throw ArgParserException(
      'Argument "repo-slug" is required if "secrets-target" is set to "repo"',
      null,
      'repo-slug',
    );
  }
}
