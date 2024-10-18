import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_id.freezed.dart';

@Freezed(toJson: false, fromJson: false)
sealed class KeyId with _$KeyId {
  const factory KeyId(String keyId) = _KeyId;

  factory KeyId.fromJson(String json) => _KeyId(json);

  const KeyId._();

  String toJson() => keyId;
}
