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
}
