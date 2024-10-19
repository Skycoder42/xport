import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:sodium/sodium.dart';

import '../apis/security/models/sec_identity.dart';
import '../apis/security/security.dart';
import '../config/config_loader.dart';
import '../config/models/upload_cache.dart';
import '../config/models/xport_config.dart';
import 'models/signing_config_missing_exception.dart';
import 'secret_uploader.dart';
import 'signing_config_loader.dart';

@injectable
class XPorter {
  final XPortConfig _config;
  final SigningConfigLoader _signingConfigLoader;
  final Security _security;
  final Sodium _sodium;
  final SecretUploader _secretUploader;
  final ConfigLoader _configLoader;

  XPorter(
    this._config,
    this._signingConfigLoader,
    this._security,
    this._sodium,
    this._secretUploader,
    this._configLoader,
  );

  Future<void> updateSecrets() async {
    await _signingConfigLoader.configureProject();
    final signingConfig = await _signingConfigLoader.getBuildConfig();
    final profileId = await _uploadProfileIfModified(
      signingConfig.provisioningProfileId,
    );
    final serialNumber = await _uploadIdentityIfModified(
      signingConfig.signingIdentity,
    );
    await _updateCache(profileId, serialNumber);
  }

  Future<String> _uploadProfileIfModified(String profileId) async {
    if (profileId == _config.cache?.profileId) {
      return profileId;
    }

    final profile = _getProfile(profileId);
    final profileBytes = await profile.readAsBytes();
    await _secretUploader.uploadProvisioningProfile(profileBytes);
    return profileId;
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

  Future<Uint8List> _uploadIdentityIfModified(String subject) async {
    final identity = _getIdentity(subject);
    final serialNumber = identity.copyCertificate().serialNumber;
    if (serialNumber == _config.cache?.certificateSerialNumber) {
      return serialNumber;
    }

    final passphrase = base64.encode(_sodium.randombytes.buf(24));
    final identityPfxBytes = identity.export(passphrase);
    await _secretUploader.uploadSigningIdentity(
      identityBytes: identityPfxBytes,
      identityPassphrase: passphrase,
    );
    return serialNumber;
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

  Future<void> _updateCache(String profileId, Uint8List serialNumber) async {
    await _configLoader.updateCache(
      UploadCache(
        profileId: profileId,
        certificateSerialNumber: serialNumber,
      ),
    );
  }
}
