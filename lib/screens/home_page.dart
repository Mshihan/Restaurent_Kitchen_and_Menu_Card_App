import 'package:flutter/material.dart';
import 'package:flutterapp/screens/NavigationPage.dart';
import 'package:flutterapp/screens/landing_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Home Page',
            style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w600,
                fontFamily: 'Serif'),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            HomeCard(
              height: height,
              function: () {
                print('Customer View');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LandingPage()));
                },
              title: 'Customer View',
            ),
            HomeCard(
              height: height,
              function: () {
                print('Kitchen View');
                Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
              },
              title: 'Kitchen View',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key key,
    @required this.height,
    @required this.function,
    @required this.title,
  }) : super(key: key);

  final double height;
  final Function function;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: height * 0.4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xFFF3A32F),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          margin: EdgeInsets.all(50),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Serif'),
            ),
          ),
        ),
      ),
    );
  }
}
