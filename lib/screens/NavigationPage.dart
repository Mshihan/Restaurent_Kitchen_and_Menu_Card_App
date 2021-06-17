import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/screens/order_details_preview.dart';
import 'addProducts.dart';
import 'preview_products.dart';
import 'availability_change_products.dart';
import 'add_product_categories.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Products Manipulation',
          style: TextStyle(color: Colors.white),
        )),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Wrap(
              children: <Widget>[
                NavigationCard(
                  height: height,
                  width: width,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddProducts()));
                  },
                  title: 'Add Products',
                  icon: Icons.add_circle_outline,
                ),
                NavigationCard(
                  height: height,
                  width: width,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PreviewPage()));
                  },
                  title: 'View Products',
                  icon: Icons.photo_library,
                ),
                NavigationCard(
                  height: height,
                  width: width,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProductManipulationPage()));
                  },
                  title: 'Maipulate Product availability',
                  icon: Icons.iso,
                ),
                NavigationCard(
                  height: height,
                  width: width,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OrderFromTable()));
                  },
                  title: 'Orders From Table',
                  icon: Icons.fastfood,
                ),
                NavigationCard(
                  height: height,
                  width: width,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProductCategories()));
                  },
                  title: 'Add Categories',
                  icon: Icons.category,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NavigationCard extends StatelessWidget {
  const NavigationCard(
      {Key key,
      @required this.height,
      @required this.width,
      @required this.title,
        @required this.icon,
      @required this.function})
      : super(key: key);

  final double height;
  final double width;
  final String title;
  final Function function;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: height * 0.3,
        width: width * 0.305,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFF3A32F),
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 35,
              color: Colors.white,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20,),
              textAlign: TextAlign.center,
            ),
          ],
        )),
      ),
    );
  }
}

//Navigator.push(
//context,
//MaterialPageRoute(
//builder: (context) => PreviewPage(),
//),
//);
