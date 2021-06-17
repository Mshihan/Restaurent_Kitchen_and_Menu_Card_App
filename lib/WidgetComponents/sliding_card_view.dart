import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SlideCard extends StatelessWidget {
  const SlideCard({
    Key key,
    this.height,
    this.title,
    this.description,
    this.imageAssert,
    this.width,
    this.price,
    this.isvegi,
    this.onPress,
  }) : super(key: key);

  final double height;
  final double width;
  final String title ;
  final String description;
  final String price;
  final bool isvegi;
  final String imageAssert;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    print(isvegi);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        height: height * 0.5,
        width: width * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageAssert),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            isvegi ? Positioned(
              left: 20,
              child: Container(
                margin: EdgeInsets.only(top: 18),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: Color(0xFFF3A32F).withOpacity(0.5),
                    border:
                    Border.all(color: Color(0xFF006400), width: 2)),
                child: Center(
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF006400),
                        shape: BoxShape.circle,
                      ),
                    )),
              ),
            ) : Container(),
            Positioned(
              left: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Apple Color Emoji'),
                    ),
                    width: width * 0.5,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: Text(
                      description,
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          fontFamily: 'Al Nile'),
                    ),
                    width: width * 0.43,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                height: height * 0.1,
                width: height * 0.1,
                decoration: BoxDecoration(
                  color: Color(0xFFF3A32F),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                    child: Text(
                  'Rs.$price',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                )),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: height * 0.05,
                height: height * 0.05,
                decoration: BoxDecoration(
                  color: Color(0xFFF3A32F),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: GestureDetector(
                    onTap: (){
                      onPress();
                    },child: Icon(Icons.add, color: Colors.white,)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
