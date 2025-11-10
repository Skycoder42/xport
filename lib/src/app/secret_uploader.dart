import 'dart:convert';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:sodium/sodium.dart';

import '../apis/github/github_client.dart';
import '../apis/github/models/encrypted_secret.dart';
import '../apis/github/models/public_key.dart';
import '../config/models/github_target.dart';
import '../config/models/xport_config.dart';

@injectable
class SecretUploader {
  final XPortConfig _config;
  final GithubClient _githubClient;
  final Sodium _sodium;
  final _logger = Logger('SecretUploader');

  PublicKey? _cachedPublicKey;

  SecretUploader(this._config, this._githubClient, this._sodium);

  Future<void> uploadProvisioningProfile(Uint8List profileBytes) async {
    final publicKey = await _loadPublicKey(_config.target);
    await _uploadSecret(
      _config.target,
      publicKey,
      _config.secrets.profile,
      base64.encode(profileBytes),
    );
  }

  Future<void> uploadSigningIdentity({
    required Uint8List identityBytes,
    required String identityPassphrase,
  }) async {
    final publicKey = await _loadPublicKey(_config.target);
    await _uploadSecret(
      _config.target,
      publicKey,
      _config.secrets.identity,
      base64.encode(identityBytes),
    );
    await _uploadSecret(
      _config.target,
      publicKey,
      _config.secrets.identityPassphrase,
      identityPassphrase,
    );
  }

  Future<PublicKey> _loadPublicKey(GitHubTarget target) async =>
      _cachedPublicKey ??= switch (target) {
        GitHubTargetOrg(:final org) =>
          await _githubClient.getOrganisationPublicKey(org),
        GitHubTargetRepo(:final owner, :final repo) =>
          await _githubClient.getRepositoryPublicKey(owner, repo),
        GitHubTargetEnv(:final owner, :final repo, :final env) =>
          await _githubClient.getEnvironmentPublicKey(owner, repo, env),
      };

  Future<void> _uploadSecret(
    GitHubTarget target,
    PublicKey publicKey,
    String secretName,
    String secret,
  ) async {
    final encryptedSecret = EncryptedSecret(
      keyId: publicKey.keyId,
      encryptedValue: _sodium.crypto.box.seal(
        message: utf8.encode(secret),
        publicKey: publicKey.key,
      ),
    );

    switch (target) {
      case GitHubTargetOrg(:final org):
        _logger.finest('Updating secret $secretName for $org');
        await _githubClient.putOrganisationSecret(
          org,
          secretName,
          encryptedSecret,
        );
      case GitHubTargetRepo(:final owner, :final repo):
        _logger.finest('Updating secret $secretName for $owner/$repo');
        await _githubClient.putRepositorySecret(
          owner,
          repo,
          secretName,
          encryptedSecret,
        );
      case GitHubTargetEnv(:final owner, :final repo, :final env):
        _logger.finest('Updating secret $secretName for $env@$owner/$repo');
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
