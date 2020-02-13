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

  static TimeOfDay formatHHMMTimeToTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
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
      duration: Duration(seconds: 3),
    )..show(context);
  }

  static List<int> addTime(
      int currentHour, int hourToAdd, int currentMinute, int minuteToAdd) {
    int resultMinute;
    int resultHour;
    if (currentMinute + minuteToAdd <= 60) {
      resultMinute = currentMinute + minuteToAdd;
      resultHour = currentHour + hourToAdd;
    } else {
      resultHour = currentHour + hourToAdd + 1;
      resultMinute = (currentMinute + minuteToAdd) - 60;
    }
    return [resultHour, resultMinute];
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

  static String formatTimeToHHMM(int hour, int minute) {
    String formattedHour = formatTimeToTwoDecimals(hour);
    String formattedMinute = formatTimeToTwoDecimals(minute);
    return '$formattedHour:$formattedMinute h';
  }

  static List<int> calculateDurationFromStartAndEndDurationsinHoursAndMinutes(
      DateTime startDuration, DateTime endDuration) {
    List<int> result = [];
    result.add(endDuration.hour - startDuration.hour);
    result.add(endDuration.minute - startDuration.minute);
    return result;
  }

  static double calculateTimePercentFromFormattedTime(
      String formattedTime, int defaultFormat) {
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      return hour / defaultFormat.round();
    }
    return 0.0;
  }

  static List<StartEndTask> getTheTodayUpcomingTasks(List<StartEndTask> tasks) {
    List<StartEndTask> upcomingTasks = List();
    for (StartEndTask task in tasks) {
      print('all today tasks ${task.taskName} and date ${task.date}');
      if (currentTimeInSeconds() < task.startTime) {
        upcomingTasks.add(task);
        print('today tasks ${task.taskName} and date ${task.date}');
      }
    }
    return upcomingTasks;
  }

  static UITask getUpcomingTask(List<StartEndTask> tasks) {
    if (tasks == null) return null;
    UITask result;
    StartEndTask nearestTask;
    DateTime nowDate =
        convertMillisecondsSinceEpochToDateTime(currentTimeInSeconds());
    if (tasks.length == 1) {
      print('tasks length is 1');
      nearestTask = tasks[0];
    } else {
      List<int> startTimes = List();
      for (StartEndTask startTask in tasks) {
        startTimes.add(startTask.startTime);
      }
      int leastTime = startTimes.reduce(min);
      if (currentTimeInSeconds() >= leastTime) {
        print('current time is more than least time $leastTime');
        return null;
      }
      for (StartEndTask task in tasks) {
        if (task.startTime == leastTime) {
          nearestTask = task;
          break;
        }
      }
    }
    DateTime startDate =
        convertMillisecondsSinceEpochToDateTime(nearestTask.startTime);

    List<int> calculatedDate =
        calculateDurationFromStartAndEndDurationsinHoursAndMinutes(
            nowDate, startDate);
    int time;
    String timeFormat;

    if (calculatedDate[0] <= 0 && calculatedDate[1] <= 0) {
      print('this was called');
      return null;
    }

    print('hour ${calculatedDate[0]} minute ${calculatedDate[1]}');
    if (calculatedDate[0] == 0) {
      time = calculatedDate[1];
      timeFormat = 'minutes';
    } else {
      time = calculatedDate[0];
      calculatedDate[0] == 1 ? timeFormat = 'hour' : timeFormat = 'hours';
    }
    String resultText = 'in $time $timeFormat';
    result = UITask(0, nearestTask.taskName, '', Colors.white, resultText);
    return result;
  }

  static double calculateTimePercentFromTotalBalance(
      int hour, int defaultFormat) {
    double percent = hour / defaultFormat;
    print('hour is $hour and default format is $defaultFormat');
    print('percent is $percent ');
    if(hour/defaultFormat<0.0){
      return 1.0;
    }
    return hour / defaultFormat;
  }

  static int calculateTimeBalanceFromFormattedTime(
      String formattedTime, int defaultFormat) {
    int userFormat = 24;
    if (defaultFormat != null && defaultFormat != 0) userFormat = defaultFormat;
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      if(userFormat-hour<=0){
        print('user format - hour is ${userFormat-hour}');
        return 0;
      }
      return userFormat - hour;
    }
    return 0;
  }

  static Color getRandomColor() {
    Random random = new Random();
    int randomNumber = random.nextInt(3);
    List<Color> colors = [
      kMainBlueColor,
      kTasksDateContainerColor,
      kTasksDateIconColor2
    ];
    return colors[randomNumber];
  }

  static UITask formatDurationTaskToUIListComponenet(DurationTask task) {
    DateTime duration =
        convertMillisecondsSinceEpochToDateTime(task.durationTime);
    DateTime date = convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask = UITask(
        task.id,
        task.taskName,
        formatTimeToHHMM(duration.hour, duration.minute),
        getRandomColor(),
        Jiffy(date).fromNow());
    return uiTask;
  }

  static UITask formatStartEndTaskToUIListComponenet(StartEndTask task) {
    List<int> duration =
        calculateDurationFromStartAndEndDurationsinHoursAndMinutes(
            convertMillisecondsSinceEpochToDateTime(task.startTime),
            convertMillisecondsSinceEpochToDateTime(task.endTime));
    DateTime date = convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask = UITask(
        task.id,
        task.taskName,
        formatTimeToHHMM(duration[0], duration[1]),
        getRandomColor(),
        Jiffy(date).fromNow());
    return uiTask;
  }
}
