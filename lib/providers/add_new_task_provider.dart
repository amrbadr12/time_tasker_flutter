import 'package:add_2_calendar/add_2_calendar.dart' as add_2_calendar;
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/expandedStateModel.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/services/local_notifications_helper.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../utils/app_utils.dart';

class AddNewTaskProvider with ChangeNotifier {
  DateTime _pickedStartDate;
  DateTime _pickedEndDate;
  DateTime duration;
  TimeOfDay _pickedDurationTime;
  final TaskTypes _currentTaskType;
  String _errorText;
  DBHelper _db;
  TextEditingController _nameController;
  TextEditingController _durationController;
  List _previousTasks;
  List _previousStartEndTasks;
  List _prefillCalendarEvents;
  List<int> _calculatedDuration;
  final _totalUserDurationTime;
  bool _calendarTask = false;
  var _overLapPeriod;
  ExpandableController _expandableController;
  List<ExpandedStateModel> _expandedTasks;

  AddNewTaskProvider(
      this._db,
      this._currentTaskType,
      this._nameController,
      this._durationController,
      this._prefillCalendarEvents,
      this._expandableController,
      this._totalUserDurationTime) {
    readMainScreenElementsFromDB(_currentTaskType);
    _prefillCalendarEventToUI();
    _expandedTasks = List();
    if (_expandableController != null) {
      _expandableController.addListener(() {
        if (_expandableController.expanded && _expandedTasks.length == 0) {
          _expandedTasks
              .add(ExpandedStateModel.empty(addNewExpandedTask, taskName));
          notifyListeners();
        }
      });
    }
  }

  String get errorText => _errorText;

  List get previousTasks => _previousTasks;

  TextEditingController get nameController => _nameController;

  TextEditingController get durationController => _durationController;

  List get previousStartEndTasks => _previousStartEndTasks;

  DateTime get pickedStartDate => _pickedStartDate;

  DateTime get pickedEndDate => _pickedEndDate;

  get userTotalDurationTime => _totalUserDurationTime;

  ExpandableController get expandableController => _expandableController;

  String get taskName =>
      _nameController != null ? _nameController.text.trim() : '';

  List<ExpandedStateModel> get expandedTasks =>
      _expandedTasks != null ? _expandedTasks : List();

  getExpandedTasks() {
    if (_expandedTasks != null) return _expandedTasks;
    return List();
  }

  setMultipleTimes(String value) {
    if (value != null && value.isNotEmpty) {
      _expandedTasks.clear();
      int times = int.parse(value);
      for (int i = 0; i < times; i++) {
        addNewExpandedTask();
      }
      notifyListeners();
    }
  }

  void addNewExpandedTask() {
    TextEditingController controller = TextEditingController(text: taskName);
    _expandedTasks.add(ExpandedStateModel(addNewExpandedTask, controller));
    notifyListeners();
  }

  void onTaskNameSubmitted(String task) {
    nameController.text = task;
  }

  void onDurationSubmitted(DurationTask durationTask) {
    UITask uiTask = AppUtils.formatDurationTaskToUIListComponent(durationTask);
    if (uiTask != null) {
      if (uiTask.duration != null) {
        _durationController.text =
            uiTask.duration.substring(0, uiTask.duration.length - 2);
        setPickedDuration(
            uiTask.duration.substring(0, uiTask.duration.length - 2));
      }
    }
  }

  void setPickedStartTime(
      DateTime startDate, Function onShowRecordTillEndOfDayDialog) async {
    if (_pickedEndDate != null) {
      if (_pickedEndDate.isAfter(startDate)) {
        this._pickedStartDate = startDate;
        notifyListeners();
        return;
      } else
        return;
    }
    this._pickedStartDate = startDate;
    // if (_checkIfTaskIsBedOrSleep(startTime)) onShowRecordTillEndOfDayDialog();
    this._pickedDurationTime = null;
    notifyListeners();
  }

  void setPickedEndDate(DateTime end) {
    if (end != null && _pickedStartDate != null) {
      if (end.isAfter(_pickedStartDate)) {
        this._pickedEndDate = end;
        notifyListeners();
      }
    }
  }

