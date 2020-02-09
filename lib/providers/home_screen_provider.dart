import 'package:flutter/foundation.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/tab_model.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';

class HomeScreenProvider with ChangeNotifier {
  int currentBottomNavBarIndex = 0;
  String _firstNavBarItemName = 'Duration Tasks';
  TabModel _currentTabModel;
  String _totalTime;
  String _totalBalance;
  List<UITask> _recentTasks;
  TaskTypes _selectedTask = TaskTypes.DurationTasks;
  bool _noTodayTasks;
  String _selectedTaskType = "Duration";
  DBHelper _db;

  HomeScreenProvider(this._db) {
    _setTasksData(TaskAction.TotalTime);
    _recentTasks=[];
  }

  TabModel get currentTabModel => _currentTabModel;
  String get firstNavBarItemName => _firstNavBarItemName;
  String get totalTime => _totalTime;
  bool get noTodayTasks => _noTodayTasks;
  String get totalBalance => _totalBalance;
  String get selectedTaskType => _selectedTaskType;
  List<UITask> get recentTasks => _recentTasks;

  void onBottomNavBarTap(int index) {
    currentBottomNavBarIndex = index;
    switch (index) {
      case 0:
        if (_firstNavBarItemName == 'Duration Tasks') {
          _firstNavBarItemName = 'Start/End Tasks';
          _selectedTask = TaskTypes.StartEndTasks;
          _selectedTaskType = 'Start/End';
        } else {
          _firstNavBarItemName = 'Duration Tasks';
          _selectedTask = TaskTypes.DurationTasks;
          _selectedTaskType = 'Duration';
        }
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
    onBottomNavBarTap(currentBottomNavBarIndex);
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
      _getRecentTasksFromDB(tasks,_selectedTask);
      _totalTime = calculateTotalTimeinHHMMFormat(todayDurationTasks);

      switch (action) {
        case TaskAction.TotalTime:
          _setTotalTimeForTaskType(_totalTime,
              AppUtils.calculateTimePercentFromFormattedTime(_totalTime, 24));
          break;
        case TaskAction.TotalBalance:
          int totalBalance =
              AppUtils.calculateTimeBalanceFromFormattedTime(_totalTime, 24);
          _setTotalBalanceForTaskType(
              AppUtils.formatTimeToHHMM(
                  AppUtils.calculateTimeBalanceFromFormattedTime(
                      _totalTime, 24),
                  0),
              AppUtils.calculateTimePercentFromTotalBalance(totalBalance, 24));
          break;
      }
    }
    notifyListeners();
  }

  void onTaskDelete(int id) async{
    switch(_selectedTask){
      case TaskTypes.DurationTasks:
         await _db.deleteDurationTask(id);
        break;
      case TaskTypes.StartEndTasks:
        await _db.deleteStartEndTask(id);
        break;
    }
    refreshMainScreen();
  }

  void _getRecentTasksFromDB(List<Task> tasks, TaskTypes taskTypes) {
    if(tasks.isNotEmpty){
    _recentTasks=List();
    switch (taskTypes) {
      case TaskTypes.DurationTasks:
        List<DurationTask> durationTasks = tasks;
        if (tasks.length >= 3) {
          for (int i = 0; i < 3; i++) {
            _recentTasks.add(AppUtils.formatDurationTaskToUIListComponenet(durationTasks[i]));
          }
        } else {
          for (DurationTask task in tasks) {
            _recentTasks.add(AppUtils.formatDurationTaskToUIListComponenet(task));
          }
        }
        break;
      case TaskTypes.StartEndTasks:
        List<StartEndTask> startEndTasks = tasks;
        if (tasks.length >= 3) {
          for (int i = 0; i < 3; i++) {
            _recentTasks.add(AppUtils.formatStartEndTaskToUIListComponenet(startEndTasks[i]));
          }
        } else {
          for (StartEndTask task in startEndTasks) {
            _recentTasks.add(AppUtils.formatStartEndTaskToUIListComponenet(task));
          }
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

  String calculateTotalTimeinHHMMFormat(List tasksList) {
    int hour = 0;
    int minute = 0;
    if (tasksList.length > 0) {
      switch (_selectedTask) {
        case TaskTypes.DurationTasks:
          for (DurationTask task in tasksList) {
            DateTime taskDuration =
                AppUtils.convertMillisecondsSinceEpochToDateTime(
                    task.durationTime);
            hour += taskDuration.hour;
            minute += taskDuration.minute;
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
            List<int> duration = AppUtils
                .calculateDurationFromStartAndEndDurationsinHoursAndMinutes(
                    taskStartTime, taskEndTime);
            hour += duration[0];
            minute += duration[1];
          }
          return AppUtils.formatTimeToHHMM(hour, minute);
          break;
      }
    }
    return '00:00 h';
  }

  Future<List> readMainScreenElementsFromDB(TaskTypes taskTypes) async {
    List tasks;
    if (_db != null) {
      switch (taskTypes) {
        case TaskTypes.DurationTasks:
          tasks = await _db.getDurationTasks();
          List<DurationTask> task = tasks;
          for (int i = 0; i < tasks.length; i++) {
            print(
                'duration tasks $i name: ${task[i].taskName},id: ${task[i].id},duration: ${task[i].durationTime}, date: ${task[i].date}');
          }
          break;
        case TaskTypes.StartEndTasks:
          tasks = await _db.getStartEndTasks();
          List<StartEndTask> task = tasks;
          if (task.length > 0) {
            for (int i = 0; i < tasks.length; i++) {
              print(
                  'start/end tasks $i name: ${task[i].taskName},id: ${task[i].id},start: ${task[i].startTime},end: ${task[i].endTime}, date: ${task[i].date}');
            }
          }
          break;
      }
    }
    return tasks;
  }

  void _setTotalTimeForTaskType(String totalTime, double percent) {
    _currentTabModel = TabModel(
        kTodayText, kYourTotalTimeText, totalTime, percent, _selectedTask);
  }

  void _setTotalBalanceForTaskType(String totalBalance, double percent) {
    _currentTabModel = TabModel(kTodayText, kYourTotalBalanceText, totalBalance,
        percent, _selectedTask);
  }
}
