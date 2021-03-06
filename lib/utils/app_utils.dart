import 'dart:math';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/models/expandedStateModel.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

class AppUtils {
  static Future<TimeOfDay> showTimePickerDialog(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  static bool validateDuration(String inputDuration) {
    final hhMMFormatReg = RegExp(r'^(?:\d|[01]\d|2[0-3]):[0-5]\d$');
    return hhMMFormatReg.hasMatch(inputDuration);
  }

  static bool validateMinutes(String minutes) {
    final hhMMFormatReg = RegExp(r'^(?:([0-5]?[0-9]))$');
    return hhMMFormatReg.hasMatch(minutes);
  }

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static int dateTimeMillisecondsSinceEpochToSeconds(DateTime dt) {
    var ms = dt.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static String formatTaskLengthToHHMM(int hour, int minutes, int tasksLength) {
    return '$tasksLength X ${formatTimeToHHMM(hour, minutes)}';
  }

  static String formatMinutesToHHMMTime(String minutes) {
    if (minutes == null) return '';
    if (minutes.length > 2) return '';
    String minsResult;
    minutes.trim().length == 1
        ? minsResult = '0' + minutes.trim()
        : minsResult = minutes.trim();
    return '00:' + minsResult;
  }

  static TimeOfDay formatHHMMTimeToTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }

  static DateTime formatTimeOfDayToDateTime(TimeOfDay tod) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  }

