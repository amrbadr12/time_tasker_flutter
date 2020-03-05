import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';

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
  List<StartEndTask> _previousStartEndTasks;

  AddNewTaskProvider(this._db, this._currentTaskType, this._nameController) {
    readMainScreenElementsFromDB(_currentTaskType);
  }

  String get errorText => _errorText;
  List<String> get previousTasks => _previousTasks;
  TextEditingController get nameController => _nameController;
  TextEditingController get durationController => _durationController;
  List<StartEndTask> get previousStartEndTasks => _previousStartEndTasks;

  void onTaskNameSubmitted(String task) {
    nameController.text = task;
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
        for (StartEndTask task in _previousStartEndTasks) {
          if (userStartTimeTask >= task.startTime &&
              userStartTimeTask <= task.endTime) {
            print('overlapping task');
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
      Function onSuccess, Function onOverlappingTask) async {
    int taskID = -1;
    if (_db != null) {
      if (validateTaskInputs()) {
        switch (_currentTaskType) {
          case TaskTypes.DurationTasks:
            DurationTask task = DurationTask(
                null,
                _nameController.text.trim(),
                AppUtils.formatTimeOfDayToTimeInSeconds(_pickedDurationTime),
                AppUtils.currentTimeInSeconds());
            DurationTask insertedTask = await _db.insertNewDurationTask(task);
            taskID = insertedTask.id;
            onSuccess();
            break;
          case TaskTypes.StartEndTasks:
            if (!checkIfOverlappingTask()) {
              StartEndTask task = StartEndTask(
                  null,
                  _nameController.text.trim(),
                  AppUtils.formatTimeOfDayToTimeInSeconds(_pickedStartTime),
                  AppUtils.formatTimeOfDayToTimeInSeconds(_pickedEndTime),
                  AppUtils.currentTimeInSeconds());
              StartEndTask insertedTask = await _db.insertNewStartEndTask(task);
              taskID = insertedTask.id;
              onSuccess();
            } else {
              onOverlappingTask();
            }
            break;
        }
      }
    }
    return taskID;
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
        List<int> duration = AppUtils.calculateDuration(
            _pickedStartTime.hour,
            _pickedEndTime.hour,
            _pickedStartTime.minute,
            _pickedEndTime.minute);
        String durationHours = AppUtils.formatTimeToTwoDecimals(duration[0]);
        String durationMinutes = AppUtils.formatTimeToTwoDecimals(duration[1]);
        return 'Total Duration: $durationHours h: $durationMinutes m';
      }
    }
    return 'Total Duration';
  }

  void resetTime() {
    _pickedStartTime = null;
    _pickedEndTime = null;
    _pickedDurationTime = null;
    notifyListeners();
  }
}
