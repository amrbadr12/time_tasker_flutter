import 'package:add_2_calendar/add_2_calendar.dart' as add_2_calendar;
import 'package:device_calendar/device_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/expandedStateModel.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../utils/app_utils.dart';

class AddNewTaskProvider with ChangeNotifier {
  TimeOfDay _pickedStartTime;
  TimeOfDay _pickedEndTime;
  TimeOfDay _pickedDurationTime;
  final TaskTypes _currentTaskType;
  String _errorText;
  DBHelper _db;
  TextEditingController _nameController;
  TextEditingController _durationController;
  List<String> _previousTasks;
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

  List<String> get previousTasks => _previousTasks;

  TextEditingController get nameController => _nameController;

  TextEditingController get durationController => _durationController;

  List get previousStartEndTasks => _previousStartEndTasks;

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

  void addNewExpandedTask() {
    int currentIndex = _expandedTasks.length - 1;
    _expandedTasks[currentIndex].icon = FontAwesomeIcons.minusCircle;
    _expandedTasks[currentIndex].addOrRemoveTask = () {
      removeTask(currentIndex);
    };
    TextEditingController controller = TextEditingController(text: taskName);
//    print(
//        'current index is $currentIndex and controller text is ${_nameController.text.trim()}');
    // controller.text = _nameController.text.trim();
    _expandedTasks.add(ExpandedStateModel(
        addNewExpandedTask, FontAwesomeIcons.plusCircle, controller));
    notifyListeners();
  }

  void onTaskNameSubmitted(String task) {
    nameController.text = task;
  }

  void removeTask(int currentIndex) {
    if (_expandedTasks.length == 1) {
      _expandedTasks[currentIndex].icon = FontAwesomeIcons.plusCircle;
      _expandedTasks[currentIndex].addOrRemoveTask = () {
        addNewExpandedTask();
      };
    } else
      _expandedTasks.removeAt(currentIndex);
    notifyListeners();
  }

  void setPickedStartTime(
      TimeOfDay startTime, Function onShowRecordTillEndOfDayDialog) async {
    if (_pickedEndTime != null) {
      if (_pickedEndTime.hour >= startTime.hour &&
          _pickedEndTime.minute >= startTime.minute) {
        this._pickedStartTime = startTime;
        notifyListeners();
        return;
      } else
        return;
    }
    this._pickedStartTime = startTime;
    if (_checkIfTaskIsBedOrSleep(startTime)) onShowRecordTillEndOfDayDialog();
    this._pickedDurationTime = null;
    notifyListeners();
  }

  void setSleepTask(bool recordTillEOD) {
    if (recordTillEOD) {
      DateTime now = DateTime.now();
      DateTime newEndTime = DateTime(now.year, now.month, now.day, 23, 59);
      this._pickedEndTime = TimeOfDay.fromDateTime(newEndTime);
      notifyListeners();
    }
  }

  void setPickedEndTime(TimeOfDay endTime) {
    if (endTime != null) {
      if (_pickedStartTime != null) {
        if (endTime.hour >= _pickedStartTime.hour) {
          if (endTime.hour == _pickedStartTime.hour) {
            if (endTime.minute <= _pickedStartTime.minute) return;
          }
          this._pickedEndTime = endTime;
          notifyListeners();
        }
      } else {
        this._pickedEndTime = endTime;
        notifyListeners();
      }
    }
  }

  bool _checkIfTaskIsBedOrSleep(TimeOfDay startTime) {
    if (_nameController.text.toLowerCase() == 'bed' ||
        _nameController.text.toLowerCase() == 'sleep') {
      return startTime.hour >= 20 && startTime.hour < 24;
    }
    return false;
  }

