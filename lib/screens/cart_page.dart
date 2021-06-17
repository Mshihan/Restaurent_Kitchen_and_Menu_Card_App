import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/screens/landing_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'addProducts.dart';

class CartScreen extends StatefulWidget {
  CartScreen({this.list});

  final List<CartProduct> list;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<bool> _onBackPressed() async {
    return false;
  }

  ScrollController controller = ScrollController();

  List<CartItemCard> addToList(List<CartProduct> list) {
    List<CartItemCard> cartList = [];
    for (int i = 0; i < list.length; i++) {
      CartItemCard item = CartItemCard(
          title: list[i].title,
          isvegi: list[i].isvegi,
          price: list[i].price.toString(),
          imgUrl: list[i].imageurl,
          qty: list[i].items.toString(),
          functionAdd: () {
            setState(() {
              list[i].items = (list[i].items + 1);
              updateCount(list);
            });
          },
          functionSub: () {
            setState(() {
              if (list[i].items == 1) {
                list.remove(list[i]);
              } else {
                list[i].items = (list[i].items - 1);
              }
              updateCount(list);
            });
          });
      cartList.add(item);
    }
    return cartList;
  }

  void showDialogPopUpEmptyList() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Order Confirmation",
              style: TextStyle(color: Color(0xFFF3A32F), fontSize: 25),
            ),
            content: Text(
              "Please Add Products to Cart",
              style: TextStyle(color: Colors.black54),
            ),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              FlatButton(
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showDialogPopUp(List<CartProduct> list) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Order Confirmation",
              style: TextStyle(color: Color(0xFFF3A32F), fontSize: 25),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Do you Confirm Your Order?",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              FlatButton(
                child: Text(
                  "No",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  Navigator.of(context).pop();
                  await updateDatabase(list);
                },
              ),
            ],
          );
        });
  }

  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child("orders");
  StreamSubscription<Event> _updateChild;

  int orderNo;

  Future<void> updateDatabase(List<CartProduct> product) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("orders")
        .orderByChild('orderNo')
        .limitToLast(1);
    await db.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          orderNo = values["orderNo"];
        });
      }
    });

    if (orderNo == null) {
      orderNo = 100;
    } else {
      orderNo++;
    }

    String plateDetails;
    String items =
        '{"orderNo":$orderNo,"tableNo":$_tableNo,"isaccepted": false, "docketItems": ${product.length},"iscancelled": false,"reason": "No","dishes": {';

    for (int i = 0; i < product.length; i++) {
      String temp;
      String category;
      String title = '"title":"${product[i].title}"';
      String item = '"itemcount":${product[i].items}';
      String coma;

      if (i != 0) {
        coma = ',';
      } else {
        coma = '';
      }
      category = '$coma"$i":{$title,$item}';
      temp = items;
      items = (temp + category);
    }
    plateDetails = items;
    items = plateDetails + "}}";
    String key;
    Map firebaseQuery = jsonDecode(items);
    DatabaseReference ref = reference.push();
    key = ref.key;
    await reference.child(key).set(firebaseQuery);
    _updateChild = reference.onChildChanged.listen(_updateScreen);
  }

  bool finalMessage = false;
  int existed = 0;

  void _updateScreen(Event event) {
    if (event.snapshot.value['isaccepted'] == true) {
      existed++;
      setState(() {
        finalMessage = true;
      });
      showFinalmessage(finalMessage, existed);
      setState(() {
        isLoading = false;
      });
    } else if (event.snapshot.value['iscancelled'] == true) {}
  }

  void showFinalmessage(bool finalMessage, int existed) {
    if (finalMessage && existed == 1) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Order Confirmation",
                style: TextStyle(color: Color(0xFFF3A32F), fontSize: 25),
              ),
              content: Text(
                "Order Confirmed By kitchen !\n OrderNo: $orderNo",
                style: TextStyle(color: Colors.black54),
              ),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                FlatButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    list = [];
                    Navigator.pop(context, list);
                  },
                ),
              ],
            );
          });
    }
  }

  int _tableNo = 1;
  int _total = 0;
  bool isLoading = false;

  void updateCount(List<CartProduct> list) {
    _total = 0;
    for (int i = 0; i < list.length; i++) {
      _total = _total + (list[i].items * list[i].price);
    }
  }

  List<CartProduct> list;

  @override
  void dispose() {
    super.dispose();
    _updateChild.cancel();
  }

  @override
  void initState() {
    super.initState();
    list = List();
    list = widget.list;
    updateCount(list);
  }

  @override
  Widget build(BuildContext context) {
//    List list = widget.list;
//    updateCount(list);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CartAppBar(
                  height: height,
                  width: width,
                ),
                Expanded(
                  child: Container(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: addToList(list),
                    ),
                  ),
                ),
                Container(
                  height: height * 0.23,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            right: 35.0, left: 35.0, top: 20, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                fontFamily: 'sans-serif',
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'Rs. $_total.00',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                                fontFamily: 'sans-serif',
                                color: Colors.lightGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Select Your Table Number ',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.w400),
                              ),
                              Row(children: <Widget>[
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tableNo++;
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 40,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45,
                                                offset: Offset(1, 2),
                                                blurRadius: 5),
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5.0),
                                              bottomLeft:
                                                  Radius.circular(5.0))),
                                    )),
                                Container(
                                  height: 50,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      '$_tableNo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 25),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black45,
                                          offset: Offset(1, 2),
                                          blurRadius: 5),
                                    ],
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_tableNo == 1) {
                                        _tableNo = 1;
                                      } else {
                                        _tableNo--;
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 40,
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black45,
                                              offset: Offset(2, 2),
                                              blurRadius: 5),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(5.0),
                                            topRight: Radius.circular(5.0))),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 35.0, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context, list);
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
                              onTap: () {
                                if (list.length < 1) {
                                  showDialogPopUpEmptyList();
                                } else {
                                  showDialogPopUp(list);
                                }
                              },
                              child: Container(
                                height: height * 0.065,
                                width: height * 0.3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 2),
                                        blurRadius: 8)
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text(
                                  'Confirm Order',
                                  style: TextStyle(
                                      color: Color(0xFFF3A32F),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    @required this.qty,
    @required this.functionAdd,
    @required this.functionSub,
    @required this.isvegi,
  }) : super(key: key);

  final String title;
  final String price;
  final String qty;
  final bool isvegi;
  final String imgUrl;
  final Function functionAdd;
  final Function functionSub;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
//        width: width * 0.9,
        height: 150,
        child: Row(
          children: <Widget>[
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: width * 0.50,
                      padding: EdgeInsets.only(left: 15, top: 18),
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
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Center(
                                child: Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            )),
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
                Row(
//                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: functionAdd,
                            child: Container(
                              height: 30,
                              width: 40,
                              child: Icon(
                                Icons.add,
                                color: Colors.black54,
                                size: 20,
                              ),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(1, 2),
                                        blurRadius: 5),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0))),
                            ),
                          ),
                          GestureDetector(
                            onTap: functionSub,
                            child: Container(
                              height: 30,
                              width: 40,
                              child: Icon(
                                Icons.remove,
                                color: Colors.black54,
                                size: 20,
                              ),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(2, 2),
                                        blurRadius: 5),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(5.0),
                                      topRight: Radius.circular(5.0))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * 0.20,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: Text(
                        'Qty : $qty',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartAppBar extends StatelessWidget {
  CartAppBar({this.width, this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Center(
        child: Text(
          'CART',
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontFamily: 'sans-serif',
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
