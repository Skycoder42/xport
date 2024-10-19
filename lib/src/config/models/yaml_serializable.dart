import 'package:freezed_annotation/freezed_annotation.dart';

const yamlSerializable = JsonSerializable(
  checked: true,
  anyMap: true,
  disallowUnrecognizedKeys: true,
);

const yamlKey = JsonKey(required: true, disallowNullValue: true);
