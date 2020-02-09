import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/utils/app_utils.dart';

class AddNewTaskProvider with ChangeNotifier {
  String taskName;
  TimeOfDay _pickedStartTime;
  TimeOfDay _pickedEndTime;
  TimeOfDay _pickedDurationTime;
  final TaskTypes _currentTaskType;
  String _errorText;
  DBHelper _db;

  AddNewTaskProvider(this._db, this._currentTaskType);

  String get errorText =>_errorText;

  void setPickedStartTime(TimeOfDay startTime) {
    if (_pickedEndTime != null) {
      if (_pickedEndTime.hour >= startTime.hour &&
          _pickedEndTime.minute >= startTime.minute) {
        this._pickedStartTime = startTime;
        notifyListeners();
      }
    } else {
      this._pickedStartTime = startTime;
      this._pickedDurationTime = null;
    }
    notifyListeners();
  }

  void setPickedEndTime(TimeOfDay endTime) {
    if (endTime != null) {
      if (_pickedStartTime != null) {
        if (endTime.hour > _pickedStartTime.hour &&
            endTime.minute >= _pickedStartTime.minute) {
          this._pickedEndTime = endTime;
          notifyListeners();
        }
      } else {
        this._pickedEndTime = endTime;
        notifyListeners();
      }
    }
  }

   void setPickedDuration(String duration) {
     _errorText=null;
     if(validateDuration(duration)){
     this._pickedDurationTime = AppUtils.formatHHMMTimeToTimeOfDay(duration);
     print('picked duration time ${_pickedDurationTime.hour} and min ${_pickedDurationTime.minute}');
     }
     else{
       _errorText='Duration has to be in HH:MM format.';
     }
    notifyListeners();
  }

  void setPickedDuration2(duration) {
    this._pickedDurationTime = duration;
    print(taskName);
    notifyListeners();
  }

  Future<int> addNewTaskToDB(Function onSuccess) async {
    int taskID = -1;
    if (_db != null) {
      if (validateTaskInputs()) {
        switch (_currentTaskType) {
          case TaskTypes.DurationTasks:
            print(taskName);
            DurationTask task = DurationTask(
                null,
                taskName.trim(),
                AppUtils.formatTimeOfDayToTimeInSeconds(_pickedDurationTime),
                AppUtils.currentTimeInSeconds());
            DurationTask insertedTask = await _db.insertNewDurationTask(task);
            taskID = insertedTask.id;
            onSuccess();
            break;
          case TaskTypes.StartEndTasks:
            StartEndTask task = StartEndTask(
                null,
                taskName.trim(),
                AppUtils.formatTimeOfDayToTimeInSeconds(_pickedStartTime),
                AppUtils.formatTimeOfDayToTimeInSeconds(_pickedEndTime),
                AppUtils.currentTimeInSeconds());
            StartEndTask insertedTask = await _db.insertNewStartEndTask(task);
            taskID = insertedTask.id;
            onSuccess();
            break;
        }
      }
    }
    return taskID;
  }

  bool validateDuration(String inputDuration){
    final hhmmFormatReg= RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$');
    return hhmmFormatReg.hasMatch(inputDuration);
  }

  bool validateTaskInputs() {
    switch (_currentTaskType) {
      case TaskTypes.DurationTasks:
        if (taskName != null && _pickedDurationTime != null) return true;
        return false;
      case TaskTypes.StartEndTasks:
        if (taskName != null &&
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
