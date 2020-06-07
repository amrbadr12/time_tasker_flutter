import '../constants.dart';

class TabModel {
  String currentDate;
  String mainTitle;
  String circularCenterText = '';
  double circlePercent = 0.0;
  TaskTypes selectedTask;

  TabModel(date, title, centerText, percent, selectedTask) {
    currentDate = date;
    mainTitle = title;
    circularCenterText = centerText;
    circlePercent = percent;
    selectedTask = selectedTask;
  }

  static TabModel getDefaultTabModel() {
    return TabModel('TODAY', 'Total Time', '', 0.0, TaskTypes.DurationTasks);
  }
}
