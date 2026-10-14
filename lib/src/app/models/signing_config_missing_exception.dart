enum SigningConfigKind(final String displayName) {
  provisioningProfile('Provisioning Profile'),
  signingIdentity('Signing Identity'),
}

class SigningConfigMissingException implements Exception {
  final SigningConfigKind kind;
  final String message;

  new build(this.kind) : message = 'Not found in build output';

  new profileFileMissing()
    : kind = SigningConfigKind.provisioningProfile,
      message = 'File does not exists';

  new identityNotFound()
    : kind = SigningConfigKind.signingIdentity,
      message = 'Unable to find valid identity in keychain';

  @override
  String toString() => 'SigningConfigMissingException($kind): $message';
}
