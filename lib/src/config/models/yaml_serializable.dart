import 'package:freezed_annotation/freezed_annotation.dart';

const yamlSerializable = JsonSerializable(
  checked: true,
  anyMap: true,
  disallowUnrecognizedKeys: true,
);

const yamlRequired = JsonKey(required: true, disallowNullValue: true);
