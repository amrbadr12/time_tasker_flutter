import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../settings_screen.dart';

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
        child: Image.asset("images/timmi_4.png"),
      ),
    ),
    PageViewModel(
      title: secondTitleText,
      body: secondBodyText,
      decoration: introPageDecoration,
      image: Center(child: Image.asset("images/timmi_5.png")),
    ),
    PageViewModel(
      title: thirdTitleText,
      body: thirdBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/timmi_5.png"),
      ),
    ),
    PageViewModel(
      title: fourthTitleText,
      body: fourthBodyText,
      decoration: introPageDecoration,
      image: Center(
        child: Image.asset("images/timmi_2.png"),
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
        utils.saveIntToSharedPreferences(kTotalBalanceHoursKey, 24);
        utils.saveIntToSharedPreferences(kTotalBalanceMinutesKey, 0);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsScreen()));
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
