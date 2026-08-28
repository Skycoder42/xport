import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_id.freezed.dart';

@Freezed(toJson: false, fromJson: false)
sealed class KeyId with _$KeyId {
  const factory(String keyId) = _KeyId;

  factory fromJson(String json) => _KeyId(json);

  const new _();

  String toJson() => keyId;
}
