import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/screens/settings_screen.dart';
import 'package:time_tasker/screens/video_player_screen.dart';
import 'package:time_tasker/services/init_services.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

void main() {
  configureDependencies();
  runApp(
    // DevicePreview(
    //   builder: (context) => MyApp(),
    // ),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TimeTasker',
        navigatorKey: navigatorKey,
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
          future: showIntroOrHomeScreen(context),
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

  Future<Widget> showIntroOrHomeScreen(BuildContext context) async {
    SharedPerferencesUtils utils =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    bool showHome = utils.getBoolFromSharedPreferences(kShowIntroScreenKey);
    return showHome
        ? SettingsScreen()
        : VideoApp(
            videoPath: 'images/intro_1.mp4',
            buttonTitle: 'Next',
            onTap: () {
              navigatorKey.currentState.push(MaterialPageRoute(
                  builder: (context) => VideoApp(
                        videoPath: 'images/intro_2.mp4',
                        buttonTitle: 'Start TimeTasking!',
                        onTap: () async {
                          SharedPerferencesUtils utils = SharedPerferencesUtils(
                              await SharedPreferences.getInstance());
                          utils.saveBoolToSharedPreferences(
                              kShowIntroScreenKey, true);
                          utils.saveIntToSharedPreferences(
                              kTotalBalanceHoursKey, 24);
                          utils.saveIntToSharedPreferences(
                              kTotalBalanceMinutesKey, 0);
                          navigatorKey.currentState.push(MaterialPageRoute(
                              builder: (context) => SettingsScreen()));
                        },
                      )));
            });
  }
}
