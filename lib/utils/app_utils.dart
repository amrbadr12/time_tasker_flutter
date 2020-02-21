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

static List<int> minusTime(
      int endHour, int startHour, int endMinute, int startMinute) {
    int resultMinute;
    int resultHour;
    if (endMinute - startMinute >= 0) {
      resultMinute = endMinute - startMinute;
      resultHour = endHour - startHour;
    } else {
      resultHour = endHour - startHour - 1;
      resultMinute = (endMinute - startMinute) + 60;
    }
    return [resultHour, resultMinute];
  }
  

  static List<int> calculateDuration(
      int startHour, int endHour, int startMinute, int endMinute) {
    int resultMinute = endMinute - startMinute;
    int resultHour = endHour - startHour;
    if (endMinute - startMinute < 0) {
      resultMinute = (60 - startMinute) + endMinute;
      resultHour--;
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
    String hourMinute = hour >= 1 ? 'h' : 'm';
    String formattedHour = formatTimeToTwoDecimals(hour);
    String formattedMinute = formatTimeToTwoDecimals(minute);
    return '$formattedHour:$formattedMinute $hourMinute';
  }

  static String formatNowDateToMMDDYYYY() {
    DateTime now = DateTime.now();
    var formatter = new DateFormat('MM:dd:yyyy');
    String formatted = formatter.format(now);
    return formatted;
  }

  static double calculateTimePercentFromFormattedTime(
      String formattedTime, int defaultFormat) {
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      print('hour is $hour');
      if(hour>24){
        return 0.0;
      }
      return hour / defaultFormat.round();
    }
    return 0.0;
  }

  static List<StartEndTask> getTheTodayUpcomingTasks(List<StartEndTask> tasks) {
    List<StartEndTask> upcomingTasks = List();
    for (StartEndTask task in tasks) {
      if (currentTimeInSeconds() < task.startTime) {
        print('task added ${task.taskName}');
        upcomingTasks.add(task);
      }
    }
    return upcomingTasks;
  }

  static UITask getUpcomingTask(List<StartEndTask> tasks) {
    if (tasks == null) return null;
    if (tasks.length == 0) return null;
    UITask result;
    StartEndTask nearestTask;
    DateTime nowDate =
        convertMillisecondsSinceEpochToDateTime(currentTimeInSeconds());
    if (tasks.length == 1) {
      nearestTask = tasks[0];
    } else {
      List<int> startTimes = List();
      for (StartEndTask startTask in tasks) {
        startTimes.add(startTask.startTime);
      }
      int leastTime = startTimes.reduce(min);
      if (currentTimeInSeconds() >= leastTime) {
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

    List<int> calculatedDate = calculateDuration(
        nowDate.hour, startDate.hour, nowDate.minute, startDate.minute);
    int time;
    String timeFormat;

    if (calculatedDate[0] <= 0 && calculatedDate[1] <= 0) return null;

    if (calculatedDate[0] == 0) {
      time = calculatedDate[1];
      timeFormat = 'minutes';
    } else {
      time = calculatedDate[0];
      calculatedDate[0] == 1 ? timeFormat = 'hour' : timeFormat = 'hours';
    }
    String resultText = 'in $time $timeFormat';
    result = UITask(0, nearestTask.taskName, '', Colors.white, resultText,TaskTypes.StartEndTasks);
    return result;
  }

  static double calculateTimePercentFromTotalBalance(
      int hour, int defaultFormat) {
    if (hour / defaultFormat < 0.0) {
      return 1.0;
    }
    return hour / defaultFormat;
  }

  static List<int> calculateTimeBalanceFromFormattedTime(
      String formattedTime, int defaultHourFormat,int defaultMinuteFormat) {
    int hourFormat = 24;
    int minuteFormat=0;
    if (defaultHourFormat != null && defaultHourFormat != 0) 
    {hourFormat = defaultHourFormat;
    minuteFormat=defaultMinuteFormat;
    }
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      int minute=int.parse(time[1].substring(0,2));
      if (hourFormat - hour <= 0) return [0,0];
      return minusTime(hourFormat, hour, minuteFormat, minute);
    }
    return [];
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
        Jiffy(date).fromNow(),
        TaskTypes.DurationTasks);
    return uiTask;
  }

  static UITask formatStartEndTaskToUIListComponenet(StartEndTask task) {
    DateTime startTime =
        AppUtils.convertMillisecondsSinceEpochToDateTime(task.startTime);
    DateTime endTime =
        AppUtils.convertMillisecondsSinceEpochToDateTime(task.endTime);
    List<int> duration = calculateDuration(
        startTime.hour, endTime.hour, startTime.minute, endTime.minute);
    DateTime date = convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask = UITask(
        task.id,
        task.taskName,
        formatTimeToHHMM(duration[0], duration[1]),
        getRandomColor(),
        Jiffy(date).fromNow(),
        TaskTypes.StartEndTasks);
    return uiTask;
  }
}
