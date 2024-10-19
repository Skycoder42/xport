// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'yaml_serializable.dart';

part 'secret_names.freezed.dart';
part 'secret_names.g.dart';

@freezed
sealed class SecretNames with _$SecretNames {
  static const _profileSecretDefaultName = 'PROVISIONING_PROFILE';
  static const _identitySecretDefaultName = 'SIGNING_IDENTITY';
  static const _identityPassphraseSecretDefaultName =
      'SIGNING_IDENTITY_PASSPHRASE';

  static const defaultNames = SecretNames();

  @yamlSerializable
  const factory SecretNames({
    @Default(SecretNames._profileSecretDefaultName) String profile,
    @Default(SecretNames._identitySecretDefaultName) String identity,
    @Default(SecretNames._identityPassphraseSecretDefaultName)
    String identityPassphrase,
  }) = _SecretNames;

  factory SecretNames.fromJson(Map<String, dynamic> json) =>
      _$SecretNamesFromJson(json);
}
