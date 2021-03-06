import 'package:flutter/cupertino.dart';

class ExpandedStateModel {
  //IconData icon;
  TextEditingController task;
  Function addOrRemoveTask;

  ExpandedStateModel(
      this.addOrRemoveTask,
      //   this.icon,
      this.task);

  factory ExpandedStateModel.empty(addOrRemoveTask, initial) {
    return ExpandedStateModel(
        addOrRemoveTask,
        // , FontAwesomeIcons.plusCircle,
        TextEditingController(text: initial));
  }
}
