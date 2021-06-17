import 'package:firebase_database/firebase_database.dart';
import 'screens/addProducts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'screens/add_product_categories.dart';
import 'screens/availability_change_products.dart';

class FireBaseClass {
  FirebaseDatabase _databaseReference = FirebaseDatabase.instance;

  //Entering details to products in database
  Future<bool> createRecord(Product products, File _imageFile) async {
    String downloadUrl = await uploadImage(products.imageUrl, _imageFile);
    products.imageUrl = downloadUrl;
    await _databaseReference.reference().child('products').push().set({
      "title": products.title,
      "description": products.description,
      "category": products.category,
      "price": products.price.toInt(),
      "imageurl": products.imageUrl,
      "isvegi": products.vegi,
      "isavailable": true,
      "timecategory": products.timeCategory,
    });
    return false;
  }

  //Product Image Uploading
  Future<String> uploadImage(String imageUrl, File _imageFile) async {
    StorageReference reference =
        FirebaseStorage.instance.ref().child("products/$imageUrl.jpg");
    StorageUploadTask uploadTask = reference.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }

  //Entering Details to Categories in Database
  Future createCategory(CategoryAddCategory category, File _imageFile) async {
    String downloadUrl = await uploadCategoryImage(category.imageUrl, _imageFile);
    category.imageUrl = downloadUrl;
    await _databaseReference
        .reference()
        .child('categories')
        .push()
        .set({"title": category.category, "imageurl": category.imageUrl});
  }

  //Category Image uploading
  Future<String> uploadCategoryImage(String imageUrl, File _imageFile) async {
    StorageReference reference =
    FirebaseStorage.instance.ref().child("categories/$imageUrl");
    StorageUploadTask uploadTask = reference.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }

  final productReference =
  FirebaseDatabase.instance.reference().child('products');

  //Update availability in Products
  Future<void> updateDetails(Updates updates) async {
    await productReference.child(updates.id).update({
      "isavailable": updates.isavailable,
    });
  }

  //deleteProducts from availability
  Future<void> deleteProduct(Updates updates) async {
    await productReference.child(updates.id).remove();
  }

}
