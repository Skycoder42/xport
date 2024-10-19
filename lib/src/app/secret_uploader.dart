import 'dart:convert';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:sodium/sodium.dart';

import '../apis/github/github_client.dart';
import '../apis/github/models/encrypted_secret.dart';
import '../apis/github/models/public_key.dart';
import '../config/models/github_target.dart';
import '../config/models/xport_config.dart';

@injectable
class SecretUploader {
  static const _profileSecretName = 'PROVISIONING_PROFILE';
  static const _identitySecretName = 'SIGNING_IDENTITY';
  static const _identityPassphraseSecretName = 'SIGNING_IDENTITY_PASSPHRASE';

  final XPortConfig _config;
  final GithubClient _githubClient;
  final Sodium _sodium;

  SecretUploader(
    this._config,
    this._githubClient,
    this._sodium,
  );

  Future<void> upload({
    required Uint8List profileBytes,
    required Uint8List identityBytes,
    required String identityPassphrase,
  }) async {
    final publicKey = await _loadPublicKey(_config.target);
    await _uploadSecret(
      _config.target,
      publicKey,
      _profileSecretName,
      profileBytes,
    );
    await _uploadSecret(
      _config.target,
      publicKey,
      _identitySecretName,
      identityBytes,
    );
    await _uploadSecret(
      _config.target,
      publicKey,
      _identityPassphraseSecretName,
      utf8.encode(identityPassphrase),
    );
  }

  Future<PublicKey> _loadPublicKey(GitHubTarget target) async {
    switch (target) {
      case GitHubTargetOrg(:final org):
        return _githubClient.getOrganisationPublicKey(org);
      case GitHubTargetRepo(:final owner, :final repo):
        return _githubClient.getRepositoryPublicKey(owner, repo);
      case GitHubTargetEnv(:final owner, :final repo, :final env):
        return _githubClient.getEnvironmentPublicKey(owner, repo, env);
    }
  }

  Future<void> _uploadSecret(
    GitHubTarget target,
    PublicKey publicKey,
    String secretName,
    Uint8List secret,
  ) async {
    final encryptedSecret = EncryptedSecret(
      keyId: publicKey.keyId,
      encryptedValue: _sodium.crypto.box.seal(
        message: secret,
        publicKey: publicKey.key,
      ),
    );

    switch (target) {
      case GitHubTargetOrg(:final org):
        await _githubClient.putOrganisationSecret(
          org,
          secretName,
          encryptedSecret,
        );
      case GitHubTargetRepo(:final owner, :final repo):
        await _githubClient.putRepositorySecret(
          owner,
          repo,
          secretName,
          encryptedSecret,
        );
      case GitHubTargetEnv(:final owner, :final repo, :final env):
        await _githubClient.putEnvironmentSecret(
          owner,
          repo,
          env,
          secretName,
          encryptedSecret,
        );
    }
  }
}
