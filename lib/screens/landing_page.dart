import 'package:flutter/material.dart';
import 'package:flutterapp/CustomerView/PreviewProductDueToTime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../WidgetComponents/custom_app_bar.dart';
import '../WidgetComponents/sliding_card_view.dart';
import '../WidgetComponents/time_of_the_day.dart';
import 'cart_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

final databaseReference = FirebaseDatabase.instance
    .reference()
    .child('products')
    .orderByChild('isavailable')
    .equalTo(true);
final categoryReference =
    FirebaseDatabase.instance.reference().child('categories');

class _LandingPageState extends State<LandingPage> {
  StreamSubscription<Event> _onChildAdded;
  StreamSubscription<Event> _onChildChanged;
  StreamSubscription<Event> _onChildDeleted;
  StreamSubscription<Event> _addCategories;
  ScrollController _scrollController;
  List<NoteLoad> _generalProductList;
  List<LoadCategories> _categories;
  List<CartProduct> _cartNow;
  List<NoteLoad> _temp;
  bool isLoading = false;
  int selectedIndex = 0;
  String cartItems = '0';
  String selectedTitle;
  double width;
  double height;

  @override
  void initState() {
    super.initState();
    _generalProductList = List();
    _categories = List();
    _temp = List();

    _scrollController = ScrollController();
    _onChildAdded =
        databaseReference.onChildAdded.listen(_onChildAddedUpdateScreen);
    _onChildChanged =
        databaseReference.onChildChanged.listen(_onChildChangedUpdateScreen);
    _onChildDeleted =
        databaseReference.onChildRemoved.listen(_onChildDeletedUpdateScreen);
    _addCategories =
        categoryReference.onChildAdded.listen(_loadCategoriesToScreen);
    _cartNow = List();
  }

  void _loadCategoriesToScreen(Event event) {
    setState(() {
      _categories.add(LoadCategories.fromSnapShot(event.snapshot));
    });
  }

  void _onChildAddedUpdateScreen(Event event) {
    setState(() {
      _generalProductList.add(NoteLoad.fromSnapshot(event.snapshot));
      refresh(selectedTitle);
      if (event.snapshot.value['category'] == selectedTitle) {
        _temp.add(NoteLoad.fromSnapshot(event.snapshot));
      }
    });
  }

  void _onChildChangedUpdateScreen(Event event) {
    var oldProductValue = _generalProductList
        .singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      _generalProductList[_generalProductList.indexOf(oldProductValue)] =
          NoteLoad.fromSnapshot(event.snapshot);
      if (selectedTitle == event.snapshot.value['category']) {
        refresh(selectedTitle);
      }
    });
  }

  void _onChildDeletedUpdateScreen(Event event) {
    for (int i = 0; i < _generalProductList.length; i++) {
      if (_generalProductList[i].id == event.snapshot.key) {
        setState(() {
          _generalProductList.remove(_generalProductList[i]);
          refresh(selectedTitle);
        });
      }
    }
  }

  void refresh(String category) {
    _temp = [];
    for (int i = 0; i < _generalProductList.length; i++) {
      if (_generalProductList[i].category == category) {
        setState(() {
          _temp.add(_generalProductList[i]);
        });
      }
    }
    setState(() {
      _temp.length < 1 ? isLoading = true : isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onChildAdded.cancel();
    _onChildChanged.cancel();
    _onChildDeleted.cancel();
    _addCategories.cancel();
  }

  CartProduct newCartProduct = CartProduct();

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

  void printdetails(NoteLoad note) {
    print(note.title);
    print(note.description);
    print(note.imageurl);
    print(note.isvegi);
    print(note.category);
    print(note.price);
    print(note.id);
  }

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

  Widget iconDayTime() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DayTimeIcons(
              width: width,
              icon: Icons.fastfood,
              title: 'Breakfast',
              list: _cartNow,
              function: () async {
                _cartNow = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCategoryPage(
                      title: 'Breakfast',
                      list: _cartNow,
                    ),
                  ),
                );
                setState(() {
                  updateCartItems();
                });
              }),
          DayTimeIcons(
              width: width,
              icon: Icons.local_dining,
              title: 'Lunch',
              function: () async {
                _cartNow = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductCategoryPage(title: 'Lunch', list: _cartNow),
                  ),
                );
                setState(() {
                  updateCartItems();
                });
              }),
          DayTimeIcons(
              width: width,
              icon: Icons.local_pizza,
              title: 'Snacks',
              function: () async {
                _cartNow = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductCategoryPage(title: 'Snacks', list: _cartNow),
                  ),
                );
                setState(() {
                  updateCartItems();
                });
              }),
          DayTimeIcons(
              width: width,
              icon: Icons.restaurant,
              title: 'Dinner',
              function: () async {
                _cartNow = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductCategoryPage(title: 'Dinner', list: _cartNow),
                  ),
                );
                setState(() {
                  updateCartItems();
                });
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (selectedTitle == null && _categories.length > 0) {
      selectedTitle = _categories[0].title;
    }
    updateCartItems();
    refresh(selectedTitle);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CustomAppBar(),
            Container(
              height: height / 10,
              color: Colors.white30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
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
                          setState(() {
                            selectedIndex = index;
                            selectedTitle = _categories[index].title;
                            _scrollController.position.jumpTo(0);
                            refresh(selectedTitle);
                          });
                        },
                        child: Text(
                          _categories[index].title,
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
            SizedBox(
              height: height / 200,
            ),
            Container(
              height: height * 0.45,
              child: ModalProgressHUD(
                inAsyncCall: isLoading,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: _temp.length,
                  itemBuilder: (context, index) {
                    CartProduct temp = CartProduct();
                    return SlideCard(
                      title: _temp[index].title,
                      height: height,
                      width: width,
                      description: _temp[index].description,
                      imageAssert: _temp[index].imageurl,
                      price: _temp[index].price.toString(),
                      isvegi: _temp[index].isvegi,
                      onPress: () {
                        temp.title = _temp[index].title;
                        temp.imageurl = _temp[index].imageurl;
                        temp.description = _temp[index].description;
                        temp.isvegi = _temp[index].isvegi;
                        temp.price = _temp[index].price;
                        temp.category = _temp[index].category;
                        temp.id = _temp[index].id;
                        addToCart(temp);
                        setState(() {
                          updateCartItems();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: height / 50,
            ),
            iconDayTime(),
            SizedBox(
              height: height / 25,
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
      ),
    );
  }
}

class NoteLoad {
  String _id;
  String _title;
  String _description;
  String _category;
  int _price;
  String _imageurl;
  bool _isvegi;

  NoteLoad(this._id, this._title, this._description, this._price,
      this._category, this._imageurl, this._isvegi);

  NoteLoad.map(dynamic obj) {
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

  NoteLoad.fromSnapshot(DataSnapshot snapshot) {
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

class CartProduct {
  String id;
  String title;
  String description;
  String category;
  int price;
  String imageurl;
  bool isvegi;
  int items;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items,
    };
  }
}
