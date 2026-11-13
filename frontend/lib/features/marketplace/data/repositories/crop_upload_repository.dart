import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';

class CropUploadRepository {
  final ApiClient _apiClient;

  CropUploadRepository(this._apiClient);

  Future<String> uploadCropPhoto(File source) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      source.absolute.path,
      quality: 85,
      minWidth: 1280,
      minHeight: 1280,
    );
    if (compressed == null || compressed.length > 1024 * 1024) {
      throw StateError('Crop photo must be compressed to 1 MB or less.');
    }

    final response = await _apiClient.post(
      ApiEndpoints.cropPhotoUpload,
      data: FormData.fromMap({
        'photo': MultipartFile.fromBytes(compressed, filename: source.uri.pathSegments.last),
      }),
    );
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}
