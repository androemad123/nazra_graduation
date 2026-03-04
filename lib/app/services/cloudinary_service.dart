import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service that uploads images to Cloudinary via their REST upload API.
///
/// Configuration is loaded from the app's `.env` file:
/// - `CLOUDINARY_CLOUD_NAME`  : Your Cloudinary cloud name (found in the dashboard).
/// - `CLOUDINARY_UPLOAD_PRESET`: An **unsigned** upload preset (safer for client-side uploads).
///
/// You can get these from https://cloudinary.com/ → Settings → Upload.
///
/// Usage:
/// ```dart
/// final service = CloudinaryService();
/// final url = await service.uploadImage(imageFile: file, category: 'Roads');
/// ```
class CloudinaryService {
  /// Builds the Cloudinary upload endpoint URI for the configured cloud.
  ///
  /// Throws [StateError] if `CLOUDINARY_CLOUD_NAME` is not set in the `.env` file.
  Uri get _uploadUri {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    if (cloudName == null || cloudName.isEmpty) {
      throw StateError(
        'CLOUDINARY_CLOUD_NAME is not set. Please add it to your .env file.',
      );
    }
    return Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
  }

  /// Returns the configured unsigned upload preset name.
  ///
  /// Throws [StateError] if `CLOUDINARY_UPLOAD_PRESET` is not set in the `.env` file.
  String get _uploadPreset {
    final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
    if (preset == null || preset.isEmpty) {
      throw StateError(
        'CLOUDINARY_UPLOAD_PRESET is not set. Please add it to your .env file.',
      );
    }
    return preset;
  }

  /// Uploads a single image file to Cloudinary with optional metadata.
  ///
  /// Uses a multipart POST request (the standard Cloudinary unsigned upload flow).
  /// Metadata is attached in the Cloudinary `context` field as key=value pairs
  /// separated by `|` (e.g., `description=Pothole|category=Roads`).
  ///
  /// [imageFile]   — The local image file to upload.
  /// [description] — Optional description stored as Cloudinary context metadata.
  /// [category]    — Optional category stored as Cloudinary context metadata.
  ///
  /// Returns the `secure_url` (HTTPS) of the uploaded image on success,
  /// or null if the upload fails.
  Future<String?> uploadImage({
    required File imageFile,
    String? description,
    String? category,
  }) async {
    try {
      // Resolve config values — will throw StateError if not set
      final uploadUri = _uploadUri;
      final uploadPreset = _uploadPreset;

      var request = http.MultipartRequest('POST', uploadUri);

      // Required: unsigned upload preset to authorize without an API key
      request.fields['upload_preset'] = uploadPreset;

      // Attach optional metadata via Cloudinary's `context` field
      // Format: key1=value1|key2=value2 (values must be URL-encoded)
      Map<String, String> context = {};
      if (description != null && description.isNotEmpty) {
        context['description'] = description;
      }
      if (category != null && category.isNotEmpty) {
        context['category'] = category;
      }

      if (context.isNotEmpty) {
        request.fields['context'] = context.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('|');
      }

      // Attach the image file as a multipart stream
      var fileStream = http.ByteStream(imageFile.openRead());
      var fileLength = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last, // Use the original file name
      );
      request.files.add(multipartFile);

      // Send the upload request and await the response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Return the secure HTTPS URL of the uploaded image
        return responseData['secure_url'] as String?;
      } else {
        print('Cloudinary upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Uploads multiple images sequentially and returns a list of their secure URLs.
  ///
  /// Images that fail to upload are silently skipped (not included in the result).
  /// [description] and [category] are applied to all uploaded images.
  ///
  /// Returns an empty list if all uploads fail or [imageFiles] is empty.
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    String? description,
    String? category,
  }) async {
    List<String> uploadedUrls = [];
    
    for (var imageFile in imageFiles) {
      final url = await uploadImage(
        imageFile: imageFile,
        description: description,
        category: category,
      );
      // Only add URLs for successful uploads
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }
}
