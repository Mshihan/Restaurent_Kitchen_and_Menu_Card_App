import 'package:flutter/material.dart';
import 'package:flutterapp/screens/home_page.dart';
import 'package:flutterapp/screens/landing_page.dart';

void main() => runApp(ClientApp());

class ClientApp extends StatefulWidget {
  @override
  _ClientAppState createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFFF3A32F),

      ),
//          fontFamily: 'SF Pro Display'),

      title: 'Menu Card App',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
