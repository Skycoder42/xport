// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters/binary_converter.dart';
import 'key_id.dart';

part 'encrypted_secret.freezed.dart';
part 'encrypted_secret.g.dart';

@freezed
sealed class EncryptedSecret with _$EncryptedSecret {
  @BinaryConverter()
  const factory EncryptedSecret({
    @JsonKey(name: 'key_id') required KeyId keyId,
    @JsonKey(name: 'encrypted_value') required Uint8List encryptedValue,
  }) = _EncryptedSecret;

  factory EncryptedSecret.fromJson(Map<String, dynamic> json) =>
      _$EncryptedSecretFromJson(json);

  const EncryptedSecret._();

  @override
  // ignore: unnecessary_overrides
  Map<String, dynamic> toJson() => super.toJson();
}