  bool checkIfOverlappingTask() {
    if (_previousStartEndTasks != null) {
      if (_previousStartEndTasks.isNotEmpty) {
        int userStartTimeTask =
            AppUtils.dateTimeMillisecondsSinceEpochToSeconds(_pickedStartDate);
        int userEndTimeTask =
            AppUtils.dateTimeMillisecondsSinceEpochToSeconds(_pickedEndDate);
        for (StartEndTask task in _previousStartEndTasks) {
          if (userStartTimeTask >= task.startTime &&
              userStartTimeTask <= task.endTime) {
            if (userEndTimeTask > task.endTime) {
              TimeOfDay overLappingTask = AppUtils.formatDateTimeToTimeOfDay(
                  AppUtils.convertMillisecondsSinceEpochToDateTime(
                      task.endTime));
              List overLap = AppUtils.minusTime(
                  _pickedEndDate.hour,
                  overLappingTask.hour,
                  _pickedEndDate.minute,
                  overLappingTask.minute);
              _overLapPeriod = '${overLap[0]},${overLap[1]}';
              return false;
            } else
              return true;
          }
        }
      }
    }
    return false;
  }

  void setPickedDuration(String duration) {
    _errorText = null;

    notifyListeners();
    if (AppUtils.validateDuration(duration))
      this._pickedDurationTime = AppUtils.formatHHMMTimeToTimeOfDay(duration);
    else {
      if (AppUtils.validateMinutes(duration))
        this._pickedDurationTime = AppUtils.formatHHMMTimeToTimeOfDay(
            AppUtils.formatMinutesToHHMMTime(duration));
      else {
        _errorText = 'Please enter a valid duration.';
        notifyListeners();
      }
    }
  }

  Future<int> addNewTaskToDB(
      {SharedPerferencesUtils sharedPreferencesUtils,
      Function onSuccess,
      Function onOverlappingTask,
      Function onExceedTimeFrameDialog,
      Function onAddingTaskToCalendar,
      Function onError}) async {
    int taskID = -1;
    if (_db != null) {
      if (validateTaskInputs()) {
        SharedPerferencesUtils sharedPerferencesUtils =
            SharedPerferencesUtils(await SharedPreferences.getInstance());
        await AppUtils.updateTimeBalance(sharedPerferencesUtils);
        switch (_currentTaskType) {
          case TaskTypes.DurationTasks:
            TimeOfDay totalDuration;
            _totalUserDurationTime != null
                ? totalDuration = TimeOfDay(
                    hour: _totalUserDurationTime[0] ?? 0,
                    minute: _totalUserDurationTime[1] ?? 0)
                : totalDuration = TimeOfDay(hour: 0, minute: 0);
            List expandedTime = [
              _pickedDurationTime.hour,
              _pickedDurationTime.minute
            ];
            if (_expandedTasks.length > 0) {
              for (int i = 0; i < _expandedTasks.length - 1; i++) {
                print('i is $i');
                expandedTime = AppUtils.addTime(
                    expandedTime[0],
                    _pickedDurationTime.hour,
                    expandedTime[1],
                    _pickedDurationTime.minute);
              }
            }
            // List addedTime = AppUtils.addTime(totalDuration.hour,
            //     expandedTime[0], totalDuration.minute, expandedTime[1]);
            if (await _checkIfTimeIsMoreThanTimeBalance(
              onExceedTimeFrameDialog,
              expandedTime,
            )) return -1;
            String commaSeparatedTasks =
                AppUtils.parseExpandedTasksToCommaSeparatedTasks(
                    _expandedTasks);
            DurationTask task = DurationTask(
              null,
              _nameController.text.trim(),
              AppUtils.formatTimeOfDayToTimeInSeconds(_pickedDurationTime),
              AppUtils.currentTimeInSeconds(),
              commaSeparatedTasks,
            );
            DurationTask insertedTask = await _db.insertNewDurationTask(task);
            taskID = insertedTask.id;
            onSuccess();
            break;
          case TaskTypes.StartEndTasks:
            if (!checkIfOverlappingTask()) {
              //Adding the task to the device's calendar
              if (_totalUserDurationTime != null) {
                List addedTime = AppUtils.addTime(
                    _totalUserDurationTime[0],
                    _calculatedDuration[0],
                    _totalUserDurationTime[1],
                    _calculatedDuration[1]);
                if (await _checkIfTimeIsMoreThanTimeBalance(
                    onExceedTimeFrameDialog, addedTime)) return -1;
              }
              if (!_calendarTask) {
                if (await onAddingTaskToCalendar()) {
                  final add_2_calendar.Event event = add_2_calendar.Event(
                    title: _nameController.text.trim(),
                    description: 'TT Task',
                    location: '',
                    startDate: _pickedStartDate,
                    endDate: _pickedEndDate,
                  );
                  add_2_calendar.Add2Calendar.addEvent2Cal(event);
                }
              }

              StartEndTask task = StartEndTask(
                  null,
                  _nameController.text.trim(),
                  AppUtils.dateTimeMillisecondsSinceEpochToSeconds(
                      _pickedStartDate),
                  AppUtils.dateTimeMillisecondsSinceEpochToSeconds(
                      _pickedEndDate),
                  AppUtils.currentTimeInSeconds(),
                  _calendarTask ? 1 : 0,
                  _overLapPeriod ?? '');
              //Adding the task to the local db
              StartEndTask insertedTask = await _db.insertNewStartEndTask(task);
              GetIt.instance<LocalNotificationsHelper>().scheduleNotification(
                  dateTime: _pickedStartDate,
                  scheduledTitle: 'TimeTasker Reminder',
                  scheduledBody:
                      'Your task ${_nameController.text.trim()} is starting now!');
              taskID = insertedTask.id;
              onSuccess();
            } else
              onOverlappingTask();
            break;
        }
      }
    }
    return taskID;
  }

