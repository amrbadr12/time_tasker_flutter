import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

abstract class Task {
  int id;
  String taskName;
  var date;
  Map<String, dynamic> toMap();
}

class UITask {
  int id;
  String taskName;
  String duration;
  Color color;
  TaskTypes taskType;
  DateTime startTime;
  DateTime endTime;
  String date;
  var expandedTasks;

  UITask(id, name, duration, color, date, type, start, end, expandedTasks) {
    this.id = id;
    this.taskName = name;
    this.duration = duration;
    this.color = color;
    this.date = date;
    this.taskType = type;
    this.startTime = start;
    this.endTime = end;
    this.expandedTasks = expandedTasks;
  }

  @override
  String toString() {
    return '$id$taskName';
  }
}

class DurationTask extends Task {
  var durationTime;
  var expandedTasks;

  DurationTask(id, taskName, duration, dateInserted, expandedTasks) {
    this.id = id;
    this.taskName = taskName;
    this.durationTime = duration;
    this.date = dateInserted;
    this.expandedTasks = expandedTasks;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.taskName,
      'duration': this.durationTime,
      'date': this.date,
      'expanded_tasks': this.expandedTasks,
    };
  }

  DurationTask.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    taskName = map['name'];
    durationTime = map['duration'];
    date = map['date'];
    this.expandedTasks = map['expanded_tasks'];
  }
}

class StartEndTask extends Task {
  var startTime;
  var endTime;
  int isCalendarTask;
  var overlapPeriod;

  StartEndTask(
      id, taskName, start, end, dateInserted, calendarTask, overlapPeriod) {
    this.id = id;
    this.taskName = taskName;
    this.startTime = start;
    this.endTime = end;
    this.date = dateInserted;
    this.isCalendarTask = calendarTask;
    this.overlapPeriod = overlapPeriod;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.taskName,
      'start_time': this.startTime,
      'end_time': this.endTime,
      'date': this.date,
      'calendar_task': this.isCalendarTask,
      'overlap_period': this.overlapPeriod
    };
  }

  StartEndTask.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.taskName = map['name'];
    this.startTime = map['start_time'];
    this.endTime = map['end_time'];
    this.date = map['date'];
    this.isCalendarTask = map['calendar_task'];
    this.overlapPeriod = map['overlap_period'];
  }
}
