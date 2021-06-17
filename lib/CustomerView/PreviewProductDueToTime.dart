import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterapp/screens/cart_page.dart';
import 'dart:async';
import 'package:flutterapp/screens/landing_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

//Product Class
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

//Database reference instance
final databaseReference = FirebaseDatabase.instance
    .reference()
    .child('products')
    .orderByChild('isavailable')
    .equalTo(true);

final categoryReference =
    FirebaseDatabase.instance.reference().child('categories');

class NoteLoad {
  String _id;
  String _title;
  String _description;
  String _category;
  int _price;
  String _imageurl;
  bool _isvegi;
  String _timecategory;

  NoteLoad(this._id, this._title, this._description, this._price,
      this._category, this._imageurl, this._isvegi, this._timecategory);

  NoteLoad.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._isvegi = obj['isvegi'];
    this._imageurl = obj['imageurl'];
    this._price = int.parse(obj['price']);
    this._category = obj['category'];
    this._timecategory = obj['timecategory'];
  }

  String get id => _id;
  String get title => _title;
  String get description => _description;
  String get category => _category;
  int get price => _price;
  String get imageurl => _imageurl;
  bool get isvegi => _isvegi;
  String get timecategory => _timecategory;

  NoteLoad.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _title = snapshot.value['title'];
    _description = snapshot.value['description'];
    _isvegi = snapshot.value['isvegi'];
    _imageurl = snapshot.value['imageurl'];
    _isvegi = snapshot.value['isvegi'];
    _category = snapshot.value['category'];
    _price = snapshot.value['price'];
    _timecategory = snapshot.value['timecategory'];
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

class ProductCategoryPage extends StatefulWidget {
  ProductCategoryPage({this.title, this.list});
  final String title;
  final List<CartProduct> list;
  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  List<NoteLoad> products;
  int selectedIndex = 0;
  List<LoadCategories> foodCategories;
  List<NoteLoad> temp;
  List<CartProduct> _cartNow;
  String selectedTitle;
  StreamSubscription<Event> _onChildAdded;
  StreamSubscription<Event> _onChildChanged;
  StreamSubscription<Event> _onChildDeleted;
  StreamSubscription<Event> _onCategoryAdded;
  String cartItems = '0';

  void updateCartItems() {
    int count = 0;
    int temp;
    for (int i = 0; i < _cartNow.length; i++) {
      temp = _cartNow[i].items;
      count += temp;
    }
    if (count < 1) {
      cartItems = '0';
    } else {
      cartItems = count.toString();
    }
  }

  @override
  void initState() {
    products = List();
    temp = List();
    foodCategories = List();
    super.initState();
    _onChildAdded = databaseReference.onChildAdded.listen(_onProductAdded);
    _onChildChanged =
        databaseReference.onChildChanged.listen(_onProductUpdated);
    _onChildDeleted = databaseReference.onChildRemoved.listen(_updateScreen);
    _onCategoryAdded = categoryReference.onChildAdded.listen(_updateCategories);
    _cartNow = widget.list;
    widget.list != null ? updateCartItems() : () {};
  }

