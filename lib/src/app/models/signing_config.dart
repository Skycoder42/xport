import 'package:freezed_annotation/freezed_annotation.dart';

part 'signing_config.freezed.dart';

@freezed
sealed class SigningConfig with _$SigningConfig {
  const factory SigningConfig({
    required String signingIdentity,
    required String provisioningProfileId,
  }) = _SigningConfig;
}
