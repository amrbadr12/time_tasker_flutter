import 'dart:async';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../constants.dart';
import 'home_screens/main_home_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPerferencesUtils _sharedPreferences;
  DeviceCalendarPlugin _deviceCalendarPlugin;
  List<String> _calendars = List();
  double _hoursSliderValue;
  double _minutesSliderValue;
  bool _currentResetSetting = false;
  TimeOfDay _timeSelected;
  int _timeSelectedInSeconds;
  String _selectedDropDownValue;
  bool _isCalendarPermissionsGranted = true;
  bool _isTimerPickerSelected = false;
  Timer _refreshTimer;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    getSharedPrefs();
    getDefaultCalendar();
    super.initState();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      getSharedPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(kAppName,
              textAlign: TextAlign.center,
              style: kAppBarTextStyle.copyWith(
                  fontSize: 22.0, color: Colors.blue)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
          // Padding(
          //     padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
          //     child: Text(
          //       'TimeTasker Settings',
          //       softWrap: true,
          //       style: kTitleTextStyle.copyWith(
          //           fontSize: 30.0, fontWeight: FontWeight.bold),
          //     )),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: Text('Set your time period',
                  style: kTitleTextStyle.copyWith(
                      fontSize: 20.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold))),
          SizedBox(
            height: 8.0,
          ),
          Slider(
              value: _hoursSliderValue ?? 1.0,
              divisions: 24,
              label: currentHoursSliderText,
              min: 0.0,
              max: 24.0,
              onChanged: (value) {
                setState(() {
                  _hoursSliderValue = value;
                  _isTimerPickerSelected = false;
                });
              }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
            child: Text('$currentHoursSliderText selected',
                softWrap: true, style: kInputAddTaskLabelTextStyle),
          ),
          Slider(
              value: _hoursSliderValue == 24.0
                  ? _minutesSliderValue = 0.0
                  : _minutesSliderValue ?? 1.0,
              divisions: 60,
              label: currentMinutesSliderText,
              min: 0.0,
              activeColor: kTasksDateIconColor2,
              inactiveColor: kTasksDateContainerColor,
              max: 60.0,
              onChanged: (value) {
                if (value == 60.0 && _hoursSliderValue < 24) {
                  _hoursSliderValue++;
                  _minutesSliderValue = 0;
                } else {
                  _minutesSliderValue = value;
                }
                _isTimerPickerSelected = false;
                setState(() {});
              }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
            child: Text('$currentMinutesSliderText selected',
                softWrap: true, style: kInputAddTaskLabelTextStyle),
          ),
          SizedBox(
            height: kMainDefaultPadding,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
              child: Text(
                  'You can adjust the time frame to calculate your tasks from 1 minute - 24 hours.',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))),
          SizedBox(
            height: kMainDefaultPadding,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
              child: Text('OR',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: DateInputField(
                    icon: Icon(
                      FontAwesomeIcons.clock,
                      size: 20.0,
                      color: kTasksDateIconColor1,
                    ),
                    containerColor: kTasksDateContainerColor,
                    text: _timeSelected != null
                        ? AppUtils.formatTimeOfDay(_timeSelected) + ' selected'
                        : 'Set the  time manually',
                    onDateChanged: () async {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime.now().add(Duration(days: 1)),
                          onConfirm: (date) {
                        try {
                          TimeOfDay temp =
                              TimeOfDay(hour: date.hour, minute: date.minute);
                          _timeSelected = temp;
                          _timeSelectedInSeconds = date.millisecondsSinceEpoch;
                          setState(() {
                            calculateSliderHoursAndMinutesFromDateTime(date);
                          });
                          saveSliderItemToLocal(() {});
                        } catch (e) {
                          print(
                              'Exception failed while setting the time with $e');
                        }
                      }, currentTime: DateTime.now());
                    },
                  ),
                ),
                Image.asset(
                  'images/timmi_1.png',
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ],
            ),
          ),

