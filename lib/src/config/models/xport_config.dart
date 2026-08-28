// ignore_for_file: invalid_annotation_target for freezed

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

import 'github_target.dart';
import 'secret_names.dart';
import 'upload_cache.dart';
import 'yaml_serializable.dart';

part 'xport_config.freezed.dart';
part 'xport_config.g.dart';

@freezed
sealed class XPortConfig with _$XPortConfig {
  @yamlSerializable
  const factory({
    @yamlRequired required GitHubTarget target,
    @yamlRequired required String accessToken,
    @Default(SecretNames.defaultNames) SecretNames secrets,
    String? setupScript,
    UploadCache? cache,
  }) = _XPortConfig;

  factory fromYaml(YamlMap yaml) => XPortConfig.fromJson(yaml.cast());

  factory fromJson(Map<String, dynamic> json) => _$XPortConfigFromJson(json);
}
