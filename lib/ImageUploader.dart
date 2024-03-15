import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploader {

  Future<String?> pickImage(String ID) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      return await uploadImage(image, ID);
    }
    return null;
  }

  Future<String> uploadImage(XFile Image, String ID) async {
    var type = 'image/${Image.path.split('.').last}';
    final response = await Supabase.instance.client.storage
        .from('ProfilePictures')
        .upload('$ID.$type', File(Image.path), fileOptions: FileOptions(
      contentType: type,
      upsert: false,
    ));
    return Image.path;
  }
}