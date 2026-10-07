import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../util/converters/binary_converter.dart';
import 'key_id.dart';

part 'encrypted_secret.freezed.dart';
part 'encrypted_secret.g.dart';

@freezed
sealed class const EncryptedSecret._() with _$EncryptedSecret {
  @BinaryConverter()
  const factory({
    @JsonKey(name: 'key_id') required KeyId keyId,
    @JsonKey(name: 'encrypted_value') required Uint8List encryptedValue,
  }) = _EncryptedSecret;

  factory fromJson(Map<String, dynamic> json) =>
      _$EncryptedSecretFromJson(json);

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError();
}
