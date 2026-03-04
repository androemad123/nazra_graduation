import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service that communicates with the backend ML API to analyse civic issue images.
///
/// Configuration is loaded from the app's `.env` file:
/// - `ML_VALIDATE_IMAGE_URL`: The full URL of the ML API endpoint (e.g., a cloud function URL).
///
/// The API is called as a POST request with query parameters:
/// - `img_url`   : The Cloudinary secure URL of the uploaded image.
/// - `description` (optional): User's description of the issue.
/// - `category`    (optional): User's selected category.
///
/// The API returns a JSON object that is expected to contain:
/// - `is_issue` (bool)        : Whether the image is a genuine civic issue.
/// - `data` (Map)             : Nested object with fields like `priority`, `category`,
///                              `description`, `confidence_level`, `issue_type`, etc.
///
/// Example API response:
/// ```json
/// {
///   "is_issue": true,
///   "data": {
///     "priority": "high",
///     "category": "Roads",
///     "description": "Large pothole detected",
///     "confidence_level": "high"
///   }
/// }
/// ```
class MlApiService {
  /// Builds the ML API request URI with the provided parameters as query strings.
  ///
  /// Merges any existing query parameters from the base endpoint URL with the
  /// new parameters (for flexibility if the endpoint already has query strings).
  ///
  /// Throws [StateError] if `ML_VALIDATE_IMAGE_URL` is not set in the `.env` file.
  Uri _buildAnalyzeUri(
    String imageUrl, {
    String? description,
    String? category,
  }) {
    final endpoint = dotenv.env['ML_VALIDATE_IMAGE_URL'];
    if (endpoint == null || endpoint.isEmpty) {
      throw StateError(
        'ML_VALIDATE_IMAGE_URL is not set. Please add it to your .env file.',
      );
    }

    final baseUri = Uri.parse(endpoint);
    // Merge base query params with the new image/description/category params
    final queryParams = {
      ...baseUri.queryParameters,
      'img_url': imageUrl,
      if (description != null && description.isNotEmpty) 'description': description,
      if (category != null && category.isNotEmpty) 'category': category,
    };

    return baseUri.replace(queryParameters: queryParams);
  }

  /// Sends a single image URL and optional metadata to the ML API for analysis.
  ///
  /// Makes a POST request to the endpoint and parses the JSON response body.
  ///
  /// [imageUrl]    — Cloudinary secure URL of the image to analyse.
  /// [description] — Optional user-provided description (helps improve accuracy).
  /// [category]    — Optional user-selected category (helps contextualise the image).
  ///
  /// Returns the decoded JSON response as a `Map<String, dynamic>`, or null if:
  /// - The API returns a non-200 status code.
  /// - A network or parsing error occurs.
  Future<Map<String, dynamic>?> analyzeImage({
    required String imageUrl,
    String? description,
    String? category,
  }) async {
    try {
      final uri = _buildAnalyzeUri(
        imageUrl,
        description: description,
        category: category,
      );
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        // Decode and return the JSON response
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('ML API request failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling ML API: $e');
      return null;
    }
  }

  /// Convenience method that analyses only the first image from a list.
  ///
  /// Useful when the caller has multiple images but only wants to run
  /// analysis on the primary/first one. Returns null if [imageUrls] is empty.
  ///
  /// To analyse all images and aggregate results, modify this method
  /// to call [analyzeImage] for each URL and combine the outputs.
  Future<Map<String, dynamic>?> analyzeImages({
    required List<String> imageUrls,
    String? description,
    String? category,
  }) async {
    if (imageUrls.isEmpty) return null;
    
    // Use only the first image for analysis (the most representative one)
    return await analyzeImage(
      imageUrl: imageUrls.first,
      description: description,
      category: category,
    );
  }
}
