import 'dart:async';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/tab_model.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/services/local_notifications_helper.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

class HomeScreenProvider with ChangeNotifier {
  int currentBottomNavBarIndex = 0;
  String _firstNavBarItemName;
  TabModel _currentTabModel;
  String _totalTime;
  List _durationTotalTime;
  List _startEndDurationTotalTime;
  List<UITask> _recentTasks;
  UITask _upcomingTask;
  TaskTypes _selectedTask;
  bool _noTodayTasks;
  String _selectedTaskType;
  DBHelper _db;
  Calendar _defaultUserCalendar;
  DeviceCalendarPlugin _deviceCalendarPlugin;
  Function _onCalendarTasksFound;
  Function _onSelectDeviceCalendar;
  Function _onTasksNotFound;
  String _currentTotalBalance;
  Timer _refreshTimer;

  HomeScreenProvider(
      this._db,
      this._selectedTask,
      this._deviceCalendarPlugin,
      Function onCalendarTasksFound,
      Function onSelectDeviceCalendar,
      Function onTasksNotFound) {
    _setTaskType();
    _onCalendarTasksFound = onCalendarTasksFound;
    _durationTotalTime = [0, 0];
    _onSelectDeviceCalendar = onSelectDeviceCalendar;
    _onTasksNotFound = onTasksNotFound;
    _setTasksData(TaskAction.TotalTime);
    _recentTasks = [];
//    if (_selectedTask == TaskTypes.StartEndTasks)
//      getDefaultCalendar(repeat: true);
    _refreshTimer = Timer.periodic(Duration(seconds: 50), (Timer t) {
      refreshMainScreen();
    });
  }

  TabModel get currentTabModel => _currentTabModel;

  String get firstNavBarItemName => _firstNavBarItemName;

  TaskTypes get selectedTask => _selectedTask;

  String get selectedTaskTypes => _selectedTaskType;

  String get totalTime => _totalTime;

  List get durationTotalTime => _durationTotalTime;

  List get startEndTotalTime => _startEndDurationTotalTime;

  bool get noTodayTasks => _noTodayTasks;

  UITask get upcomingTask => _upcomingTask;

  String get selectedTaskType => _selectedTaskType;

  List<UITask> get recentTasks => _recentTasks;

  void onBottomNavBarTap(int index, Function dialogCallback) async {
    currentBottomNavBarIndex = index;
    switch (index) {
      case 0:
        displayResetDialog(dialogCallback);
        if (_firstNavBarItemName == 'Duration Tasks')
          _selectedTask = TaskTypes.StartEndTasks;
        else
          _selectedTask = TaskTypes.DurationTasks;
        _setTaskType();
        _setTasksData(TaskAction.TotalTime);
        break;
      case 1:
        _setTasksData(TaskAction.TotalTime);
        break;
      case 2:
        _setTasksData(TaskAction.TotalBalance);
        break;
    }
    notifyListeners();
  }

  void refreshMainScreen() {
    int index = 0;
    currentBottomNavBarIndex == 0
        ? index = 1
        : index = currentBottomNavBarIndex;
    onBottomNavBarTap(index, () {});
  }

  void refreshAndShowCalendarDialog() {
    refreshMainScreen();
    getDefaultCalendar(repeat: true);
  }

  onTaskAddButtonTap(Function navigateToDurationCallback,
      Function navigateToStartEndCallback) {
    if (_selectedTask != null) {
      switch (_selectedTask) {
        case TaskTypes.DurationTasks:
          navigateToDurationCallback();
          break;
        case TaskTypes.StartEndTasks:
          navigateToStartEndCallback();
          break;
      }
    }
  }

