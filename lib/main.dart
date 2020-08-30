import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/intro_screens/intro_screen.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import 'add_task_screens/add_task_screen.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context) => MyApp(),
    ),
    // MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TimeTasker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            backgroundColor: appBarColor,
            appBarTheme: AppBarTheme(
              color: Colors.grey.shade200,
              brightness: Platform.isIOS ? Brightness.light : null,
              elevation: 2.0,
              iconTheme: IconThemeData(
                color: Colors.grey[700],
              ),
            ),
            primarySwatch: Colors.blue),
        home: FutureBuilder<Widget>(
          future: showIntroOrHomeScreen(),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ));
              default:
                if (snapshot.hasError)
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ));
                else
                  return snapshot.data;
            }
          },
        ));
  }

  Future<Widget> showIntroOrHomeScreen() async {
    SharedPerferencesUtils utils =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    bool showHome = utils.getBoolFromSharedPreferences(kShowIntroScreenKey);
    return showHome
        ? AddTaskScreen(
            navigateToHome: true,
          )
        : IntroScreen();
  }
}
