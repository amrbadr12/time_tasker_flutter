import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/home_screens/main_home_screen.dart';
import 'package:time_tasker/home_screens/name_entering_intro_screen.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<PageViewModel> pages = [
    PageViewModel(
      title: firstTitleText,
      body: firstBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/first_intro.png",
            height: introScreenImagesSize, width: introScreenImagesSize),
      ),
    ),
    PageViewModel(
      title: secondTitleText,
      body: secondBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/second_intro.png",
            height: introScreenImagesSize, width: introScreenImagesSize),
      ),
    ),
    PageViewModel(
      title: secondTitleText,
      body: thirdBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/third_intro.png",
            height: introScreenImagesSize, width: introScreenImagesSize),
      ),
    ),
    PageViewModel(
      title: fourthTitleText,
      body: fourthBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/fourth_intro.png",
            height: introScreenImagesSize, width: introScreenImagesSize),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      onDone: () async {
        SharedPerferencesUtils utils =
            SharedPerferencesUtils(await SharedPreferences.getInstance());
        utils.saveBoolToSharedPreferences(kShowIntroScreenKey, true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        print('done button pressed');
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