  void _setTasksData(TaskAction action) async {
    List<Task> tasks;
    switch (_selectedTask) {
      case TaskTypes.DurationTasks:
        tasks = await readMainScreenElementsFromDB(TaskTypes.DurationTasks);
        break;
      case TaskTypes.StartEndTasks:
        tasks = await readMainScreenElementsFromDB(TaskTypes.StartEndTasks);
        break;
    }
    List<Task> todayDurationTasks = _getTodayTasks(tasks);
    if (todayDurationTasks.isEmpty) {
      _noTodayTasks = true;
      _startEndDurationTotalTime = [0, 0];
      _durationTotalTime = [0, 0];
    } else {
      _noTodayTasks = false;
      if (_selectedTask == TaskTypes.StartEndTasks) {
        List<StartEndTask> todayStartEndTasks =
            AppUtils.getTheTodayUpcomingTasks(todayDurationTasks.cast());
        _upcomingTask = AppUtils.getUpcomingTask(todayStartEndTasks);
        notifyListeners();
      }
      _getRecentTasksFromDB(todayDurationTasks, _selectedTask);
      _totalTime = calculateTotalTimeInHHMMFormat(todayDurationTasks);
      switch (action) {
        case TaskAction.TotalTime:
          _setTotalTimeForTaskType(_totalTime,
              AppUtils.calculateTimePercentFromFormattedTime(_totalTime, 24));
          break;
        case TaskAction.TotalBalance:
          SharedPerferencesUtils sharedPerferencesUtils =
              SharedPerferencesUtils(await SharedPreferences.getInstance());
          int timeSaved = sharedPerferencesUtils
              .getIntFromSharedPreferences(kTimeSelectedSettingsKey);
          List<int> totalBalance;
          int userTotalHourBalance;
          int userTotalMinutesBalance;
          if (timeSaved != 0)
            AppUtils.updateTimeBalance(sharedPerferencesUtils);
          userTotalHourBalance = sharedPerferencesUtils
              .getIntFromSharedPreferences(kTotalBalanceHoursKey);
          userTotalMinutesBalance = sharedPerferencesUtils
              .getIntFromSharedPreferences(kTotalBalanceMinutesKey);
          userTotalHourBalance == 0 && userTotalMinutesBalance == 0
              ? totalBalance = [0, 0, 0]
              : totalBalance = AppUtils.calculateTimeBalanceFromFormattedTime(
                  _totalTime, userTotalHourBalance, userTotalMinutesBalance);
          _currentTotalBalance = AppUtils.formatTimeToHHMM(
              totalBalance[0], totalBalance[1],
              isNegative: totalBalance[2] == 1 ? true : false);
          _setTotalBalanceForTaskType(
              _currentTotalBalance,
              AppUtils.calculateTimePercentFromTotalBalance(
                  totalBalance[0], userTotalHourBalance));
          break;
      }
    }
    notifyListeners();
  }

  void onTaskDelete(int id) async {
    switch (_selectedTask) {
      case TaskTypes.DurationTasks:
        await _db.deleteDurationTask(id);
        refreshMainScreen();
        break;
      case TaskTypes.StartEndTasks:
        await _db.deleteStartEndTask(id);
        refreshMainScreen();
        break;
    }
    print('start end total duration is ${_startEndDurationTotalTime[0]}');
  }

  void deleteAllTodaysTasksForTaskType() async {
    if (_recentTasks != null) {
      if (_recentTasks.isNotEmpty) {
        switch (_selectedTask) {
          case TaskTypes.DurationTasks:
            _durationTotalTime = [0, 0];
            break;
          case TaskTypes.StartEndTasks:
            _startEndDurationTotalTime = [0, 0];
            break;
        }
        for (UITask task in _recentTasks) {
          task.taskType == TaskTypes.DurationTasks
              ? await _db.deleteDurationTask(task.id)
              : await _db.deleteStartEndTask(task.id);
        }
      }
      GetIt.instance<LocalNotificationsHelper>().cancelAllNotifications();
      refreshMainScreen();
    }
  }

  void displayResetDialog(Function dialogCallback) {
    if (!noTodayTasks) {
      dialogCallback();
    }
  }

  void _getRecentTasksFromDB(List<Task> tasks, TaskTypes taskTypes) {
    if (tasks.isNotEmpty) {
      _recentTasks = List();
      switch (taskTypes) {
        case TaskTypes.DurationTasks:
          List<DurationTask> durationTasks = tasks.cast();
          for (DurationTask task in durationTasks) {
            _recentTasks
                .add(AppUtils.formatDurationTaskToUIListComponent(task));
          }
          break;
        case TaskTypes.StartEndTasks:
          List<StartEndTask> startEndTasks = tasks.cast();
          for (StartEndTask task in startEndTasks) {
            _recentTasks
                .add(AppUtils.formatStartEndTaskToUIListComponent(task));
          }
          break;
      }
    }
  }

