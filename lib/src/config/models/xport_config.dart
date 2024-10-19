// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

import 'github_target.dart';
import 'upload_cache.dart';
import 'yaml_serializable.dart';

part 'xport_config.freezed.dart';
part 'xport_config.g.dart';

@freezed
sealed class XPortConfig with _$XPortConfig {
  @yamlSerializable
  const factory XPortConfig({
    @yamlKey required GitHubTarget target,
    @yamlKey required String accessToken,
    UploadCache? cache,
  }) = _XPortConfig;

  factory XPortConfig.fromYaml(YamlMap yaml) =>
      XPortConfig.fromJson(yaml.cast());

  factory XPortConfig.fromJson(Map<String, dynamic> json) =>
      _$XPortConfigFromJson(json);
}
