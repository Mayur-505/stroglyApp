import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<Map<String, dynamic>?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final name = file.name.isNotEmpty ? file.name : 'photo.jpg';
        final mimeType = file.mimeType ?? 'image/jpeg';
        return {
          'name': name,
          'bytes': bytes,
          'mimeType': mimeType,
          'path': file.path,
        };
      }
    } catch (e) {
      // Return null on user cancel or permission error
    }
    return null;
  }
}