  List<Task> _getTodayTasks(List<Task> tasksList) {
    List<Task> result = [];
    if (tasksList.length > 0) {
      for (Task task in tasksList) {
        bool isToday;
        if (task is StartEndTask) {
          isToday = AppUtils.checkTheTasksDates(
              AppUtils.convertMillisecondsSinceEpochToDateTime(task.startTime),
              AppUtils.convertMillisecondsSinceEpochToDateTime(task.endTime),
              AppUtils.convertMillisecondsSinceEpochToDateTime(task.date));
        } else
          isToday = AppUtils.checkIfDateIsToday(
              AppUtils.convertMillisecondsSinceEpochToDateTime(task.date));
        if (isToday) {
          result.add(task);
        }
      }
    }
    return result;
  }

  String calculateTotalTimeInHHMMFormat(List tasksList) {
    int hour = 0;
    int minute = 0;
    if (tasksList.length > 0) {
      switch (_selectedTask) {
        case TaskTypes.DurationTasks:
          for (DurationTask task in tasksList) {
            DateTime taskDuration;
            DateTime fixedDuration;
            List expandedList =
                AppUtils.parseCommaSeparatedExpandedTasksToString(
                    task.expandedTasks);
            if (expandedList.length > 0) {
              taskDuration = AppUtils.convertMillisecondsSinceEpochToDateTime(
                  task.durationTime);
              fixedDuration = taskDuration;
              for (int i = 0; i < expandedList.length - 1; i++) {
                taskDuration = taskDuration.add(Duration(
                    hours: fixedDuration.hour, minutes: fixedDuration.minute));
              }
            } else
              taskDuration = AppUtils.convertMillisecondsSinceEpochToDateTime(
                  task.durationTime);
            List<int> time = AppUtils.addTime(
                taskDuration.hour, hour, taskDuration.minute, minute);
            hour = time[0];
            minute = time[1];
            _durationTotalTime = time;
          }
          return AppUtils.formatTimeToHHMM(hour, minute);
          break;
        case TaskTypes.StartEndTasks:
          for (StartEndTask task in tasksList) {
            List<int> time;
            List<int> duration;
            //if there's an overlapping task, no need for calculation, it's already provided in the db.
            if (task.overlapPeriod.toString().trim().isNotEmpty) {
              List split = task.overlapPeriod.toString().split(',');
              time = [int.parse(split[0]), int.parse(split[1])];
              duration = time;
            } else {
              DateTime taskStartTime =
                  AppUtils.convertMillisecondsSinceEpochToDateTime(
                      task.startTime);
              DateTime taskEndTime =
                  AppUtils.convertMillisecondsSinceEpochToDateTime(
                      task.endTime);
              List<double> durationBetweenDates =
                  AppUtils.calculateDifferenceBetweenTwoDates(
                      taskStartTime, taskEndTime);
              duration = [
                durationBetweenDates[0].toInt(),
                durationBetweenDates[1].toInt()
              ];
            }
            time = AppUtils.addTime(duration[0], hour, duration[1], minute);
            hour = time[0];
            minute = time[1];
            _startEndDurationTotalTime = time;
          }
          return AppUtils.formatTimeToHHMM(hour, minute);
          break;
      }
      print("DURATION TOTAL TIME IS ${_startEndDurationTotalTime[0]}");
    }
    return '00:00 h';
  }

