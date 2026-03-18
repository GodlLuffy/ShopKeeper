import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class LocalImageService {
  final picker = ImagePicker();

  Future<File?> pickImage(bool fromCamera) async {
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<File?> cropImage(File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Product Image',
          toolbarColor: AppTheme.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Product Image'),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg");

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 500,
      minHeight: 500,
    );
    if (compressed == null) return null;
    return File(compressed.path);
  }

  Future<File?> pickAndCropImage(bool fromCamera) async {
    final picked = await pickImage(fromCamera);
    if (picked == null) return null;
    return await cropImage(picked);
  }

  Future<String> processAndSaveImage(File croppedFile) async {
    final compressed = await compressImage(croppedFile);
    if (compressed == null) throw Exception("Image compression failed.");

    final dir = await getApplicationDocumentsDirectory();
    final finalPath = p.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}_product.jpg");

    final saved = await compressed.copy(finalPath);
    return saved.path;
  }
}