  void _updateCategories(Event event) async {
    setState(() {
      foodCategories.add((new LoadCategories.fromSnapShot(event.snapshot)));
    });
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

  void _onProductUpdated(Event event) {
    var oldProductValue =
        products.singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      products[products.indexOf(oldProductValue)] =
          NoteLoad.fromSnapshot(event.snapshot);
      if (selectedTitle == event.snapshot.value['category'] &&
          event.snapshot.value['timecategory'] == widget.title) {
        refresh(selectedTitle);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onChildAdded.cancel();
    _onChildChanged.cancel();
    _onChildDeleted.cancel();
  }

  void refresh(String category) {
    print(category);
    print(products.length);
    temp = [];
    for (int i = 0; i < products.length; i++) {
      if (products[i].category == category &&
          products[i].timecategory == widget.title) {
        setState(() {
          temp.add(products[i]);
        });
      }
    }
    print(temp.length);
  }

  bool isLoading = false;

  void _onProductAdded(Event event) {
    setState(() {
      products.add(new NoteLoad.fromSnapshot(event.snapshot));
      if (event.snapshot.value['category'] == selectedTitle &&
          event.snapshot.value['timecategory'] == widget.title) {
        temp.add(NoteLoad.fromSnapshot(event.snapshot));
      }
      print(temp.length);
    });
    print(event.snapshot.value['timecategory']);
  }

  @override
  Widget build(BuildContext context) {
    updateCartItems();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (selectedTitle == null && foodCategories.length > 0) {
      selectedTitle = foodCategories[0].title;
    }
    refresh(selectedTitle);

    if (temp.length < 1) {
      isLoading = true;
    } else {
      isLoading = false;
    }

    void addToCart(CartProduct product) {
      int selection;
      bool isExited = false;
      if (_cartNow.length < 1) {
        product.items = 1;
        _cartNow.add(product);
      } else {
        for (int i = 0; i < _cartNow.length; i++) {
          if (_cartNow[i].title == product.title) {
            isExited = true;
            selection = i;
            break;
          } else {
            isExited = false;
          }
        }
        if (isExited == true) {
          int count = _cartNow[selection].items;
          _cartNow[selection].items = count + 1;
        } else {
          product.items = 1;
          _cartNow.add(product);
        }
      }
    }

    Future<bool> _onBackPressed() async {
      return false;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              widget.title,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: height / 10,
                  width: width,
                  color: Colors.black26.withOpacity(0.1),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: foodCategories.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: width / 70, left: width / 70),
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
                    child: Container(
                      width: width,
                      child: GridView.builder(
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: 3,
                          padding: EdgeInsets.all(15.0),
                          itemBuilder: (context, position) {
                            if (temp.length < 1) {
                              isLoading = true;
                            } else {
                              isLoading = false;
                            }
                            CartProduct _temp = CartProduct();

                            return Container(
//                              margin: position % 2 == 1 ? EdgeInsets.only( right: 10) : EdgeInsets.only( right: 10) ,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 200,
                                    child: Image.asset(
                                      'assets/prperoniPizza.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: width * 0.504 * 0.95,
                                    margin: EdgeInsets.only(top: 5, left: 8),
                                    child: Text(
                                      'Italiano Sphegetti Pasta',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 15, fontFamily: 'serif'),
                                    ),
                                  ),
                                  Container(
                                    width: width * 0.504 * 0.95,
                                    margin: EdgeInsets.only(top: 5, left: 8),
                                    child: Text(
                                      'Rs.850.00',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 15, fontFamily: 'serif'),
                                    ),
                                  ),
                                ],
                              ),
//                              child: Stack(
//                                children: <Widget>[
//                                  Column(
//                                    children: <Widget>[
//                                      Row(
//                                        children: <Widget>[
//                                          Container(
//                                            padding: EdgeInsets.all(20.0),
//                                            child: Container(
//                                                height: 160,
//                                                width: 160,
//                                                decoration: BoxDecoration(
//                                                    boxShadow: [
//                                                      BoxShadow(
//                                                          color: Colors.black38,
//                                                          offset: Offset(0, 5),
//                                                          blurRadius: 8)
//                                                    ]),
//                                                child: ClipRRect(
//                                                  borderRadius:
//                                                      BorderRadius.circular(10.0),
//                                                  child: Image.network(
//                                                    temp[position].imageurl,
//                                                    fit: BoxFit.cover,
//                                                  ),
//                                                )),
//                                          ),
//                                          Container(
//                                            width: width * 0.504 * 0.95,
//                                            height: 180,
//                                            decoration: BoxDecoration(
//                                              borderRadius:
//                                                  BorderRadius.circular(10.0),
//                                              color: Colors.amber.shade100,
//                                              boxShadow: [
//                                                BoxShadow(
//                                                    color: Colors.black38,
//                                                    offset: Offset(0, 5),
//                                                    blurRadius: 8)
//                                              ],
//                                            ),
//                                            child: Column(
//                                              crossAxisAlignment:
//                                                  CrossAxisAlignment.center,
//                                              children: <Widget>[
//                                                SizedBox(
//                                                  height: 20,
//                                                ),
//                                                Container(
//                                                    width: width * 0.504 * 0.95,
//                                                    child: Text(
//                                                      temp[position]
//                                                          .title
//                                                          .toUpperCase(),
//                                                      textAlign: TextAlign.center,
//                                                      style: TextStyle(
//                                                          fontSize: 25,
//                                                          fontFamily: 'serif'),
//                                                    )),
//                                                SizedBox(
//                                                  height: 10,
//                                                ),
//                                                Container(
//                                                  width: width * 0.504 * 0.5,
//                                                  child: Text(
//                                                    'Price : ${temp[position].price}.00',
//                                                    textAlign: TextAlign.left,
//                                                    style:
//                                                        TextStyle(fontSize: 15),
//                                                  ),
//                                                ),
//                                              ],
//                                            ),
//                                          )
//                                        ],
//                                      ),
//                                    ],
//                                  ),
//                                  Positioned(
//                                    right: 2,
//                                    bottom: 5,
//                                    child: GestureDetector(
//                                      onTap: () {
//                                        _temp.title = temp[position].title;
//                                        _temp.imageurl = temp[position].imageurl;
//                                        _temp.description =
//                                            temp[position].description;
//                                        _temp.isvegi = temp[position].isvegi;
//                                        _temp.price = temp[position].price;
//                                        _temp.category = temp[position].category;
//                                        _temp.id = temp[position].id;
//                                        addToCart(_temp);
//                                        setState(() {
//                                          updateCartItems();
//                                        });
//                                      },
//                                      child: Container(
//                                        height: 50,
//                                        width: 50,
//                                        decoration: BoxDecoration(
//                                          borderRadius: BorderRadius.circular(50),
//                                          color: Colors.amber,
//                                          boxShadow: [
//                                            BoxShadow(
//                                                color: Colors.black38,
//                                                offset: Offset(0, 5),
//                                                blurRadius: 8)
//                                          ],
//                                        ),
//                                        child: Icon(
//                                          Icons.add,
//                                          color: Colors.white,
//                                        ),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            color: Colors.red,
                            );
                          }),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, _cartNow);
                      },
                      child: Container(
                        height: height * 0.065,
                        width: height * 0.065,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFF3A32F),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                offset: Offset(0, 2),
                                blurRadius: 8)
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _cartNow = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(
                              list: _cartNow,
                            ),
                          ),
                        );
                        updateCartItems();
                      },
                      child: Container(
                        width: width * 0.5,
                        height: width * 0.2,
                        decoration: BoxDecoration(
                          color: Color(0xFFF3A32F),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 8)
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Icon(
                                Icons.shopping_cart,
                                size: 50,
                                color: Colors.white,
                              ),
                              Positioned(
                                top: 1,
                                right: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.redAccent,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 2),
                                            blurRadius: 10)
                                      ]),
                                  width: width * 0.05,
                                  height: width * 0.05,
                                  child: Center(
                                    child: Container(
                                      child: Text(
                                        cartItems,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
