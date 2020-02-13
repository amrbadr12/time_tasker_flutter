import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/reusable_widgets/white_container_reusable.dart';

import '../constants.dart';

class MainScreenReusableTab extends StatelessWidget {
  final String date;
  final String mainTitle;
  final String circularCenterText;
  final double circlePercent;
  final Function onTaskDelete;
  final UITask upcomingTask;
  final List<UITask> recentTasksList;
  final String taskType;

  MainScreenReusableTab(
      {this.date,
      this.mainTitle,
      this.circularCenterText,
      this.circlePercent,
      this.upcomingTask,
      this.taskType,
      this.onTaskDelete,
      this.recentTasksList});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                top: kTitleDefaultPaddingVertical,
                left: kTitleDefaultPaddingHorizontal,
              ),
              child: Text(date,
                  style: kSubTitleTextStyle.copyWith(fontSize: 15.0)),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 15.0, left: kTitleDefaultPaddingHorizontal, bottom: 5.0),
              child: Text(
                mainTitle,
                style: kTitleTextStyle,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: kTitleDefaultPaddingHorizontal,
                right: kTitleDefaultPaddingHorizontal),
            height: 4.0,
            width: double.infinity,
            decoration:
                BoxDecoration(gradient: LinearGradient(colors: blueGradient)),
          ),
          SizedBox(height: kTitleDefaultPaddingVertical),
          Container(
            decoration: BoxDecoration(
                color: Colors.blueGrey[700],
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(
                horizontal: kTitleDefaultPaddingHorizontal),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: CircularPercentIndicator(
                  radius: 150.0,
                  lineWidth: 5.0,
                  percent: circlePercent,
                  animation: true,
                  animationDuration: 1200,
                  center: Text(
                    circularCenterText,
                    style: kTitleTextStyle.copyWith(color: Colors.white),
                  ),
                  progressColor: blueGradient[0],
                  backgroundColor: blueGradient[1]),
            ),
          ),
          Visibility(
            visible: taskType == 'Start/End' && upcomingTask != null ?? false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: kTitleDefaultPaddingVertical,
                        left: kTitleDefaultPaddingHorizontal,
                        bottom: 5.0),
                    child: Text(
                      'Upcoming Task',
                      style: kTitleTextStyle.copyWith(fontSize: 20.0),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.only(
                      top: kTitleDefaultPaddingHorizontal,
                      right: kTitleDefaultPaddingHorizontal,
                      left: kTitleDefaultPaddingHorizontal),
                  color: Colors.blue.shade600,
                  elevation: 5.0,
                  child: ListTile(
                    title: Text(upcomingTask!=null?
                      upcomingTask.taskName.toUpperCase():'',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    subtitle: Text(upcomingTask!=null?upcomingTask.date:'',
                        style: TextStyle(color: Colors.grey[100])),
                    leading: Icon(FontAwesomeIcons.dotCircle,
                        color: Colors.blue.shade200),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Divider(
            thickness: 2.0,
          ),
          WhiteReusableContainer(
            verticalMargin: kMainDefaultHeightPadding,
            horizontalMargin: kMainDefaultHeightPadding,
            containerChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('Recorded Tasks', style: kSubTitleTextStyle),
                  ),
                ),
                ListView.builder(
                    itemCount:
                        recentTasksList == null ? 2 : recentTasksList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        onDismissed: (direction) {
                          print(recentTasksList[index].id);
                          onTaskDelete(recentTasksList[index].id);
                        },
                        child: ListTile(
                          title: Text(recentTasksList[index].taskName),
                          subtitle: Text(recentTasksList[index].date),
                          leading: Icon(FontAwesomeIcons.dotCircle,
                              color: kTasksDateIconColor2),
                          trailing: Text(recentTasksList[index].duration),
                        ),
                        key: UniqueKey(),
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
