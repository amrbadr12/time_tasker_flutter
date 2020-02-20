import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

abstract class Task {
  int id;
  String taskName;
  var date;
  Map<String, dynamic> toMap();
}

class UITask{
  int id;
  String taskName;
  String duration;
  Color color;
  TaskTypes tasktype;
  String date;

  UITask(id,name,duration,color,date,type){
    this.id=id;
    this.taskName=name;
    this.duration=duration;
    this.color=color;
    this.date=date;
    this.tasktype=type;
  }

  @override
  String toString() {
    return '$id$taskName';
  }

}


class DurationTask extends Task {
  var durationTime;

  DurationTask(id, taskName, duration,dateInserted){
    this.id=id;
    this.taskName=taskName;
    this.durationTime=duration;
    this.date=dateInserted;
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {'id': this.id, 'name': this.taskName, 'duration': this.durationTime, 'date':this.date};
  }

  DurationTask.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    taskName = map['name'];
    durationTime = map['duration'];
    date= map['date'];
  }
}

class StartEndTask extends Task {
  var startTime;
  var endTime;

  StartEndTask(id, taskName,start,end,dateInserted){
    this.id=id;
    this.taskName=taskName;
    this.startTime=start;
    this.endTime=end;
    this.date=dateInserted;
  }

  @override
  Map<String, dynamic> toMap() {
    return {'id': this.id, 'name': this.taskName, 'start_time': this.startTime, 'end_time': this.endTime, 'date':this.date};
  }

  StartEndTask.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.taskName = map['name'];
    this.startTime = map['start_time'];
    this.endTime = map['end_time'];
    this.date= map['date'];
  }
}
