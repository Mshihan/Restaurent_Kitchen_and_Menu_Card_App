import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import '../styles_and_constants.dart';
import 'package:flutterapp/firebase_access_file.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterapp/functions.dart';

class Product {
  double price;
  String title = "";
  String description;
  int qty;
  String imageUrl;
  bool vegi = false;
  bool available;
  String category;
  String timeCategory;
}

class Categories {
  String imageUrl;
  String text;

  Categories({@required this.text, @required this.imageUrl});
}

class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  List<LoadCategories> listCategories;
  var _titleController = TextEditingController();
  var _priceController = TextEditingController();
  var _descriptionController = TextEditingController();
  FireBaseClass _fireBaseClass = FireBaseClass();
  Product _product = Product();

  final categoryReference =
      FirebaseDatabase.instance.reference().child('categories');
  StreamSubscription<Event> _LoadCategories;

  var selectedValue;
  File _imageFile;
  String title;
  String description;
  String imageUrl;
  String category;
  double price;
  bool isEmptyPrice = false;
  bool isEmptyDecription = false;
  bool isEmptytitle = false;
  bool vegi = false;
  bool isLoading = false;

  Functions function = Functions();

  @override
  void initState() {
    super.initState();
    listCategories = List();
    _LoadCategories = categoryReference.onChildAdded.listen(_loadCategory);
  }

  void _loadCategory(Event event) {
    setState(() {
      listCategories.add(new LoadCategories.fromSnapShot(event.snapshot));
    });
  }

  void showColoredToast() {
    Fluttertoast.showToast(
      msg: "Product Added Successfully",
      gravity: ToastGravity.BOTTOM,
    );
  }

  String timeCategory = 'Breakfast';


  @override
  void dispose() {
    super.dispose();
    _LoadCategories.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Adding Products To Firebase',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(
            new FocusNode(),
          );
        },
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: TextField(
                        controller: _titleController,
                        onChanged: (title) {
                          _product.title = title;
                        },
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Title',
                          errorText:
                              isEmptytitle ? 'Please Enter a Value' : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: TextField(
                        controller: _priceController,
                        onChanged: (price) {
                          _product.price = double.parse(price);
                        },
                        keyboardType: TextInputType.number,
                        decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Price',
                          errorText:
                              isEmptyPrice ? 'Please Enter a Value' : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: TextField(
                        controller: _descriptionController,
                        onChanged: (description) {
                          _product.description = description;
                        },
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Description',
                          errorText:
                              isEmptyDecription ? 'Please Enter a Value' : null,
                        ),
                        maxLines: null,
                      ),
                    ),
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
                            'Vegetarian',
                            style: kTextColumnHeading,
                          ),
                          Switch(
                            value: vegi,
                            onChanged: (value) {
                              setState(() {
                                vegi = value;
                                _product.vegi = value;
                              });
                            },
                            activeColor: Color(0xFFF3A32F),
                            activeTrackColor: Color(0xFFF3A32F).withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
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
                            'Time Category',
                            style: kTextColumnHeading,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                    blurRadius: 5),
                              ],
                            ),
                            child: DropdownButton<String>(
                              hint: Text(
                                "Available Time",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20),
                              ),
                              itemHeight: 70,
                              underline: Container(),
                              value: timeCategory,
                              onChanged: (category) {
                                setState(() {
                                  timeCategory = category;
                                  _product.timeCategory = category;
                                });
                              },
                              items:
                              <String>['Breakfast', 'Lunch', 'Dinner', 'Snack', ]
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                            'Category',
                            style: kTextColumnHeading,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                    blurRadius: 5),
                              ],
                            ),
                            child: DropdownButton<LoadCategories>(
                              hint: Text(
                                "Select item",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20),
                              ),
                              itemHeight: 70,
                              underline: Container(),
                              value: selectedValue,
                              onChanged: (category) {
                                setState(() {
                                  selectedValue = category;
                                  _product.category = category.title;
                                  _titleController.selection;
                                });
                              },
                              items:
                                  listCategories.map((LoadCategories category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 2),
                                    width: width * 0.38,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
//                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(category.url),
                                                fit: BoxFit.cover,
                                              )),
                                          height: 50.0,
                                          width: 50.0,
                                        ),
                                        Text(
                                          category.title,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                  image = await function.getImage(true);
                                  setState(() {
                                    _imageFile = image;
                                  });
                                },
                                color: Color(0xFFF3A32F),
                                child: Icon(Icons.camera_enhance, color: Colors.white,),
                                minWidth: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  File image;
                                  image = await function.getImage(false);
                                  setState(() {
                                    _imageFile = image;
                                  });
                                },
                                color: Color(0xFFF3A32F),
                                child: Icon(Icons.collections, color: Colors.white,),
                                minWidth: 20,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _imageFile == null
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 60.0, horizontal: 70),
//                        height: 170,
//                        width: 170,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            ),
                          )
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: MaterialButton(
                        elevation: 8.0,
                        minWidth: 60,
                        height: 60,
                        color: Color(0xFFF3A32F),
                        onPressed: () async {
                          _product.imageUrl =
                              _product.title.split(" ").join("");
                          print(_descriptionController.value.text);
                          print(_titleController.value.text);
                          print(_priceController.value.text);

                          if (_titleController.text.length < 1) {
                            setState(() {
                              isEmptytitle = true;
                            });
                          } else if (_priceController.text.length < 1) {
                            setState(() {
                              isEmptyPrice = true;
                            });
                          } else if (_descriptionController.text.length < 1) {
                            setState(() {
                              isEmptyDecription = true;
                            });
                          } else {
                            isEmptytitle = false;
                            isEmptyPrice = false;
                            isEmptyDecription = false;
                            setState(() {
                              isLoading = true;
                            });
                            bool uploaded = await _fireBaseClass.createRecord(
                                _product, _imageFile);
                            setState(() {
                              isLoading = uploaded;
                              _titleController.clear();
                              _priceController.clear();
                              _descriptionController.clear();
                              vegi = false;
                              selectedValue = null;
                              _imageFile = null;
                              showColoredToast();
                            });
                          }
                        },
                        child: Text(
                          'Add to database',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 20),
                        ),
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
