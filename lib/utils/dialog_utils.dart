import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
}
