import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Service that wraps the [ImagePicker] plugin to pick or capture images.
///
/// Provides two simple methods:
/// - [pickFromGallery]: opens the device photo gallery for selection.
/// - [pickFromCamera]: opens the device camera for capture.
///
/// Both methods return the selected/captured image as a [File], or null if
/// the user cancels the picker.
///
/// The [imageQuality] parameter (0–100) controls JPEG compression.
/// The default of 80 provides a good balance between quality and file size.
class ImagePickerService {
  /// The underlying [ImagePicker] plugin instance.
  final ImagePicker _picker = ImagePicker();

  /// Opens the device's photo gallery and returns the selected image as a [File].
  ///
  /// [imageQuality] — JPEG compression quality from 0 (worst) to 100 (best).
  /// Defaults to 80 for a good quality/size balance.
  ///
  /// Returns null if the user dismisses the gallery without selecting an image.
  Future<File?> pickFromGallery({int imageQuality = 80}) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    // Convert XFile to dart:io File, or return null if cancelled
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  /// Opens the device camera and returns the captured image as a [File].
  ///
  /// [imageQuality] — JPEG compression quality from 0 (worst) to 100 (best).
  /// Defaults to 80 for a good quality/size balance.
  ///
  /// Returns null if the user cancels the camera without capturing an image.
  Future<File?> pickFromCamera({int imageQuality = 80}) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    // Convert XFile to dart:io File, or return null if cancelled
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }
}
