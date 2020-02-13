import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';

class AddNewTaskProvider with ChangeNotifier {
  TimeOfDay _pickedStartTime;
  TimeOfDay _pickedEndTime;
  TimeOfDay _pickedDurationTime;
  final TaskTypes _currentTaskType;
  String _errorText;
  DBHelper _db;
  TextEditingController _nameController;
  List<String> _previousTasks;
  List<StartEndTask> _previousStartEndTasks;

  AddNewTaskProvider(this._db, this._currentTaskType, this._nameController) {
    readMainScreenElementsFromDB(_currentTaskType);
  }

  String get errorText => _errorText;
  List<String> get previousTasks => _previousTasks;
  TextEditingController get nameController => _nameController;
  List<StartEndTask> get previousStartEndaTasks => _previousStartEndTasks;

  void onTaskNameSubmitted(String task) {
    nameController.text = task;
  }

  void setPickedStartTime(TimeOfDay startTime) {
    if (_pickedEndTime != null) {
      if (_pickedEndTime.hour >= startTime.hour &&
          _pickedEndTime.minute >= startTime.minute) {
        this._pickedStartTime = startTime;
        notifyListeners();
        return;
      }
    }
    this._pickedStartTime = startTime;
    this._pickedDurationTime = null;
    notifyListeners();
  }

  void setPickedEndTime(TimeOfDay endTime) {
    if (_pickedStartTime != null) {
      if (endTime.hour >= _pickedStartTime.hour &&
          endTime.minute >= _pickedStartTime.minute) {
        print('picked end time is more than starttime');
        this._pickedEndTime = endTime;
        notifyListeners();
      }
    } else {
      this._pickedEndTime = endTime;
      notifyListeners();
    }
  }

  bool checkIfOverlappingTask() {
    if (_previousStartEndTasks != null) {
      if (_previousStartEndTasks.isNotEmpty) {
        int userStartTimeTask =
            AppUtils.formatTimeOfDayToTimeInSeconds(_pickedStartTime);
        for (StartEndTask task in _previousStartEndTasks) {
          if (userStartTimeTask >= task.startTime &&
              userStartTimeTask <= task.endTime) {
            print('overlapping task...');
            return true;
          }
        }
      }
    }
    return false;
  }

  void setPickedDuration(String duration) {
    _errorText = null;
    if (validateDuration(duration)) {
      this._pickedDurationTime = AppUtils.formatHHMMTimeToTimeOfDay(duration);
      print(
          'picked duration time ${_pickedDurationTime.hour} and min ${_pickedDurationTime.minute}');
    } else {
      _errorText = 'Duration has to be in HH:MM format.';
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
            print(_nameController.text);
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
                  nameController.text.trim(),
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
          List<DurationTask> task = tasks;
          for (int i = 0; i < tasks.length; i++) {
            print(
                'duration tasks $i name: ${task[i].taskName},id: ${task[i].id},duration: ${task[i].durationTime}, date: ${task[i].date}');
          }
          break;
        case TaskTypes.StartEndTasks:
          tasks = await _db.getStartEndTasks();
          List<StartEndTask> task = tasks;
          _previousStartEndTasks = task;
          if (task.length > 0) {
            for (int i = 0; i < tasks.length; i++) {
              print(
                  'start/end tasks $i name: ${task[i].taskName},id: ${task[i].id},start: ${task[i].startTime},end: ${task[i].endTime}, date: ${task[i].date}');
            }
          }
          break;
      }
    }
    _previousTasks = List();
    _previousTasks = filterDataDuplicates(tasks);
    notifyListeners();
    return _previousTasks;
  }

  bool validateDuration(String inputDuration) {
    final hhmmFormatReg = RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$');
    return hhmmFormatReg.hasMatch(inputDuration);
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
        if (nameController.text != null && _pickedDurationTime != null)
          return true;
        return false;
      case TaskTypes.StartEndTasks:
        if (nameController.text != null &&
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
        String durationHours = AppUtils.formatTimeToTwoDecimals(
            _pickedEndTime.hour - _pickedStartTime.hour);
        String durationMinutes = AppUtils.formatTimeToTwoDecimals(
            _pickedEndTime.minute - _pickedStartTime.minute);
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
