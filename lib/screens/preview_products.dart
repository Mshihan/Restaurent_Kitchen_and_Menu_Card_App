import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class PreviewPage extends StatefulWidget {
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

final productReference = FirebaseDatabase.instance
    .reference()
    .child('products')
    .orderByChild('isavailable')
    .equalTo(true);

final categoryReference =
    FirebaseDatabase.instance.reference().child('categories');

class _PreviewPageState extends State<PreviewPage> {
  List<Note> products;
  String selectedTitle;
  List<Note> temp;
  List<LoadCategories> categories;
  StreamSubscription<Event> _onNoteAddedSubscription;
  StreamSubscription<Event> _onNoteChangedSubscription;
  StreamSubscription<Event> _onNoteDeleted;
  StreamSubscription<Event> _onProductFullYDeleted;
  StreamSubscription<Event> _addCategories;

  @override
  void initState() {
    super.initState();
    products = List();
    foodCategories = List();
    temp = List();
    _onNoteAddedSubscription =
        productReference.onChildAdded.listen(_onProductAdded);
    _onNoteChangedSubscription =
        productReference.onChildChanged.listen(_onProductUpdated);
    _onNoteDeleted = productReference.onChildRemoved.listen(_updateScreen);
    _addCategories = categoryReference.onChildAdded.listen(_updateCategories);
    if (products.length < 1) {
      isLoading = true;
    } else {
      isLoading = false;
    }
  }

  void _updateScreen(Event event) {
    for (int i = 0; i < products.length; i++) {
      if (products[i].id == event.snapshot.key) {
        print(event.snapshot.key);
        print(products[i].id);
        setState(() {
          products.remove(products[i]);
          refresh(selectedTitle);
        });
      }
    }
  }

  void _updateCategories(Event event) async {
    setState(() {
      foodCategories.add((new LoadCategories.fromSnapShot(event.snapshot)));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onNoteChangedSubscription.cancel();
    _onNoteAddedSubscription.cancel();
    _onNoteDeleted.cancel();
    _onProductFullYDeleted.cancel();
    _addCategories.cancel();
  }

  void _onProductAdded(Event event) {
    setState(() {
      products.add(new Note.fromSnapshot(event.snapshot));
      if (event.snapshot.value['category'] == selectedTitle) {
        temp.add(Note.fromSnapshot(event.snapshot));
      }
    });
  }

  void _onProductUpdated(Event event) {
    var oldProductValue =
        products.singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      products[products.indexOf(oldProductValue)] =
          Note.fromSnapshot(event.snapshot);
      if (selectedTitle == event.snapshot.value['category']) {
        refresh(selectedTitle);
      }
    });
  }

  void refresh(String category) {
    print(category);
    print(products.length);
    temp = [];
    for (int i = 0; i < products.length; i++) {
      if (products[i].category == category) {
        setState(() {
          temp.add(products[i]);
        });
      }
    }
    print(temp.length);
  }

  bool isLoading = false;
  List<LoadCategories> foodCategories;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (selectedTitle == null && foodCategories.length > 0) {
      selectedTitle = foodCategories[0].title;
    }
    refresh(selectedTitle);

    if (temp.length < 1) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Products', style: TextStyle(fontSize: 25
        ),)),
        elevation: 0.0,
        backgroundColor: Colors.black26.withOpacity(0.5),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: height / 10,
              color: Colors.black26.withOpacity(0.1),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodCategories.length,
                itemBuilder: (context, index) {
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
//                            refresh(selectedTitle);
                            temp = [];
                            for (int i = 0; i < products.length; i++) {
                              if (products[i].title == selectedTitle) {
                                setState(() {
                                  temp.add(products[i]);
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
                      if (temp.length < 1) {
                        isLoading = true;
                      } else {
                        isLoading = false;
                      }
                      return CartItemCard(
                          title: '${temp[position].title}',
                          price: '${temp[position].price}',
                          imgUrl: '${temp[position].imageurl}',
                          isvegi: temp[position].isvegi);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    Key key,
    @required this.title,
    @required this.price,
    @required this.imgUrl,
    @required this.isvegi,
  }) : super(key: key);

  final String title;
  final String price;
  final String imgUrl;
  final bool isvegi;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        width: width * 0.9,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black26.withOpacity(0.1),
        ),
        child: Row(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  width: width * 0.30,
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
//                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ModalProgressHUD(
                      inAsyncCall: true,
                      child: Container(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  width: width * 0.30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                        imgUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: width * 0.5,
                      padding: EdgeInsets.only(left: 15, top: 28),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                    isvegi
                        ? Container(
                            margin: EdgeInsets.only(top: 18),
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.lightGreen, width: 2)),
                            child: Center(
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: Colors.lightGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: 'Price : ',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'sans-serif',
                            fontSize: 16),
                      ),
                      TextSpan(
                        text: 'Rs.$price.00',
                        style: TextStyle(
                            color: Colors.lightGreen,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'sans-serif',
                            fontSize: 16),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  String _id;
  String _title;
  String _description;
  String _category;
  int _price;
  String _imageurl;
  bool _isvegi;

  Note(this._id, this._title, this._description, this._price, this._category,
      this._imageurl, this._isvegi, );

  Note.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._isvegi = obj['isvegi'];
    this._imageurl = obj['imageurl'];
    this._price = int.parse(obj['price']);
    this._category = obj['category'];
  }

  String get id => _id;

  String get title => _title;

  String get description => _description;

  String get category => _category;

  int get price => _price;

  String get imageurl => _imageurl;

  bool get isvegi => _isvegi;

  Note.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _title = snapshot.value['title'];
    _description = snapshot.value['description'];
    _isvegi = snapshot.value['isvegi'];
    _imageurl = snapshot.value['imageurl'];
    _isvegi = snapshot.value['isvegi'];
    _category = snapshot.value['category'];
    _price = snapshot.value['price'];
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
