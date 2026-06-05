import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Picks images and copies them into the app's documents directory so the
/// path remains valid across app launches.
class ImageStorageService {
  ImageStorageService(this._picker, this._uuid);

  final ImagePicker _picker;
  final Uuid _uuid;

  Future<String?> pickAndStore({required ImageSource source}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 2000,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final filename = '${_uuid.v4()}.$ext';
    final saved = await File(picked.path).copy('${dir.path}/$filename');
    return saved.path;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