  //Retrieve user's calendars from mobile device
  //Request permissions first if they haven't been granted
  getDefaultCalendar({bool repeat}) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final data = calendarsResult.data;
      SharedPerferencesUtils sharedPrefsUtils =
          SharedPerferencesUtils(await SharedPreferences.getInstance());
      String userSavedCalendar =
          sharedPrefsUtils.getStringFromSharedPreferences(kSavedCalendarKey);
      if (userSavedCalendar == null) {
        for (Calendar calendar in data) {
          if (!calendar.isReadOnly) {
            _defaultUserCalendar = calendar;
            break;
          }
        }
      } else {
        for (Calendar calendar in data) {
          if (calendar.name == userSavedCalendar) {
            _defaultUserCalendar = calendar;
            break;
          }
        }
      }
      _popCalendarTasksDialog(repeat);
    } catch (e) {}
  }

  _popCalendarTasksDialog(bool repeat) async {
    if (_defaultUserCalendar != null && _deviceCalendarPlugin != null) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime tomorrow = today.add(Duration(days: 1));
      final calendarEvents = await _deviceCalendarPlugin.retrieveEvents(
          _defaultUserCalendar.id,
          RetrieveEventsParams(startDate: today, endDate: tomorrow));
      if (calendarEvents.data != null) {
        if (calendarEvents.data.length > 0) {
          List events = _filterAllDayEvents(
              await _filterCalendarExistingTasks(calendarEvents.data));
          if (events.length > 0) {
            final result = await _onCalendarTasksFound(events);
            if (result) refreshAndShowCalendarDialog();
          } else if (!repeat) _onTasksNotFound();
        } else if (!repeat) _onTasksNotFound();
      }
    }
  }

  Future<List> _filterCalendarExistingTasks(List<Event> events) async {
    final dbTasks = _getTodayTasks(
        await readMainScreenElementsFromDB(TaskTypes.StartEndTasks));
    if (dbTasks.length == 0) return events;
    List<StartEndTask> tasksResult = List();
    List<Event> eventsResult = List();
    for (StartEndTask task in dbTasks) {
      if (task.isCalendarTask == 1)
        tasksResult.add(task); //existing calendar task
    }
    bool isFound = true;
    //Compare existing calendar events
    if (tasksResult.length > 0) {
      for (int i = 0; i < events.length; i++) {
        for (int j = 0; j < tasksResult.length; j++) {
          isFound = false;
          if (events[i].title == tasksResult[j].taskName) {
            isFound = true;
            break;
          }
        }
        if (!isFound) {
          eventsResult.add(events[i]);
          isFound = true;
        }
      }
    } else
      eventsResult = events;
    return eventsResult;
  }

  List _filterAllDayEvents(List<Event> events) {
    List<Event> result = List();
    for (Event e in events) {
      if (!e.allDay) result.add(e);
    }
    return result;
  }

  Future<List> readMainScreenElementsFromDB(TaskTypes taskTypes) async {
    List tasks;
    if (_db != null) {
      switch (taskTypes) {
        case TaskTypes.DurationTasks:
          tasks = await _db.getDurationTasks();
          break;
        case TaskTypes.StartEndTasks:
          tasks = await _db.getStartEndTasks();
          break;
      }
    }
    return tasks;
  }

  void _setTotalTimeForTaskType(String totalTime, double percent) {
    _currentTabModel = TabModel(AppUtils.formatNowDateToMMDDYYYY(),
        kYourTotalTimeText, totalTime, percent, _selectedTask);
  }

  void _setTotalBalanceForTaskType(String totalBalance, double percent) {
    _currentTabModel = TabModel(AppUtils.formatNowDateToMMDDYYYY(),
        kYourTotalBalanceText, totalBalance, percent, _selectedTask);
  }

  void _setTaskType() {
    if (_selectedTask != null) {
      switch (_selectedTask) {
        case TaskTypes.DurationTasks:
          _firstNavBarItemName = 'Duration Tasks';
          _selectedTaskType = "Duration";
          break;
        case TaskTypes.StartEndTasks:
          _firstNavBarItemName = 'Start/End Tasks';
          _selectedTaskType = 'Start/End';
          break;
      }
    }
  }

  String getShareableWhatsAppList() {
    String result = '';
    switch (_selectedTask) {
      case TaskTypes.StartEndTasks:
        for (UITask task in _recentTasks) {
          result = result +
              '\n' +
              'Task: ${task.taskName}, From: ${AppUtils.formatTimeToHHMM2(task.startTime.hour, task.startTime.minute)} To: ${AppUtils.formatTimeToHHMM2(task.endTime.hour, task.endTime.minute)}';
        }
        break;

      case TaskTypes.DurationTasks:
        for (UITask task in _recentTasks) {
          result = result +
              '\n' +
              'Task: ${task.taskName}, Duration: ${task.duration}';
        }
        break;
    }
    return result +
        '\n' +
        '=============================' +
        '\nTotal Time: $totalTime' +
        '\nTime Remaining: $_currentTotalBalance';
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
