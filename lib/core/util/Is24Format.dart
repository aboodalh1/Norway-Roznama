import 'package:flutter/material.dart';

class Is24Format{
  static late bool is24TimeFormat;

  static void init(BuildContext context){
   is24TimeFormat = MediaQuery.of(context).alwaysUse24HourFormat;

  }
}