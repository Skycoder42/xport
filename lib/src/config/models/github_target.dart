// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'yaml_serializable.dart';

part 'github_target.freezed.dart';
part 'github_target.g.dart';

@Freezed(unionKey: 'type')
sealed class GitHubTarget with _$GitHubTarget {
  @yamlSerializable
  const factory GitHubTarget.org(
    @yamlRequired String org,
  ) = GitHubTargetOrg;

  @yamlSerializable
  const factory GitHubTarget.repo(
    @yamlRequired String owner,
    @yamlRequired String repo,
  ) = GitHubTargetRepo;

  @yamlSerializable
  const factory GitHubTarget.env(
    @yamlRequired String owner,
    @yamlRequired String repo,
    @yamlRequired String env,
  ) = GitHubTargetEnv;

  factory GitHubTarget.fromJson(Map<String, dynamic> json) =>
      _$GitHubTargetFromJson(json);
}
