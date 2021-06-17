import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OrderFromTable extends StatefulWidget {
  @override
  _OrderFromTableState createState() => _OrderFromTableState();
}

final productReference = FirebaseDatabase.instance.reference().child('/orders');

final ref = FirebaseDatabase.instance
    .reference()
    .child('/orders')
    .orderByChild('orderNo');

class _OrderFromTableState extends State<OrderFromTable> {
  StreamSubscription _onChildAdded;
  StreamSubscription _onChildChanged;
  List<Order> orders;
  List<Order> finalOrder;
  ScrollController _scrollController  = ScrollController();

  @override
  void initState() {
    super.initState();
    orders = List();
    finalOrder = List();
    _onChildAdded = ref.onChildAdded.listen(_refreshAddedChild);
    _onChildChanged = ref.onChildChanged.listen(_changeScreen);
  }

  void _changeScreen(Event event){
    var oldProductValue =
    orders.singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      orders[orders.indexOf(oldProductValue)] =
          Order.fromSnapshot(event.snapshot);
      finalOrder = []..addAll(orders.reversed);
    });
  }

  void _refreshAddedChild(Event event) {
    setState(() {
      orders.add(Order.fromSnapshot(event.snapshot));
      finalOrder = []..addAll(orders.reversed);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onChildAdded.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Order Preview', style: TextStyle(fontSize: 30))),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: finalOrder.length,
              itemBuilder: (context, index) {
                print(finalOrder[index].id);
                return Message(
                  tableNo: finalOrder[index].tableNo,
                  orderNo: finalOrder[index].orderNo,
                  order: finalOrder[index].dishes,
                  isaccepted: finalOrder[index].isaccepted,
                  iscancelled: finalOrder[index].iscancelled,
                  id: finalOrder[index].id,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  List<Items> _dishes = List();
  String _id;
  bool _isaccepted;
  bool _iscancelled;
  int _orderNo;
  int _tableNo;
  int _docketItems;
  String _title;
  int _count;

  Order(this._tableNo, this._id, this._dishes, this._isaccepted,
      this._iscancelled, this._orderNo, this._docketItems);

  String get id => _id;

  bool get isaccepted => _isaccepted;

  bool get iscancelled => _iscancelled;

  int get orderNo => _orderNo;

  int get tableNo => _tableNo;

  List get dishes => _dishes;

  int get docketItems => _docketItems;

  String get title => _title;

  int get count => _count;

  Order.map(dynamic obj) {
    this._id = obj['id'];
    this._tableNo = obj['tableNo'];
    this._orderNo = obj['orderNo'];
    this._iscancelled = obj['iscancelled'];
    this._docketItems = obj['docketItems'];
    this._isaccepted = obj['isaccepted'];
    for (int i = 0; i < _docketItems; i++) {
      Items items;
      items.title = obj['dishes'][i]['title'];
      items.count = obj['dishes'][i]['itemcount'];
      this._dishes.add(items);
    }
  }

  Items items;

  Order.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _docketItems = snapshot.value['docketItems'];
    for (int i = 0; i < _docketItems; i++) {
      Items items = Items(
          title: snapshot.value['dishes'][i]['title'],
          count: snapshot.value['dishes'][i]['itemcount']);
      _dishes.add(items);
    }
    _iscancelled = snapshot.value['iscancelled'];
    _isaccepted = snapshot.value['isaccepted'];
    _orderNo = snapshot.value['orderNo'];
    _tableNo = snapshot.value['tableNo'];
  }
}

class Items {
  var title;
  var count;

  Items({this.title, this.count});
}

class Message extends StatefulWidget {
  Message(
      {@required this.order,
      @required this.tableNo,
      @required this.orderNo,
      @required this.isaccepted,
      @required this.iscancelled,
      @required this.id});

  final List<Items> order;
  int tableNo;
  int orderNo;
  bool isaccepted;
  bool iscancelled;
  String id;

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Color _color = Colors.orangeAccent;
  Color _buttonAccept = Colors.green;
  Color _buttonCancel = Colors.red;
  bool isSelected = false;

  List<Widget> updateItemsList() {
    List<Widget> cart = [];
    for (int i = 0; i < order.length; i++) {
      var orderItem = Text(
        '${order[i].count} x ${order[i].title}',
        style: TextStyle(
          color: Colors.green,
          fontSize: 20,
        ),
      );
      cart.add(orderItem);
    }
    return cart;
  }



  //Update availability in Products
  Future<void> updateDetails(String id, bool accepted, bool cancelled) async {
    if(accepted && !cancelled) {
      await productReference.child(id).update({
        "isaccepted": true,
      });
    }else if(cancelled && !accepted){
      await productReference.child(id).update({
        "iscancelled": true,
      });
    }
  }

  Color checkColor(bool isaccepted, bool iscancelled) {
    if (isaccepted) {
      return Colors.greenAccent;
    } else if (iscancelled) {
      return Colors.redAccent;
    } else {
      return _color;
    }
  }

  List<Items> order;

  @override
  Widget build(BuildContext context) {
    order = widget.order;
    int tableNo = widget.tableNo;
    int orderNo = widget.orderNo;
    bool isaccepted = widget.isaccepted;
    bool iscancelled = widget.iscancelled;
    String id = widget.id;



    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      offset: Offset(2, 5),
                      blurRadius: 5)
                ],
                color: checkColor(isaccepted, iscancelled),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Order No: $orderNo",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 25,
                        fontFamily: 'serif'),
                  ),
                  Text(
                    "Table No: $tableNo",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 25,
                        fontFamily: 'serif'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: updateItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected == false) {
                    _color = Colors.greenAccent;
                    _buttonAccept = Colors.green.shade100;
                    _buttonCancel = Colors.red.shade100;
                    isSelected = true;
                    updateDetails(id, true, false);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                width: 50,
                height: 50,
                child: Center(child: Text('accept')),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: isaccepted || iscancelled
                      ? Colors.green.shade100
                      : _buttonAccept,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected == false) {
                    _color = Colors.redAccent;
                    _buttonAccept = Colors.green.shade100;
                    _buttonCancel = Colors.red.shade100;
                    isSelected = true;
                    updateDetails(id, false, true);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                width: 50,
                height: 50,
                child: Center(child: Text('cancel')),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: isaccepted || iscancelled
                      ? Colors.red.shade100
                      : _buttonCancel,
                ),
              ),
            ),
          ],
        )
      ],
    );
    ;
  }
}