  static TimeOfDay formatDateTimeToTimeOfDay(DateTime dt) {
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
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

  static String parseExpandedTasksToCommaSeparatedTasks(
      List<ExpandedStateModel> tasks) {
    if (tasks != null) {
      if (tasks.isEmpty) return '';
      String result = '';
      for (int i = 0; i < tasks.length; i++) {
        result = result + tasks[i].task.text.trim();
        if (i != tasks.length - 1) result = result + ',';
      }
      return result;
    }
    return '';
  }

  static List parseCommaSeparatedExpandedTasksToString(String tasks) {
    if (tasks != null) {
      if (tasks.isNotEmpty) {
        List split = tasks.split(',');
        return split;
      }
      return List();
    }
    return List();
  }

  static List<int> addTime(
      int currentHour, int hourToAdd, int currentMinute, int minuteToAdd) {
    int resultMinute;
    int resultHour;
    if (currentMinute + minuteToAdd <= 60) {
      if (currentMinute + minuteToAdd == 60) {
        resultHour = currentHour + hourToAdd + 1;
        resultMinute = 0;
      } else {
        resultMinute = currentMinute + minuteToAdd;
        resultHour = currentHour + hourToAdd;
      }
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

  static List<double> calculateTheDifferenceBetweenDatesInHoursAndMinutes(
      DateTime dateTime) {
    DateTime nowDate = DateTime.now();
    Duration difference;
    if (dateTime.isAfter(nowDate))
      difference = dateTime.difference(nowDate);
    else
      difference = nowDate.difference(dateTime);
    int hoursToMilliseconds = difference.inHours * 3600000;
    double totalMinutes =
        (difference.inMilliseconds - hoursToMilliseconds).abs() / 60000;
    return [difference.inHours.ceilToDouble(), totalMinutes.ceilToDouble()];
  }

  static List<double> calculateDifferenceBetweenTwoDates(
      DateTime dateTime1, DateTime dateTime2) {
    Duration difference;
    difference = dateTime2.difference(dateTime1);
    int hoursToMilliseconds = (difference.inHours * 3600000);
    double totalMinutes =
        (difference.inMilliseconds - hoursToMilliseconds).abs() / 60000;
    return [
      difference.inHours.ceilToDouble().abs(),
      totalMinutes.ceilToDouble().abs(),
      difference.isNegative ? 1 : 0
    ];
  }

  static List<int> calculateDuration(
      int startHour, int endHour, int startMinute, int endMinute) {
    int resultMinute = endMinute - startMinute;
    if (endHour == 0) endHour = 24;
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
    return today.difference(aDate).inDays == 1 ||
        today.difference(aDate).inDays == 0;
  }

  static updateTimeBalance(
      SharedPerferencesUtils sharedPerferencesUtils) async {
    int timeSaved = sharedPerferencesUtils
        .getIntFromSharedPreferences(kTimeSelectedSettingsKey);
    if (timeSaved != 0) {
      DateTime timeSavedDateTime =
          DateTime.fromMillisecondsSinceEpoch(timeSaved);
      List<double> result =
          AppUtils.calculateTheDifferenceBetweenDatesInHoursAndMinutes(
              timeSavedDateTime);
      if (timeSavedDateTime.isAfter(DateTime.now())) {
        //4:00 and now is 4:01
        sharedPerferencesUtils.saveIntToSharedPreferences(
            kTotalBalanceHoursKey, result[0].toInt());
        sharedPerferencesUtils.saveIntToSharedPreferences(
            kTotalBalanceMinutesKey, result[1].toInt());
      } else {
        sharedPerferencesUtils.saveIntToSharedPreferences(
            kTimeSelectedSettingsKey, 0);
        sharedPerferencesUtils.saveIntToSharedPreferences(
            kTotalBalanceHoursKey, 0);
        sharedPerferencesUtils.saveIntToSharedPreferences(
            kTotalBalanceMinutesKey, 0);
        print("ALL SET TO 0");
      }
    }
  }

  static bool checkTheTasksDates(
      DateTime startDate, DateTime endDate, DateTime creationDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return startDate.day == today.day ||
        endDate.day == today.day ||
        creationDate.day == today.day;
  }

  static bool checkIfTimePickerDateIsToday(TimeOfDay date) {
    final DateTime now = DateTime.now();
    if (now.hour >= 12) {
      if (date.hour <= 12)
        return false;
      else {
        if (date.hour >= now.hour) return true;
        return false;
      }
    }
    return true;
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

  static String formatTimeToHHMM(int hour, int minute,
      {bool isNegative = false}) {
    String hourMinute = hour >= 1 || hour < 0 ? 'h' : 'm';
    String formattedHour = formatTimeToTwoDecimals(hour);
    String formattedMinute = formatTimeToTwoDecimals(minute);
    return '${isNegative ? '-' : ''}$formattedHour:$formattedMinute $hourMinute';
  }

  static String formatTimeToHHMM2(int hour, int minute) {
    String formattedHour = formatTimeToTwoDecimals(hour);
    String formattedMinute = formatTimeToTwoDecimals(minute);
    return '$formattedHour:$formattedMinute';
  }

  static String formatNowDateToMMDDYYYY() {
    DateTime now = DateTime.now();
    var formatter = new DateFormat('MM:dd:yyyy');
    String formatted = formatter.format(now);
    return formatted;
  }

  static String formatTimeToAndFrom(DateTime start, DateTime end) {
    return 'From ${formatTimeToTwoDecimals(start.hour)}:${formatTimeToTwoDecimals(start.minute)} to ${formatTimeToTwoDecimals(end.hour)}:${formatTimeToTwoDecimals(end.minute)}';
  }

  static double calculateTimePercentFromFormattedTime(
      String formattedTime, int defaultFormat) {
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      if (hour > 24) {
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
    result = UITask(0, nearestTask.taskName, '', Colors.white, resultText,
        TaskTypes.StartEndTasks, null, null, null);
    return result;
  }

  static double calculateTimePercentFromTotalBalance(
      int hour, int defaultFormat) {
    if (hour == 0) return 0;
    if (hour / defaultFormat < 0.0) {
      return 1.0;
    }
    return hour / defaultFormat;
  }

  static List<int> calculateTimeBalanceFromFormattedTime(
      String formattedTime, int defaultHourFormat, int defaultMinuteFormat) {
    int hourFormat = 24;
    int minuteFormat = 0;
    if (defaultHourFormat != null
        //&& defaultHourFormat != 0
        ) {
      hourFormat = defaultHourFormat;
      minuteFormat = defaultMinuteFormat;
    }
    List<String> time = formattedTime.split(':');
    if (time.length >= 1) {
      int hour = int.parse(time[0]);
      int minute = int.parse(time[1].substring(0, 2));
      DateTime now = DateTime.now();
      DateTime start = DateTime(now.year, now.month, now.day, hour, minute);
      DateTime end =
          DateTime(now.year, now.month, now.day, hourFormat, minuteFormat);
      List<double> diff = calculateDifferenceBetweenTwoDates(start, end);
      return [diff[0].toInt(), diff[1].toInt(), diff[2].toInt()];
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

  static UITask formatDurationTaskToUIListComponent(DurationTask task) {
    DateTime duration =
        convertMillisecondsSinceEpochToDateTime(task.durationTime);
    DateTime date = convertMillisecondsSinceEpochToDateTime(task.date);
    String durationInHHMM = formatTimeToHHMM(duration.hour, duration.minute);
    List expandedTasks =
        parseCommaSeparatedExpandedTasksToString(task.expandedTasks);
    if (expandedTasks.isNotEmpty) {
      durationInHHMM = formatTaskLengthToHHMM(
          duration.hour, duration.minute, expandedTasks.length);
    }
    UITask uiTask = UITask(
        task.id,
        task.taskName,
        durationInHHMM,
        getRandomColor(),
        Jiffy(date).fromNow(),
        TaskTypes.DurationTasks,
        null,
        null,
        expandedTasks);
    return uiTask;
  }

  static UITask formatStartEndTaskToUIListComponent(StartEndTask task) {
    DateTime startTime =
        AppUtils.convertMillisecondsSinceEpochToDateTime(task.startTime);
    DateTime endTime =
        AppUtils.convertMillisecondsSinceEpochToDateTime(task.endTime);
    List<double> difference =
        calculateDifferenceBetweenTwoDates(startTime, endTime);
    List<int> duration = [difference[0].toInt(), difference[1].toInt()];
    DateTime date = convertMillisecondsSinceEpochToDateTime(task.date);
    UITask uiTask = UITask(
        task.id,
        task.taskName,
        formatTimeToHHMM(duration[0], duration[1]),
        getRandomColor(),
        Jiffy(date).fromNow(),
        TaskTypes.StartEndTasks,
        startTime,
        endTime,
        null);
    return uiTask;
  }

  static String constructWhatsAppShareLink(String tasks) {
    Uri actualText = Uri.parse(tasks);
    String shareLink = 'whatsapp://send?text=$actualText';
    return shareLink;
  }
}