  _prefillCalendarEventToUI() {
    if (_currentTaskType == TaskTypes.StartEndTasks) {
      if (_prefillCalendarEvents != null) {
        if (_prefillCalendarEvents.isNotEmpty) {
          Event calendarEvent = _prefillCalendarEvents[0];
          _nameController.text = calendarEvent.title;

          // _pickedStartTime =
          //     AppUtils.formatDateTimeToTimeOfDay(calendarEvent.start);
          // _pickedEndTime =
          //     AppUtils.formatDateTimeToTimeOfDay(calendarEvent.end);

          _calendarTask = true;
          notifyListeners();
        }
      }
    }
  }

  Future<void> readMainScreenElementsFromDB(TaskTypes taskTypes) async {
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
    _previousTasks = List();
    _previousStartEndTasks = tasks;
    _previousTasks = filterDataDuplicates(tasks);
    notifyListeners();
    return _previousTasks;
  }

  List<Task> filterDataDuplicates(List<Task> tasks) {
    List<Task> uniqueTasks = List();
    List<String> namedTasks = List();
    for (int i = 0; i < tasks.length; i++) {
      if (!namedTasks.contains(tasks[i].taskName)) {
        uniqueTasks.add(tasks[i]);
        namedTasks.add(tasks[i].taskName);
      }
    }
    return uniqueTasks;
  }

  Future<bool> _checkIfTimeIsMoreThanTimeBalance(
      Function onExceedTimeFrame, List addedTime) async {
    SharedPerferencesUtils sharedPerferencesUtils =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    int userTotalHourBalance = sharedPerferencesUtils
        .getIntFromSharedPreferences(kTotalBalanceHoursKey);
    int userTotalMinutesBalance = sharedPerferencesUtils
        .getIntFromSharedPreferences(kTotalBalanceMinutesKey);
    print(
        'user total hour is $userTotalHourBalance and minutes is $userTotalMinutesBalance and added time is ${addedTime[0]} and 1 is ${addedTime[1]}');
    if (userTotalHourBalance == 0 && userTotalMinutesBalance == 0) {
      onExceedTimeFrame(
          'Please update your time balance from the settings screen to begin adding tasks again.');
      return true;
    } else {
      int timeSaved = sharedPerferencesUtils
          .getIntFromSharedPreferences(kTimeSelectedSettingsKey);
      print('time saved is ${timeSaved}');
      if (timeSaved != 0) {
        //If the user has set the clock from the settings
        DateTime timeSavedDateTime =
            DateTime.fromMillisecondsSinceEpoch(timeSaved);
        if (_currentTaskType == TaskTypes.StartEndTasks) {
          if (_pickedStartDate.isAfter(timeSavedDateTime) ||
              _pickedEndDate.isAfter(timeSavedDateTime)) {
            onExceedTimeFrame('Please reset your clock from the settings.');
            return true;
          }
        }
        List<double> difference =
            AppUtils.calculateTheDifferenceBetweenDatesInHoursAndMinutes(
                timeSavedDateTime);
        return _checkIfTheUserExceededTheirTimeFrameWithSlider(
            onExceedTimeFrame,
            difference[0].toInt(),
            difference[1].toInt(),
            addedTime);
      } //If they set the slider
      else
        return _checkIfTheUserExceededTheirTimeFrameWithSlider(
            onExceedTimeFrame,
            userTotalHourBalance,
            userTotalMinutesBalance,
            addedTime);
    }
  }

