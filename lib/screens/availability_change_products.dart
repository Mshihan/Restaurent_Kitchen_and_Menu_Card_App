import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterapp/firebase_access_file.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProductManipulationPage extends StatefulWidget {
  @override
  _ProductManipulationPageState createState() =>
      _ProductManipulationPageState();
}

class _ProductManipulationPageState extends State<ProductManipulationPage> {
  final productReference =
      FirebaseDatabase.instance.reference().child('products');
  final categoryReference =
  FirebaseDatabase.instance.reference().child('categories');

  String selectedTitle;
  bool isLoading = false;
  List<Updates> screenUpdate;
  List<Updates> temp;
  List<LoadCategories> foodCategories;
  StreamSubscription<Event> _screenUpdate;
  StreamSubscription<Event> _screenChange;
  StreamSubscription<Event> _addCategories;


  @override
  void initState() {
    super.initState();
    screenUpdate = List();
    foodCategories = List();
    temp = List();
    _screenUpdate = productReference.onChildAdded.listen(_updateScreen);
    _screenChange = productReference.onChildChanged.listen(_onscreenChanged);
    _addCategories = categoryReference.onChildAdded.listen(_updateCategories);
    if (screenUpdate.length < 1) {
      isLoading = true;
    } else {
      isLoading = false;
    }
  }

  void _updateCategories(Event event) async {
    setState(() {
      foodCategories.add((new LoadCategories.fromSnapShot(event.snapshot)));
    });
  }


  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
    );
  }


  void _updateScreen(Event event) {
    setState(() {
      screenUpdate.add(Updates.fromSnapshot(event.snapshot));
      if(event.snapshot.value['category'] == selectedTitle){
        temp.add(Updates.fromSnapshot(event.snapshot));
      }
    });
  }

  void _onscreenChanged(Event event) {
    var oldProductValue =
        screenUpdate.singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      screenUpdate[screenUpdate.indexOf(oldProductValue)] =
          Updates.fromSnapshot(event.snapshot);
      if(selectedTitle == event.snapshot.value['category']){
        refresh(selectedTitle);
      }
    });
  }

  void refresh(String category){
    print(category);
    print(screenUpdate.length);
    temp = [];
    for(int i = 0; i < screenUpdate.length; i++){
      if(screenUpdate[i].category == category){
        setState(() {
          temp.add(screenUpdate[i]);
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _screenUpdate.cancel();
    _screenChange.cancel();
    _addCategories.cancel();
  }


  FireBaseClass fireBaseClass = FireBaseClass();

  Future<void> removeFromScreen(Updates updates)async {
    await fireBaseClass.deleteProduct(updates);
    screenUpdate.remove(updates);
  }
  int selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if(selectedTitle == null && foodCategories.length > 0){
      selectedTitle = foodCategories[0].title;
      refresh(selectedTitle);
    }
    if (temp.length < 1) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Manipulation Page',
            style: TextStyle(fontSize: 20, fontFamily: 'Serif'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: height / 10,
                color: Colors.white30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foodCategories.length,
                  itemBuilder: (context, index) {
                    selectedTitle = foodCategories[0].title;
                    return Center(
                      child: Container(
                        margin:
                        EdgeInsets.only(right: width / 70, left: width / 70),
                        padding: index == selectedIndex
                            ? EdgeInsets.only(
                            left: 20, top: 8, right: 20, bottom: 8)
                            : EdgeInsets.only(
                            left: 20, top: 8, right: 20, bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: index == selectedIndex
                              ? Color(0xFFF3A32F)
                              : Colors.white,
                          boxShadow: index == selectedIndex
                              ? [
                            BoxShadow(
                              offset: Offset(0, 5),
                              color: Colors.black26,
                              blurRadius: 8,
                            ),
                          ]
                              : [],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            selectedIndex = index;
                            selectedTitle = foodCategories[index].title;
                            setState(() {
                              temp = [];
                              for(int i = 0; i < screenUpdate.length; i++){
                                if(screenUpdate[i].category == selectedTitle){
                                  setState(() {
                                    temp.add(screenUpdate[i]);
                                  });
                                }
                              }
                            });
                          },
                          child: Text(
                            foodCategories[index].title,
                            style: TextStyle(
                              color: index == selectedIndex
                                  ? Colors.white
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ModalProgressHUD(
                  inAsyncCall: isLoading,
                  child: Center(
                    child: ListView.builder(
                      itemCount: temp.length,
                      padding: EdgeInsets.all(5.0),
                      itemBuilder: (context, position) {
                        bool isAvailable;
                        if (temp.length < 1) {
                          isLoading = true;
                        } else {
                          isLoading = false;
                        }
                        return Container(
                          width: width,
                          color: Color(0xFFF3A32F).withOpacity(0.1),
                          margin: EdgeInsets.all(2),
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 210,
                                child: Text(
                                  '${temp[position].title}',
                                  style: TextStyle(color: Colors.black54, fontSize: 20),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Switch(
                                    value: temp[position].isavailable,
                                    onChanged: (value) async {
                                      setState(() {
                                        isAvailable = value;
                                        isLoading = true;
                                      });

                                      Updates updates = Updates(
                                          temp[position].title,
                                          temp[position].id,
                                          isAvailable, temp[position]._category);
                                      await fireBaseClass.updateDetails(updates);
                                      selectedTitle = temp[position].category;
                                      refresh(selectedTitle);
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showToast('Product Updated Successfully');
                                    },
                                    activeColor: Colors.lightBlueAccent,
                                    activeTrackColor: Colors.lightBlue,
                                  ),
                                  SizedBox(
                                    width: 10,
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
                                      await removeFromScreen(temp[position]);
                                      setState(() {
                                        isLoading = false;
                                        showToast('Product Deleted Successfully');
                                      });
                                      selectedTitle = temp[position].category;
                                      refresh(selectedTitle);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class Updates {
  String _id;
  String _title;
  bool _isavailable;
  String _category;

  Updates(this._title, this._id, this._isavailable, this._category);

  String get id => _id;
  String get category => _category;

  String get title => _title;

  bool get isavailable => _isavailable;

  Updates.map(dynamic obj) {
    this._isavailable = obj['isavailable'];
    this._id = obj['id'];
    this._title = obj['title'];
    this._category = obj['category'];
  }

  Updates.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _title = snapshot.value['title'];
    _isavailable = snapshot.value['isavailable'];
    _category = snapshot.value['category'];
  }
}

class LoadCategories {
  String _title;
  String _id;

  LoadCategories(this._title);

  LoadCategories.map(dynamic obj) {
    this._title = obj['title'];
    this._id = obj['id'];
  }

  String get title => _title;

  String get id => _id;

  LoadCategories.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _title = snapshot.value['title'];
  }
}
