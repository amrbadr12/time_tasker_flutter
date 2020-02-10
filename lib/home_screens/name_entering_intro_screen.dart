import 'package:flutter/material.dart';

import '../constants.dart';

class NameEnteringIntroScreen extends StatefulWidget {
  @override
  _NameEnteringIntroScreenState createState() =>
      _NameEnteringIntroScreenState();
}

class _NameEnteringIntroScreenState extends State<NameEnteringIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                  child: Text(
                    'Just Wrapping Up!',
                    softWrap: true,
                    style: kTitleTextStyle.copyWith(
                        fontSize: 30.0, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: kMainDefaultHeightPadding,
              ),
              Center(
                  child: Image.asset(
                'images/launch_illustration.png',
                width: 500.0,
                height: 300.0,
              )),
              SizedBox(
                height: kMainDefaultHeightPadding,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                      child: Text(
                        'Enter your name to proceed.',
                        softWrap: true,
                        style: kSubTitleTextStyle.copyWith(fontSize: 18.0),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                    child: TextField(
                      onChanged: (value) {},
                      style: kInputAddTaskLabelTextStyle,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelStyle: kInputAddTaskLabelTextStyle,
                        hintText: 'Your Name',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ));
  }
}
