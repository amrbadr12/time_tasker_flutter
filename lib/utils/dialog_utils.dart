import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

class DialogUtils {
  static void showResetTasksDialog(
      String taskType, BuildContext context, Function onReset) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Reset Time'),
            content: Text(
                'Do you want to reset the time in recorded ${taskType.toLowerCase()} tasks?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textColor: Colors.lightBlue,
              ),
              FlatButton(
                child: Text('Reset'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onReset();
                },
                textColor: Colors.red[600],
              ),
            ],
          );
        });
  }

  static Future<bool> showConfirmDeleteDialog(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Delete Task'),
            content: Text('Are you sure you want to delete this task?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                textColor: Colors.lightBlue,
              ),
              FlatButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.red[600],
              ),
            ],
          );
        });
  }

  static Future<bool> showDurationExceedDialog(
      BuildContext context, String errorText) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Duration is more than selected time frame'),
            content: Text(errorText),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.lightBlue,
              ),
            ],
          );
        });
  }

  static Future<bool> showCalendarTasksNotFoundDialog(
      BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('No tasks found...'),
            content:
                Text('Time Tasker could\'t found any tasks in this calendar.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.lightBlue,
              ),
            ],
          );
        });
  }

  static Future<bool> showBedSleepTasksDialog(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Record till rest of the day'),
            content:
                Text('Would you like to record this till the rest of the day?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                textColor: Colors.lightBlue,
              ),
              FlatButton(
                child: Text('Record'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.red[600],
              ),
            ],
          );
        });
  }

  static Future<bool> showAddTaskToCalendarDialog(BuildContext context) async {
    bool res = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Sync this task with your Calendar?'),
            content: Text(
                'Would you like to add this task to your device\'s calendar?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                textColor: Colors.lightBlue,
              ),
              FlatButton(
                child: Text('Sync'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.red[600],
              ),
            ],
          );
        });
    return res;
  }

  static Future<bool> showTasksFromCalendarDialog(
      BuildContext context, List events) async {
    String task = 'tasks';
    if (events.length == 1) task = 'task';
    bool res = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('${events.length} Calendar $task found.'),
            content: Text('Would you like to sync them with TT?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                textColor: Colors.lightBlue,
              ),
              FlatButton(
                child: Text('Sync'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                textColor: Colors.red[600],
              ),
            ],
          );
        });
    return res;
  }

  static Future<String> showAvailableCalendarsDialog(
      BuildContext context, List<Calendar> calendars) async {
    List<String> calendarStrings = List();
    for (Calendar calendar in calendars) {
      calendarStrings.add(calendar.name);
    }
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          String selectedCalendar = calendarStrings[0];
          return CupertinoAlertDialog(
            title: Text('Select which calendar you want to sync with'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: kMainDefaultPadding,
                ),
                Text('Calendar:'),
                SizedBox(
                  height: 10.0,
                ),
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Material(
                    color: Colors.grey[300],
                    child: DropdownButton<String>(
                      value: selectedCalendar,
                      onChanged: (String newValue) {
                        setState(() {
                          selectedCalendar = newValue;
                        });
                      },
                      items: calendarStrings
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textColor: Colors.red[800],
              ),
              FlatButton(
                child: Text('Select'),
                onPressed: () {
                  Navigator.of(context).pop(selectedCalendar);
                },
                textColor: Colors.lightBlue,
              ),
            ],
          );
        });
  }
}