//          SwitchListTile(
//            contentPadding: EdgeInsets.all(0),
//            title: Padding(
//                padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
//                child: Text(
//                  'Enable re-set function',
//                  style: kInputAddTaskLabelTextStyle,
//                )),
//            value: _currentResetSetting,
//            activeColor: kTasksDateIconColor2,
//            onChanged: (bool value) {
//              setState(() {
//                _currentResetSetting = value;
//              });
//            },
//          ),
//          SizedBox(
//            height: 10.0,
//          ),
//          _isCalendarPermissionsGranted
//              ? Row(
//                  children: [
//                    Padding(
//                      padding:
//                          EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
//                      child: Text(
//                        'Default Calendar:',
//                        style: kInputAddTaskLabelTextStyle,
//                      ),
//                    ),
//                    Expanded(
//                      child: DropdownButton<String>(
//                        isExpanded: true,
//                        value: _selectedDropDownValue,
//                        onChanged: (String newValue) {
//                          setState(() {
//                            _selectedDropDownValue = newValue;
//                          });
//                        },
//                        items: _calendars
//                            .map<DropdownMenuItem<String>>((String value) {
//                          return DropdownMenuItem<String>(
//                            value: value,
//                            child: Text(
//                              value,
//                              style: kInputAddTaskLabelTextStyle.copyWith(
//                                  fontSize: 15),
//                            ),
//                          );
//                        }).toList(),
//                      ),
//                    ),
//                  ],
//                )
//              : Padding(
//                  padding:
//                      EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
//                  child: Text(
//                      'Please enable the calendar permission from your phone settings.',
//                      style:
//                          TextStyle(fontSize: 13.0, color: Colors.red[700]))),
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
                child: Text('Start TimeTasking!',
                    style: kAppBarTextStyle.copyWith(color: Colors.white)),
                onPressed: () {
                  saveSliderItemToLocal(() {
                    AppUtils.showFlushBar(
                        'Successful', 'Saved Successfully!', context);
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(TaskTypes.DurationTasks),
                      ),
                      (route) => false);
                },
              ),
            ),
          )
        ])));
  }

  void getSharedPrefs() async {
    _sharedPreferences =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    setState(() {
      _hoursSliderValue =
          readSliderItemFromLocal(kTotalBalanceHoursKey).toDouble();
      _minutesSliderValue =
          readSliderItemFromLocal(kTotalBalanceMinutesKey).toDouble();
      _currentResetSetting =
          readResetSettingFromLocal(kResetDialogSettingsOption);
      int timeSaved = _sharedPreferences
          .getIntFromSharedPreferences(kTimeSelectedSettingsKey);
      if (timeSaved != 0) {
        _isTimerPickerSelected = true;
        DateTime timeSavedDateTime =
            DateTime.fromMillisecondsSinceEpoch(timeSaved);
        calculateSliderHoursAndMinutesFromDateTime(timeSavedDateTime);
        if (_hoursSliderValue < 0 ||
            timeSavedDateTime.isBefore(DateTime.now())) {
          _hoursSliderValue = 0;
          _minutesSliderValue = 0;
          _timeSelected = null;
          saveSliderItemToLocal(() {});
          _sharedPreferences.saveIntToSharedPreferences(
              kTimeSelectedSettingsKey, 0);
        } else
          _timeSelected = AppUtils.formatDateTimeToTimeOfDay(timeSavedDateTime);
      }
    });
  }

  void saveSliderItemToLocal(Function onSuccess) {
    if (_sharedPreferences != null) {
      _sharedPreferences.saveIntToSharedPreferences(
          kTotalBalanceHoursKey, _hoursSliderValue.toInt());
      _sharedPreferences.saveIntToSharedPreferences(
          kTotalBalanceMinutesKey, _minutesSliderValue.toInt());
      _sharedPreferences.saveBoolToSharedPreferences(
          kResetDialogSettingsOption, _currentResetSetting);
      _sharedPreferences.saveStringToSharedPreferences(
          kSavedCalendarKey, _selectedDropDownValue);
      if (_timeSelected != null) {
        if (_isTimerPickerSelected && _timeSelectedInSeconds != null) {
          _sharedPreferences.saveIntToSharedPreferences(
              kTimeSelectedSettingsKey, _timeSelectedInSeconds);
        } else {
          if (!_isTimerPickerSelected)
            _sharedPreferences.saveIntToSharedPreferences(
                kTimeSelectedSettingsKey, 0);
        }
      }
      onSuccess();
    }
  }

  String get currentHoursSliderText {
    if (_hoursSliderValue != null) {
      String sliderValue = '${_hoursSliderValue.toStringAsFixed(0)}';
      if (_hoursSliderValue == 1.0) {
        return '$sliderValue hour';
      }
      return '$sliderValue hours';
    }
    return '';
  }

  String get currentMinutesSliderText {
    if (_minutesSliderValue != null) {
      String sliderValue = '${_minutesSliderValue.toStringAsFixed(0)}';
      if (_minutesSliderValue == 1.0) {
        return '$sliderValue minute';
      }
      return '$sliderValue minutes';
    }
    return '';
  }

  int readSliderItemFromLocal(String key) {
    if (_sharedPreferences != null) {
      return _sharedPreferences.getIntFromSharedPreferences(key);
    }
    return 0;
  }

  bool readResetSettingFromLocal(String key) {
    if (_sharedPreferences != null) {
      return _sharedPreferences.getBoolFromSharedPreferences(key);
    }
    return false;
  }

  getDefaultCalendar() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          setState(() {
            _isCalendarPermissionsGranted = false;
          });
          return;
        }
      }
      _isCalendarPermissionsGranted = true;
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final data = calendarsResult.data;
      for (Calendar calendar in data) {
        _calendars.add(calendar.name);
      }
      final localCalendar =
          _sharedPreferences.getStringFromSharedPreferences(kSavedCalendarKey);
      localCalendar != null
          ? _selectedDropDownValue = localCalendar
          : _selectedDropDownValue = _calendars[0];
      setState(() {});
    } catch (e) {}
  }

  void calculateSliderHoursAndMinutesFromDateTime(DateTime datePicked) {
    List<double> time =
        AppUtils.calculateTheDifferenceBetweenDatesInHoursAndMinutes(
            datePicked);
    _hoursSliderValue = time[0];
    _minutesSliderValue = time[1];
    _isTimerPickerSelected = true;
  }

  @override
  void dispose() {
    super.dispose();
    try {
      if (_refreshTimer != null) {
        _refreshTimer.cancel();
      }
    } catch (e) {}
  }
}
