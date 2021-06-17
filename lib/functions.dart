import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Functions{
  Future<File> getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    return image;
  }
}