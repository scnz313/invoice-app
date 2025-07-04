import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/security_config.dart';
import '../utils/logger.dart';

/// Service for handling company logo and image operations
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Maximum image size in bytes (2MB)
  static const int maxImageSize = 2 * 1024 * 1024;
  
  /// Allowed image extensions
  static const Set<String> allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};
  
  /// Maximum image dimensions
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;

  /// Pick an image from gallery or camera
  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: 85, // Compress to reduce file size
      );

      if (image == null) {
        Logger.info('User cancelled image selection', 'ImageService');
        return null;
      }

      // Validate the selected image
      final validationResult = await _validateImage(image);
      if (!validationResult.isValid) {
        Logger.warning('Image validation failed: ${validationResult.error}', 'ImageService');
        throw ImageValidationException(validationResult.error);
      }

      // Save the image to app directory
      final savedPath = await _saveImageToAppDirectory(image);
      Logger.info('Image saved successfully: $savedPath', 'ImageService');
      
      return savedPath;
    } catch (e) {
      Logger.error('Error picking image', 'ImageService', e);
      rethrow;
    }
  }

  /// Pick company logo with specific validation and storage
  Future<String?> pickCompanyLogo() async {
    try {
      Logger.debug('Starting company logo selection...', 'ImageService');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: 85,
      );

      if (image == null) {
        Logger.debug('No image selected for company logo', 'ImageService');
        return null;
      }

      Logger.debug('Image selected: ${image.path}', 'ImageService');

      // Get image info for debugging
      final fileSize = await image.length();
      Logger.debug('Image file size: ${(fileSize / 1024).toStringAsFixed(1)} KB', 'ImageService');

      // Validate the selected image
      final validation = await _validateImage(image);
      if (!validation.isValid) {
        Logger.error('Image validation failed: ${validation.error}', 'ImageService');
        throw ImageValidationException(validation.error);
      }

      Logger.debug('Image validation passed', 'ImageService');

      // Clean up old logos first
      await cleanupOldLogos();

      // Save the new logo
      final savedPath = await _saveImageToAppDirectory(image);
      Logger.info('Company logo saved successfully: $savedPath', 'ImageService');

      return savedPath;
    } catch (e, stackTrace) {
      Logger.error('Error picking company logo: $e', 'ImageService', e, stackTrace);
      rethrow;
    }
  }

  /// Validate the selected image
  Future<ImageValidationResult> _validateImage(XFile image) async {
    try {
      // Check file extension
      final extension = path.extension(image.path).toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return ImageValidationResult(
          isValid: false,
          error: 'Unsupported file format. Please select a JPG, PNG, or WebP image.',
        );
      }

      // Check file size
      final fileSize = await image.length();
      if (fileSize > maxImageSize) {
        final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        return ImageValidationResult(
          isValid: false,
          error: 'Image size ($sizeMB MB) exceeds the maximum limit of 2 MB.',
        );
      }

      // For image picker files, we don't need to validate the path since they come from system picker
      // The files will be copied to our secure app directory anyway
      Logger.debug('Image validation passed for: ${image.path}', 'ImageService');

      return ImageValidationResult(isValid: true);
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        error: 'Error validating image: $e',
      );
    }
  }

  /// Save image to app's document directory
  Future<String> _saveImageToAppDirectory(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory(path.join(appDir.path, 'logos'));
      
      // Create logos directory if it doesn't exist
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Generate secure filename
      final extension = path.extension(image.path);
      final fileName = SecurityConfig.generateSecureFileName('company_logo', extension.substring(1));
      final savePath = path.join(logoDir.path, fileName);

      // Copy the image to app directory
      final imageBytes = await image.readAsBytes();
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(imageBytes);

      return savePath;
    } catch (e) {
      Logger.error('Error saving image to app directory', 'ImageService', e);
      throw ImageSaveException('Failed to save image: $e');
    }
  }

  /// Load image as bytes for PDF generation
  Future<Uint8List?> loadImageAsBytes(String imagePath) async {
    try {
      if (imagePath.isEmpty) return null;
      
      final file = File(imagePath);
      if (!await file.exists()) {
        Logger.warning('Logo image not found at path: $imagePath', 'ImageService');
        return null;
      }

      final bytes = await file.readAsBytes();
      Logger.debug('Loaded image bytes: ${bytes.length} bytes', 'ImageService');
      return bytes;
    } catch (e) {
      Logger.error('Error loading image as bytes', 'ImageService', e);
      return null;
    }
  }

  /// Check if image exists at given path
  Future<bool> imageExists(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      Logger.warning('Error checking if image exists', 'ImageService');
      return false;
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) return;
      
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        Logger.info('Deleted image: $imagePath', 'ImageService');
      }
    } catch (e) {
      Logger.error('Error deleting image', 'ImageService', e);
    }
  }

  /// Get image file size in bytes
  Future<int> getImageSize(String imagePath) async {
    try {
      if (imagePath.isEmpty) return 0;
      
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      Logger.warning('Error getting image size', 'ImageService');
      return 0;
    }
  }

  /// Clean up old logo images (keep only the latest one)
  Future<void> cleanupOldLogos() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory(path.join(appDir.path, 'logos'));
      
      if (!await logoDir.exists()) return;

      final files = await logoDir.list().toList();
      final logoFiles = files
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) => allowedExtensions.any((ext) => file.path.toLowerCase().endsWith(ext)))
          .toList();

      // Sort by last modified date (newest first)
      logoFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Keep only the most recent logo, delete others
      if (logoFiles.length > 1) {
        for (int i = 1; i < logoFiles.length; i++) {
          await logoFiles[i].delete();
          Logger.debug('Cleaned up old logo: ${logoFiles[i].path}', 'ImageService');
        }
      }
    } catch (e) {
      Logger.warning('Error cleaning up old logos', 'ImageService');
    }
  }

  /// Get image dimensions
  Future<ImageDimensions?> getImageDimensions(String imagePath) async {
    try {
      if (imagePath.isEmpty) return null;
      
      final file = File(imagePath);
      if (!await file.exists()) return null;

      // For now, return null as we'd need additional packages for image dimension detection
      // This can be implemented if needed
      return null;
    } catch (e) {
      Logger.warning('Error getting image dimensions', 'ImageService');
      return null;
    }
  }
}

/// Result of image validation
class ImageValidationResult {
  final bool isValid;
  final String error;

  ImageValidationResult({
    required this.isValid,
    this.error = '',
  });
}

/// Image dimensions
class ImageDimensions {
  final int width;
  final int height;

  ImageDimensions({required this.width, required this.height});
}

/// Custom exceptions for image operations
class ImageValidationException implements Exception {
  final String message;
  ImageValidationException(this.message);
  
  @override
  String toString() => 'ImageValidationException: $message';
}

class ImageSaveException implements Exception {
  final String message;
  ImageSaveException(this.message);
  
  @override
  String toString() => 'ImageSaveException: $message';
}

/// Helper methods for image operations
extension ImageServiceHelpers on ImageService {
  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if file is an image based on extension
  bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ImageService.allowedExtensions.contains(extension);
  }
} 