import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../util/converters/binary_converter.dart';
import 'key_id.dart';

part 'public_key.freezed.dart';
part 'public_key.g.dart';

@freezed
sealed class PublicKey with _$PublicKey {
  @BinaryConverter()
  const factory({
    @JsonKey(name: 'key_id') required KeyId keyId,
    required Uint8List key,
  }) = _PublicKey;

  factory fromJson(Map<String, dynamic> json) => _$PublicKeyFromJson(json);
}
