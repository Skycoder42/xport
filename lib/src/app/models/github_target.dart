import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_target.freezed.dart';

@freezed
sealed class GitHubTarget with _$GitHubTarget {
  const factory GitHubTarget.org(String org) = GitHubTargetOrg;
  const factory GitHubTarget.repo(String owner, String repo) = GitHubTargetRepo;
  const factory GitHubTarget.env(String owner, String repo, String env) =
      GitHubTargetEnv;
}