  bool checkIfOverlappingTask() {
    if (_previousStartEndTasks != null) {
      if (_previousStartEndTasks.isNotEmpty) {
        int userStartTimeTask =
            AppUtils.formatTimeOfDayToTimeInSeconds(_pickedStartTime);
        int userEndTimeTask =
            AppUtils.formatTimeOfDayToTimeInSeconds(_pickedEndTime);
        for (StartEndTask task in _previousStartEndTasks) {
          if (userStartTimeTask >= task.startTime &&
              userStartTimeTask <= task.endTime) {
            if (userEndTimeTask > task.endTime) {
              TimeOfDay overLappingTask = AppUtils.formatDateTimeToTimeOfDay(
                  AppUtils.convertMillisecondsSinceEpochToDateTime(
                      task.endTime));
              List overLap = AppUtils.minusTime(
                  _pickedEndTime.hour,
                  overLappingTask.hour,
                  _pickedEndTime.minute,
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
    if (AppUtils.validateDuration(duration)) {
      this._pickedDurationTime = AppUtils.formatHHMMTimeToTimeOfDay(duration);
    } else {
      _errorText = 'Please enter a valid duration.';
    }
    notifyListeners();
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
        int userTotalHourBalance = sharedPreferencesUtils
            .getIntFromSharedPreferences(kTotalBalanceHoursKey);
        int userTotalMinutesBalance = sharedPreferencesUtils
            .getIntFromSharedPreferences(kTotalBalanceMinutesKey);
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
              for (int i = 0; i < _expandedTasks.length; i++) {
                expandedTime = AppUtils.addTime(
                    expandedTime[0],
                    _pickedDurationTime.hour,
                    expandedTime[1],
                    _pickedDurationTime.minute);
              }
            }
            List addedTime = AppUtils.addTime(totalDuration.hour,
                expandedTime[0], totalDuration.minute, expandedTime[1]);
            if (_checkIfTimeIsMoreThanTimeBalance(
                onExceedTimeFrameDialog,
                userTotalHourBalance,
                userTotalMinutesBalance,
                addedTime)) return -1;
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
                if (_checkIfTimeIsMoreThanTimeBalance(
                    onExceedTimeFrameDialog,
                    userTotalHourBalance,
                    userTotalMinutesBalance,
                    addedTime)) return -1;
              }
              if (!_calendarTask) {
                if (await onAddingTaskToCalendar()) {
                  final add_2_calendar.Event event = add_2_calendar.Event(
                    title: _nameController.text.trim(),
                    description: 'TT Task',
                    location: '',
                    startDate:
                        AppUtils.formatTimeOfDayToDateTime(_pickedStartTime),
                    endDate: AppUtils.formatTimeOfDayToDateTime(_pickedEndTime),
                  );
                  add_2_calendar.Add2Calendar.addEvent2Cal(event);
                }
              }
              StartEndTask task = StartEndTask(
                  null,
                  _nameController.text.trim(),
                  AppUtils.formatTimeOfDayToTimeInSeconds(_pickedStartTime),
                  AppUtils.formatTimeOfDayToTimeInSeconds(_pickedEndTime),
                  AppUtils.currentTimeInSeconds(),
                  _calendarTask ? 1 : 0,
                  _overLapPeriod ?? '');
              //Adding the task to the local db
              StartEndTask insertedTask = await _db.insertNewStartEndTask(task);
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
          _pickedStartTime =
              AppUtils.formatDateTimeToTimeOfDay(calendarEvent.start);
          _pickedEndTime =
              AppUtils.formatDateTimeToTimeOfDay(calendarEvent.end);

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

  List<String> filterDataDuplicates(List<Task> tasks) {
    List<String> textTasks = List();
    for (Task task in tasks) {
      textTasks.add(task.taskName);
    }
    textTasks = textTasks.toSet().toList();
    return textTasks;
  }

  bool _checkIfTimeIsMoreThanTimeBalance(Function onExceedTimeFrame,
      int userTotalHourBalance, int userTotalMinutesBalance, List addedTime) {
    switch (userTotalHourBalance) {
      case 24:
        if (addedTime[0] >= userTotalHourBalance) {
          if (addedTime[0] == userTotalHourBalance) {
            if (addedTime[1] < userTotalMinutesBalance) break;
          }
          onExceedTimeFrame(timeMoreThan24Hours);
          return true;
        }
        break;
      default:
        if (addedTime[0] >= userTotalHourBalance) {
          if (addedTime[0] == userTotalHourBalance) {
            if (addedTime[1] < userTotalMinutesBalance) break;
          }
          onExceedTimeFrame(timeLessThan24Hours);
          return true;
        }
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
            _pickedStartTime != null &&
            _pickedEndTime != null) return true;
        return false;
    }
    return false;
  }

  String getStartTime() {
    if (_pickedStartTime != null) {
      String hour = AppUtils.formatTimeToTwoDecimals(_pickedStartTime.hour);
      String minute = AppUtils.formatTimeToTwoDecimals(_pickedStartTime.minute);
      return 'Start Time: $hour:$minute';
    }
    return 'Enter Start Time';
  }

  String getEndTime() {
    if (_pickedEndTime != null) {
      String hour = AppUtils.formatTimeToTwoDecimals(_pickedEndTime.hour);
      String minute = AppUtils.formatTimeToTwoDecimals(_pickedEndTime.minute);
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
    if (_pickedStartTime != null && _pickedEndTime != null) {
      if (_pickedStartTime.hour.toString().isNotEmpty &&
          _pickedEndTime.hour.toString().isNotEmpty) {
        _calculatedDuration = AppUtils.calculateDuration(
            _pickedStartTime.hour,
            _pickedEndTime.hour,
            _pickedStartTime.minute,
            _pickedEndTime.minute);
        String durationHours =
            AppUtils.formatTimeToTwoDecimals(_calculatedDuration[0]);
        String durationMinutes =
            AppUtils.formatTimeToTwoDecimals(_calculatedDuration[1]);
        return 'Total Duration: $durationHours h: $durationMinutes m';
      }
    }
    return 'Total Duration';
  }

  void resetTime() {
    _calendarTask = false;
    _pickedStartTime = null;
    _pickedEndTime = null;
    _pickedDurationTime = null;
    notifyListeners();
  }
}
