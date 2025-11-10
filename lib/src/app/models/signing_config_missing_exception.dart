enum SigningConfigKind {
  provisioningProfile('Provisioning Profile'),
  signingIdentity('Signing Identity');

  final String displayName;

  const SigningConfigKind(this.displayName);
}

class SigningConfigMissingException implements Exception {
  final SigningConfigKind kind;
  final String message;

  SigningConfigMissingException.build(this.kind)
    : message = 'Not found in build output';

  SigningConfigMissingException.profileFileMissing()
    : kind = SigningConfigKind.provisioningProfile,
      message = 'File does not exists';

  SigningConfigMissingException.identityNotFound()
    : kind = SigningConfigKind.signingIdentity,
      message = 'Unable to find valid identity in keychain';

  @override
  String toString() => 'SigningConfigMissingException($kind): $message';
}
