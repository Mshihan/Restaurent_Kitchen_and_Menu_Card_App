import 'package:flutter/material.dart';
import 'package:flutterapp/firebase_access_file.dart';
import 'package:flutterapp/styles_and_constants.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'package:flutterapp/functions.dart';

class ProductCategories extends StatefulWidget {
  @override
  _ProductCategoriesState createState() => _ProductCategoriesState();
}

class _ProductCategoriesState extends State<ProductCategories> {
  Functions functions = Functions();
  FireBaseClass fireBaseClass = FireBaseClass();
  CategoryAddCategory _category = CategoryAddCategory();
  TextEditingController categoryController = TextEditingController();

  File _imageFile;
  bool isLoading = false;
  bool isEmptycategory = false;
  List<LoadCategories> listCategories;
  StreamSubscription<Event> _onAddedSubscription;

  //Toast message function
  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
    );
  }

  //FireBase Database Reference
  final productReference =
      FirebaseDatabase.instance.reference().child('categories');

  //If a new Product added to the database this function will trigger
  void _onProductAdded(Event event) {
    setState(() {
      listCategories.add(new LoadCategories.fromSnapShot(event.snapshot));
    });
  }

  //Adding category to database procedures
  void addCategory() async {
    if (_imageFile == null || categoryController.value.text.length < 0) {
      showToast("Please Fill The Details");
    } else {
      setState(() {
        isLoading = true;
      });
      print(_category.category);
      _category.imageUrl = categoryController.value.text.split(" ").join("");
      await fireBaseClass.createCategory(_category, _imageFile);
      setState(() {
        isLoading = false;
        categoryController.clear();
        _imageFile = null;
        showToast('Product Added Successfuly');
      });
    }
  }

  //If product deleted this function will trigger and update the interface also
  Future<void> deleteCategory(LoadCategories categories) async {
    await productReference.child(categories.id).remove();
    removeFromScreen(categories);
  }

  void removeFromScreen(categories) {
    listCategories.remove(categories);
  }

  @override
  void initState() {
    super.initState();
    listCategories = List();
    _onAddedSubscription =
        productReference.onChildAdded.listen(_onProductAdded);
  }

  @override
  void dispose() {
    super.dispose();
    _onAddedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Add Categories',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SafeArea(
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Pick The Image',
                            style: kTextColumnHeading,
                          ),
                          Row(
                            children: <Widget>[
                              MaterialButton(
                                onPressed: () async {
                                  File image;
                                  image = await functions.getImage(true);
                                  setState(() {
                                    _imageFile = image;
                                  });
                                },
                                color: Color(0xFFF3A32F),
                                child: Icon(
                                  Icons.camera_enhance,
                                  color: Colors.white,
                                ),
                                minWidth: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  File image;
                                  image = await functions.getImage(false);
                                  setState(() {
                                    _imageFile = image;
                                  });
                                },
                                color: Color(0xFFF3A32F),
                                child: Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                ),
                                minWidth: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _imageFile == null
                        ? Container()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.only(right: 25.0),
                              height: 150,
                              width: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.file(
                                  _imageFile,
                                  fit: BoxFit.cover,
                                  height: 150,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        controller: categoryController,
                        onChanged: (title) {
                          _category.category = title;
                        },
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Title',
                          errorText:
                              isEmptycategory ? 'Please Enter a Value' : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      elevation: 5.0,
                      minWidth: 50,
                      color: Colors.red,
                      onPressed: addCategory,
                      child: Text(
                        'Add To Database',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Available Categories',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 450,
                      child: ListView.builder(
                        itemCount: listCategories.length,
                        padding: EdgeInsets.all(5.0),
                        itemBuilder: (context, position) {
                          return Container(
                            color: Colors.white,
                            height: 80,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  listCategories[position].title,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 20),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(
                                      listCategories[position].url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  color: Colors.red,
                                  child: Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await deleteCategory(
                                        listCategories[position]);

                                    setState(() {
                                      isLoading = false;
                                      showToast('Product Removed');
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryAddCategory {
  String category;
  String imageUrl;
}

class LoadCategories {
  String _title;
  String _url;
  String _id;

  LoadCategories(this._title, this._url);

  LoadCategories.map(dynamic obj) {
    this._url = obj['imageurl'];
    this._title = obj['title'];
    this._id = obj['id'];
  }

  String get title => _title;

  String get url => _url;

  String get id => _id;

  LoadCategories.fromSnapShot(DataSnapshot snapshot) {
    _url = snapshot.value['imageurl'];
    _id = snapshot.key;
    _title = snapshot.value['title'];
  }
}
