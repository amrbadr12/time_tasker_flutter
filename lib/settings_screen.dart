import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import 'constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPerferencesUtils _sharedPreferences;
  double _sliderValue;
  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                  child: Text(
                    'Change time frame to calculate your tasks',
                    softWrap: true,
                    style: kTitleTextStyle.copyWith(
                        fontSize: 30.0, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 50.0,
              ),
              Slider(
                  value: _sliderValue ?? 1.0,
                  divisions: 24,
                  label: currentSliderText,
                  min: 0.0,
                  max: 24.0,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  }),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                child: Text('$currentSliderText selected',
                    softWrap: true, style: kInputAddTaskLabelTextStyle),
              ),
              SizedBox(
                height: kTitleDefaultPaddingVertical,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: LinearGradient(colors: blueGradient)),
                  width: double.infinity,
                  child: FlatButton(
                    child: Text('Save Changes',
                        style: kAppBarTextStyle.copyWith(color: Colors.white)),
                    onPressed: () {
                      saveSliderItemToLocal(_sliderValue.toInt(), () {
                        AppUtils.showFlushBar('Successful',
                            'Changes successfully changed', context);
                        readSliderItemFromLocal();
                      });
                    },
                  ),
                ),
              )
            ])));
  }

  void getSharedPrefs() async {
    _sharedPreferences =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    _sliderValue = readSliderItemFromLocal().toDouble();
  }

  void saveSliderItemToLocal(int value, Function onSuccess) {
    if (_sharedPreferences != null) {
      _sharedPreferences.saveIntToSharedPreferences(
          kTotalBalanceKey, value.toInt());
      onSuccess();
    }
  }

  String get currentSliderText {
    if (_sliderValue != null) {
      String sliderValue = '${_sliderValue.toStringAsFixed(0)}';
      if (_sliderValue == 1.0) {
        return '$sliderValue hour';
      }
      return '$sliderValue hours';
    }
    return '';
  }

  int readSliderItemFromLocal() {
    if (_sharedPreferences != null) {
      int sliderValue;
      setState(() {
        sliderValue =
            _sharedPreferences.getIntFromSharedPreferences(kTotalBalanceKey);
      });
      return _sharedPreferences.getIntFromSharedPreferences(kTotalBalanceKey);
    }
    return 0;
  }
}
