import 'package:flutter/material.dart';
import 'package:flutterapp/CustomerView/PreviewProductDueToTime.dart';
import 'package:flutterapp/screens/landing_page.dart';


class DayTimeIcons extends StatelessWidget {
  const DayTimeIcons({
    Key key,
    @required this.width,
    @required this.icon,
    @required this.title,
    @required this.function,
    this.list,
  }) : super(key: key);

  final double width;
  final IconData icon;
  final String title;
  final List<CartProduct> list;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RawMaterialButton(
          elevation: 5.0,
          onPressed: () {
            function();
          },
          fillColor: Colors.white,
          hoverElevation: 8.0,
          hoverColor: Color(0x20F3A32F),
          highlightColor: Color(0x20F3A32F),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          constraints: BoxConstraints(
            minWidth: width * 0.17,
            minHeight: width * 0.17,
          ),
          child: Icon(
            icon,
            color: Color(0xFFF3A32F),
            size: 30,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.black45,
              fontFamily: 'Party LET'),
        )
      ],
    );
  }
}
