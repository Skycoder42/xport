// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../util/converters/binary_converter.dart';
import 'yaml_serializable.dart';

part 'upload_cache.freezed.dart';
part 'upload_cache.g.dart';

@freezed
sealed class UploadCache with _$UploadCache {
  @yamlSerializable
  @BinaryConverter()
  const factory UploadCache({
    @yamlKey required String profileId,
    @yamlKey required Uint8List certificateFingerprint,
  }) = _UploadCache;

  factory UploadCache.fromJson(Map<String, dynamic> json) =>
      _$UploadCacheFromJson(json);
}
