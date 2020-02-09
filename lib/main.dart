import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/home_screens/main_home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTasker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: appBarColor,
        appBarTheme: AppBarTheme(
          color:Colors.grey[100],elevation:2.0,iconTheme: IconThemeData(
            color:Colors.grey[700],
          ),),
        primarySwatch: Colors.blue),
      home: HomeScreen()
    );
  }
}



