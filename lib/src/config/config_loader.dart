import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../cli/dependencies.dart';
import 'models/upload_cache.dart';
import 'models/xport_config.dart';

@module
abstract class ConfigModule {
  @singleton
  @preResolve
  Future<XPortConfig> config(ConfigLoader configLoader) async =>
      await configLoader.load();
}

@injectable
class ConfigLoader {
  final Directory projectDir;

  ConfigLoader(
    @projectDirRef this.projectDir,
  );

  Future<XPortConfig> load() async {
    final configFile = _getConfigFile();
    final configString = await configFile.readAsString();

    YamlMap configYaml;
    try {
      final yamlNode = loadYamlNode(configString, sourceUrl: configFile.uri);
      if (yamlNode is! YamlMap) {
        throw ParsedYamlException('Not a map', yamlNode);
      }
      configYaml = yamlNode;
    } on YamlException catch (e, s) {
      Error.throwWithStackTrace(ParsedYamlException.fromYamlException(e), s);
    }

    try {
      return XPortConfig.fromYaml(configYaml);
    } on CheckedFromJsonException catch (e, s) {
      Error.throwWithStackTrace(
        toParsedYamlException(e, exceptionMap: configYaml),
        s,
      );
    }
  }

  Future<void> updateCache(UploadCache cache) async {
    final configFile = _getConfigFile();
    final configString = await configFile.readAsString();
    final editor = YamlEditor(configString)..update(['cache'], cache);
    await configFile.writeAsString(editor.toString());
  }

  File _getConfigFile() => File.fromUri(projectDir.uri.resolve('.xport.yaml'));
}
