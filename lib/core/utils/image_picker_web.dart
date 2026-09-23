// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class ImagePickerHelper {
  static Future<Map<String, dynamic>?> pickImage() async {
    final completer = Completer<Map<String, dynamic>?>();
    final uploadInput = html.FileUploadInputElement();
    // Strictly restrict browser file picker dialog to JPG, PNG, WEBP images
    uploadInput.accept = 'image/jpeg,image/png,image/webp,.jpg,.jpeg,.png,.webp';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : '';
        final allowed = ['jpg', 'jpeg', 'png', 'webp'];
        if (ext.isNotEmpty && !allowed.contains(ext)) {
          completer.complete(null);
          return;
        }

        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          List<int> bytes = [];
          if (result is Uint8List) {
            bytes = result.toList();
          } else if (result is List<int>) {
            bytes = result;
          } else if (result != null) {
            try {
              bytes = (result as dynamic).asUint8List() as List<int>;
            } catch (_) {}
          }

          if (bytes.isNotEmpty) {
            completer.complete({
              'name': file.name,
              'bytes': bytes,
              'mimeType': file.type,
            });
          } else {
            completer.complete(null);
          }
        });
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
