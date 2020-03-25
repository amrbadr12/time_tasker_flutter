import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/tab_model.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

class HomeScreenProvider with ChangeNotifier {
  int currentBottomNavBarIndex = 0;
  String _firstNavBarItemName;
  TabModel _currentTabModel;
  String _totalTime;
  String _totalBalance;
  List<UITask> _recentTasks;
  UITask _upcomingTask;
  TaskTypes _selectedTask;
  bool _noTodayTasks;
  String _selectedTaskType;
  DBHelper _db;
  Calendar _defaultUserCalendar;
  DeviceCalendarPlugin _deviceCalendarPlugin;

  HomeScreenProvider(this._db, this._selectedTask, this._deviceCalendarPlugin,
      Function onCalendarTasksFound) {
    _setTaskType();
    _setTasksData(TaskAction.TotalTime);
    _recentTasks = [];
    _getDefaultCalendar(onCalendarTasksFound);
  }

  TabModel get currentTabModel => _currentTabModel;

  String get firstNavBarItemName => _firstNavBarItemName;

  String get selectedTaskTypes => _selectedTaskType;

  String get totalTime => _totalTime;

  bool get noTodayTasks => _noTodayTasks;

  String get totalBalance => _totalBalance;

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
    } else {
      _noTodayTasks = false;
      if (_selectedTask == TaskTypes.StartEndTasks) {
        List<StartEndTask> todayStartEndTasks =
            AppUtils.getTheTodayUpcomingTasks(todayDurationTasks.cast());
        //_upcomingTask =null;
        _upcomingTask = AppUtils.getUpcomingTask(todayStartEndTasks);
        notifyListeners();
      }
      //_getRecentTasksFromDB(tasks, _selectedTask);
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
          int userTotalHourBalance = sharedPerferencesUtils
              .getIntFromSharedPreferences(kTotalBalanceHoursKey);
          int userTotalMinutesBalance = sharedPerferencesUtils
              .getIntFromSharedPreferences(kTotalBalancMinutesKey);
          List<int> totalBalance =
              AppUtils.calculateTimeBalanceFromFormattedTime(
                  _totalTime, userTotalHourBalance, userTotalMinutesBalance);
          _setTotalBalanceForTaskType(
              AppUtils.formatTimeToHHMM(totalBalance[0], totalBalance[1]),
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
        break;
      case TaskTypes.StartEndTasks:
        await _db.deleteStartEndTask(id);
        break;
    }
    refreshMainScreen();
  }

  void deleteAllTodaysTasksForTaskType() async {
    if (_recentTasks != null) {
      if (_recentTasks.isNotEmpty) {
        for (UITask task in _recentTasks) {
          task.taskType == TaskTypes.DurationTasks
              ? await _db.deleteDurationTask(task.id)
              : await _db.deleteStartEndTask(task.id);
        }
      }
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
                .add(AppUtils.formatDurationTaskToUIListComponenet(task));
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
        bool isToday = AppUtils.checkIfDateIsToday(
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
            List expandedList =
                AppUtils.parseCommaSeparatedExpandedTasksToString(
                    task.expandedTasks);
            if (expandedList.length > 0) {
              taskDuration = AppUtils.convertMillisecondsSinceEpochToDateTime(
                  task.durationTime);
              for (int i = 0; i < expandedList.length - 1; i++) {
                taskDuration = taskDuration.add(Duration(
                    hours: taskDuration.hour, minutes: taskDuration.minute));
              }
            } else
              taskDuration = AppUtils.convertMillisecondsSinceEpochToDateTime(
                  task.durationTime);
            List<int> time = AppUtils.addTime(
                taskDuration.hour, hour, taskDuration.minute, minute);
            hour = time[0];
            minute = time[1];
          }
          return AppUtils.formatTimeToHHMM(hour, minute);
          break;
        case TaskTypes.StartEndTasks:
          for (StartEndTask task in tasksList) {
            DateTime taskStartTime =
                AppUtils.convertMillisecondsSinceEpochToDateTime(
                    task.startTime);
            DateTime taskEndTime =
                AppUtils.convertMillisecondsSinceEpochToDateTime(task.endTime);
            List<int> duration = AppUtils.calculateDuration(taskStartTime.hour,
                taskEndTime.hour, taskStartTime.minute, taskEndTime.minute);
            List<int> time =
                AppUtils.addTime(duration[0], hour, duration[1], minute);
            hour = time[0];
            minute = time[1];
          }
          return AppUtils.formatTimeToHHMM(hour, minute);
          break;
      }
    }
    return '00:00 h';
  }

  //Retrieve user's calendars from mobile device
  //Request permissions first if they haven't been granted
  _getDefaultCalendar(Function onCalendarTasksFound) async {
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
      for (Calendar calendar in data) {
        if (!calendar.isReadOnly) {
          _defaultUserCalendar = calendar;
          break;
        }
      }
      _popCalendarTasksDialog(onCalendarTasksFound);
    } catch (e) {}
  }

  _popCalendarTasksDialog(Function onCalendarTasksFound) async {
    if (_defaultUserCalendar != null && _deviceCalendarPlugin != null) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime tomorrow = today.add(Duration(days: 1));
      final calendarEvents = await _deviceCalendarPlugin.retrieveEvents(
          _defaultUserCalendar.id,
          RetrieveEventsParams(startDate: today, endDate: tomorrow));
      if (calendarEvents.data != null) {
        if (calendarEvents.data.length > 0) {
          List events = await _filterCalendarExistingTasks(calendarEvents.data);
          if (events.length > 0) onCalendarTasksFound(events);
        }
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
    return eventsResult;
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
}
