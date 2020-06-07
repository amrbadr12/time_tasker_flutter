import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import 'constants.dart';

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
  String _selectedDropDownValue;
  bool _isCalendarPermissionsGranted = true;
  bool _isTimerPickerSelected = false;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    getSharedPrefs();
    getDefaultCalendar();
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
              child: Text(
                'TimeTasker Settings',
                softWrap: true,
                style: kTitleTextStyle.copyWith(
                    fontSize: 30.0, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 50.0,
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
                setState(() {
                  _minutesSliderValue = value;
                  _isTimerPickerSelected = false;
                });
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
            child: DateInputField(
              icon: Icon(
                FontAwesomeIcons.clock,
                size: 20.0,
                color: kTasksDateIconColor1,
              ),
              containerColor: kTasksDateContainerColor,
              text: _timeSelected != null
                  ? AppUtils.formatTimeOfDay(_timeSelected) + ' selected'
                  : 'Or set the  time',
              onDateChanged: () async {
                TimeOfDay temp = await AppUtils.showTimePickerDialog(context);
                if (AppUtils.checkIfTimePickerDateIsToday(temp)) {
                  _timeSelected = temp;
                  setState(() {
                    calculateSliderHoursAndMinutesFromTimeOfDay(
                      _timeSelected,
                    );
                  });
                }
              },
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
          SizedBox(
            height: 10.0,
          ),
          _isCalendarPermissionsGranted
              ? Row(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                      child: Text(
                        'Default Calendar:',
                        style: kInputAddTaskLabelTextStyle,
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDropDownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            _selectedDropDownValue = newValue;
                          });
                        },
                        items: _calendars
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: kInputAddTaskLabelTextStyle.copyWith(
                                  fontSize: 15),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
                  child: Text(
                      'Please enable the calendar permission from your phone settings.',
                      style:
                          TextStyle(fontSize: 13.0, color: Colors.red[700]))),
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
                  saveSliderItemToLocal(() {
                    AppUtils.showFlushBar(
                        'Successful', 'Changes successfully changed', context);
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
            AppUtils.convertMillisecondsSinceEpochToDateTime(timeSaved);
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
        if (_isTimerPickerSelected) {
          _sharedPreferences.saveIntToSharedPreferences(
              kTimeSelectedSettingsKey,
              AppUtils.formatTimeOfDayToTimeInSeconds(_timeSelected));
        } else {
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

  void calculateSliderHoursAndMinutesFromTimeOfDay(TimeOfDay tod) {
    DateTime nowDate = DateTime.now();
    DateTime selectedTimeOfDay = AppUtils.formatTimeOfDayToDateTime(tod);
    if (selectedTimeOfDay.hour < nowDate.hour) return;
    List<int> time = AppUtils.minusTime(selectedTimeOfDay.hour, nowDate.hour,
        selectedTimeOfDay.minute, nowDate.minute);
    _hoursSliderValue = double.parse(time[0].toString());
    _minutesSliderValue = double.parse(time[1].toString());
    _isTimerPickerSelected = true;
  }
}
