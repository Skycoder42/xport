import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.constructor})
class BinaryConverter implements JsonConverter<Uint8List, String> {
  const BinaryConverter();

  @override
  Uint8List fromJson(String json) => base64.decode(json);

  @override
  String toJson(Uint8List object) => base64.encode(object);
}
