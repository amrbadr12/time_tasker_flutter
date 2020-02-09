import 'dart:math';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/models/task.dart';

class AppUtils {
  static Future<TimeOfDay> showTimePickerDialog(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static TimeOfDay formatHHMMTimeToTimeOfDay(String time){
    return TimeOfDay(hour:int.parse(time.split(":")[0]),minute: int.parse(time.split(":")[1]));
  }

  static int formatTimeOfDayToTimeInSeconds(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    var ms = dt.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static void showFlushBar(String title, String message, BuildContext context) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 5),
    )..show(context);
  }

  static DateTime convertMillisecondsSinceEpochToDateTime(int time) {
    return DateTime.fromMillisecondsSinceEpoch(time * 1000);
  }

  static bool checkIfDateIsToday(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(time.year, time.month, time.day);
    if (aDate == today) {
      return true;
    }
    return false;
  }

  static String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static String formatTimeToTwoDecimals(int time) {
    if (time.toString().length == 1) return '0$time';
    return time.toString();
  }

  static String formatTimeToHHMM(int hour, int minute){
    String formattedHour=formatTimeToTwoDecimals(hour);
    String formattedMinute=formatTimeToTwoDecimals(minute);
    return '$formattedHour:$formattedMinute h';
  }

  static List<int> calculateDurationFromStartAndEndDurationsinHoursAndMinutes(DateTime startDuration,DateTime endDuration){
    List<int> result=[];
    result.add(endDuration.hour-startDuration.hour);
    result.add(endDuration.minute-startDuration.minute);
    return result;
  }

  static double calculateTimePercentFromFormattedTime(String formattedTime,int defaultFormat){
    List<String> time = formattedTime.split(':');
    if(time.length>=1){
      int hour=int.parse(time[0]);
      return hour/defaultFormat.round();
    }
    return 0.0;
  }

  static double calculateTimePercentFromTotalBalance(int hour,int defaultFormat){
      return hour/defaultFormat.round();
  }

  static int calculateTimeBalanceFromFormattedTime(String formattedTime,int defaultFormat){
    List<String> time = formattedTime.split(':');
    if(time.length>=1){
      int hour=int.parse(time[0]);
      return defaultFormat-hour;
    }
    return 0;
  }

  static Color getRandomColor(){
    Random random = new Random();
    int randomNumber = random.nextInt(3);
    List<Color>colors=[kMainBlueColor,kTasksDateContainerColor,kTasksDateIconColor2];
    return colors[randomNumber];
  }

  static UITask formatDurationTaskToUIListComponenet(DurationTask task){
    DateTime duration=convertMillisecondsSinceEpochToDateTime(task.durationTime);
    DateTime date=convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask=UITask(task.id,task.taskName,formatTimeToHHMM(duration.hour, duration.minute),getRandomColor(),Jiffy(date).fromNow());
    return uiTask;
  }

  static UITask formatStartEndTaskToUIListComponenet(StartEndTask task){
    List<int>duration = calculateDurationFromStartAndEndDurationsinHoursAndMinutes(convertMillisecondsSinceEpochToDateTime(task.startTime)
    ,convertMillisecondsSinceEpochToDateTime(task.endTime));
    DateTime date=convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask=UITask(task.id,task.taskName,formatTimeToHHMM(duration[0], duration[1]),getRandomColor(),Jiffy(date).fromNow());
    return uiTask;
  }
}
