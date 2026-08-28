// ignore_for_file: invalid_annotation_target for freezed

import 'package:freezed_annotation/freezed_annotation.dart';

import 'yaml_serializable.dart';

part 'github_target.freezed.dart';
part 'github_target.g.dart';

@Freezed(unionKey: 'type')
sealed class GitHubTarget with _$GitHubTarget {
  @yamlSerializable
  const factory org(@yamlRequired String org) = GitHubTargetOrg;

  @yamlSerializable
  const factory repo(@yamlRequired String owner, @yamlRequired String repo) =
      GitHubTargetRepo;

  @yamlSerializable
  const factory env(
    @yamlRequired String owner,
    @yamlRequired String repo,
    @yamlRequired String env,
  ) = GitHubTargetEnv;

  factory fromJson(Map<String, dynamic> json) => _$GitHubTargetFromJson(json);
}
