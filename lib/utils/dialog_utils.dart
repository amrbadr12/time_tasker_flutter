
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUitls{


  static void showResetTasksDialog(String taskType,BuildContext context,Function onReset){
    showCupertinoDialog(context:context,
    builder: (context){
      return CupertinoAlertDialog(
        title:Text('Reset Time'),
        content:Text('Do you want to reset the time in recorded ${taskType.toLowerCase()} tasks?'),
        actions: <Widget>[
           FlatButton(
            child:Text('Cancel'),
            onPressed: (){
              Navigator.of(context).pop();
            },
            textColor:Colors.lightBlue,
          ),
            FlatButton(
            child:Text('Reset'),
            onPressed: (){
              Navigator.of(context).pop();
              onReset();
            },
            textColor:Colors.red[600],
          ),
        ],
      );
    });
  }
}