  bool _checkIfTheUserExceededTheirTimeFrameWithSlider(
    Function onExceedTimeFrame,
    int userTotalHourBalance,
    int userTotalMinutesBalance,
    List addedTime,
  ) {
    print(
        'userTotalHourBalance is ${userTotalHourBalance} and userTotalMinutesBalance is ${userTotalMinutesBalance} and addedTime is ${addedTime[0]} and 1 is ${addedTime[1]}');
    if (addedTime[0] >= userTotalHourBalance) {
      if (addedTime[0] == userTotalHourBalance) {
        if (addedTime[1] <= userTotalMinutesBalance) return false;
      }
      List duration;
      if (addedTime[1] >= userTotalMinutesBalance)
        duration = AppUtils.minusTime(addedTime[0], userTotalHourBalance,
            addedTime[1], userTotalMinutesBalance);
      else
        duration = AppUtils.minusTime(addedTime[0], userTotalHourBalance,
            userTotalMinutesBalance, addedTime[1]);
      onExceedTimeFrame(
          'You exceeded your time frame by ${AppUtils.formatTimeToHHMM(duration[0], duration[1])}');
      return true;
    }
    return false;
  }

  bool validateTaskInputs() {
    switch (_currentTaskType) {
      case TaskTypes.DurationTasks:
        if (nameController.text != null &&
            _pickedDurationTime != null &&
            nameController.text.isNotEmpty) return true;
        return false;
      case TaskTypes.StartEndTasks:
        if (nameController.text != null &&
            nameController.text.isNotEmpty &&
            _pickedStartDate != null &&
            _pickedEndDate != null) return true;
        return false;
    }
    return false;
  }

  String getStartTime() {
    if (_pickedStartDate != null) {
      String hour = AppUtils.formatTimeToTwoDecimals(_pickedStartDate.hour);
      String minute = AppUtils.formatTimeToTwoDecimals(_pickedStartDate.minute);
      return 'Start Time: $hour:$minute';
    }
    return 'Enter Start Time';
  }

  String getEndTime() {
    if (_pickedEndDate != null) {
      String hour = AppUtils.formatTimeToTwoDecimals(_pickedEndDate.hour);
      String minute = AppUtils.formatTimeToTwoDecimals(_pickedEndDate.minute);
      return 'End Time: $hour:$minute';
    }
    return 'Enter End Time';
  }

  String getDuration() {
    if (_pickedDurationTime != null) {
      String hour = AppUtils.formatTimeToTwoDecimals(_pickedDurationTime.hour);
      String minute =
          AppUtils.formatTimeToTwoDecimals(_pickedDurationTime.minute);
      return 'Duration: $hour h: $minute m';
    }
    return 'Enter Duration';
  }

  String getCalculatedDuration() {
    if (_pickedStartDate != null && _pickedEndDate != null) {
      List<double> result = AppUtils.calculateDifferenceBetweenTwoDates(
          _pickedStartDate, _pickedEndDate);
      _calculatedDuration = [result[0].toInt(), result[1].toInt()];
      return 'Total Duration:${AppUtils.formatTimeToHHMM(_calculatedDuration[0], _calculatedDuration[1])}';
    }
    return 'Total Duration';
  }

  void resetTime() {
    _calendarTask = false;
    _pickedStartDate = null;
    _pickedEndDate = null;
    duration = null;
    _pickedDurationTime = null;
    notifyListeners();
  }
}
