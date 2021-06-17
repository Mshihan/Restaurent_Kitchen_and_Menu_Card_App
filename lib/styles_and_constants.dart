import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Add Product Page Styles

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
  labelText: 'non',
  fillColor: Colors.white,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFF3A32F), width: 0.8),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Color(0xFFF3A32F), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);


const kTextColumnHeading = TextStyle(color: Colors.black54, fontSize: 18);
