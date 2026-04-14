import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

/// Image picking, cropping, and compressing helper.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from [source], crop it to square, and compress to <= 2MB.
  Future<File?> pickCropAndCompress({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    if (pickedFile == null) {
      return null;
    }

    final cropped = await cropImage(File(pickedFile.path));
    if (cropped == null) {
      return null;
    }

    return await compressImage(cropped, maxBytes: 2 * 1024 * 1024);
  }

  /// Crop image to square with basic UI settings.
  Future<File?> cropImage(File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      maxWidth: 1080,
      maxHeight: 1080,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Potong Foto',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Potong Foto', aspectRatioLockEnabled: true),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }

  /// Compress [file] to be under [maxBytes]. If already small, returns original file.
  Future<File> compressImage(File file, {required int maxBytes}) async {
    final currentSize = await file.length();
    if (currentSize <= maxBytes) {
      return file;
    }

    final baseName = p.basenameWithoutExtension(file.path);
    final ext = p.extension(file.path);
    final targetPath = p.join(
      p.dirname(file.path),
      '${baseName}_compressed$ext',
    );

    int quality = 90;
    File? compressedFile;
    while (quality >= 20) {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 720,
        minHeight: 720,
      );

      if (result == null) break;
      compressedFile = File(result.path);

      final newSize = await compressedFile.length();
      if (newSize <= maxBytes) {
        return compressedFile;
      }
      quality -= 15;
    }

    return compressedFile ?? file;
  }
}
