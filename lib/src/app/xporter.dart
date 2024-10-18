import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:sodium/sodium.dart';

import '../apis/security/models/sec_identity.dart';
import '../apis/security/security.dart';
import 'models/signing_config_missing_exception.dart';
import 'secret_uploader.dart';
import 'signing_config_loader.dart';

@injectable
class XPorter {
  final SigningConfigLoader _signingConfigLoader;
  final Security _security;
  final Sodium _sodium;
  final SecretUploader _secretUploader;

  XPorter(
    this._signingConfigLoader,
    this._security,
    this._sodium,
    this._secretUploader,
  );

  Future<void> updateSecrets() async {
    await _signingConfigLoader.configureProject();
    final signingConfig = await _signingConfigLoader.getBuildConfig();
    final profile = _getProfile(signingConfig.provisioningProfileId);
    final identity = _getIdentity(signingConfig.signingIdentity);
    await _uploadSecrets(profile, identity);
  }

  File _getProfile(String profileId) {
    final profileFile = File(
      path.join(
        Platform.environment['HOME']!,
        'Library/Developer/Xcode/UserData/Provisioning Profiles',
        '$profileId.mobileprovision',
      ),
    );
    if (!profileFile.existsSync()) {
      throw SigningConfigMissingException.profileFileMissing();
    }
    return profileFile;
  }

  SecIdentity _getIdentity(String subject) {
    final identity = _security.findIdentity(
      subject: subject,
      validOn: DateTime.now(),
    );
    if (identity == null) {
      throw SigningConfigMissingException.identityNotFound();
    }
    return identity;
  }

  Future<void> _uploadSecrets(File profile, SecIdentity identity) async {
    final passphrase = base64.encode(_sodium.randombytes.buf(24));
    final profileBytes = await profile.readAsBytes();
    final identityPfxBytes = identity.export(passphrase);
    await _secretUploader.upload(
      profileBytes: profileBytes,
      identityBytes: identityPfxBytes,
      identityPassphrase: passphrase,
    );
  }
}
