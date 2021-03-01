import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/reusable_widgets/white_container_reusable.dart';
import 'package:time_tasker/utils/dialog_utils.dart';

import '../constants.dart';
import '../utils/app_utils.dart';

class MainScreenReusableTab extends StatelessWidget {
  final String date;
  final String mainTitle;
  final String circularCenterText;
  final double circlePercent;
  final Function onTaskDelete;
  final UITask upcomingTask;
  final List<UITask> recentTasksList;
  final String taskType;
  final Function onAddButtonTap;
  final Function onReset;
  final Function onShareToWhatsApp;
  final Function onShareSMS;

  MainScreenReusableTab(
      {this.date,
      this.mainTitle,
      this.circularCenterText,
      this.circlePercent,
      this.upcomingTask,
      this.taskType,
      this.onTaskDelete,
      this.recentTasksList,
      this.onAddButtonTap,
      this.onReset,
      this.onShareToWhatsApp,
      this.onShareSMS});

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
                  percent: circlePercent >= 1.0 || circlePercent <= 0
                      ? 1.0
                      : circlePercent,
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
//          Visibility(
//            visible: taskType == 'Start/End' && upcomingTask != null ?? false,
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                Flexible(
//                  child: Padding(
//                    padding: EdgeInsets.only(
//                        top: kTitleDefaultPaddingVertical,
//                        left: kTitleDefaultPaddingHorizontal,
//                        bottom: 5.0),
//                    child: Text(
//                      'Upcoming Task',
//                      style: kTitleTextStyle.copyWith(fontSize: 20.0),
//                    ),
//                  ),
//                ),
//                Card(
//                  margin: EdgeInsets.only(
//                      top: kTitleDefaultPaddingHorizontal,
//                      right: kTitleDefaultPaddingHorizontal,
//                      left: kTitleDefaultPaddingHorizontal),
//                  color: Colors.blue.shade600,
//                  elevation: 5.0,
//                  child: ListTile(
//                    title: Text(
//                      upcomingTask != null
//                          ? upcomingTask.taskName.toUpperCase()
//                          : '',
//                      style: TextStyle(color: Colors.white, fontSize: 20.0),
//                    ),
//                    subtitle: Text(
//                        upcomingTask != null ? upcomingTask.date : '',
//                        style: TextStyle(color: Colors.grey[100])),
//                    leading: Icon(FontAwesomeIcons.dotCircle,
//                        color: Colors.blue.shade200),
//                  ),
//                ),
//              ],
//            ),
//          ),
//          SizedBox(
//            height: 15.0,
//          ),
          Divider(
            thickness: 2.0,
          ),
          SizedBox(
            height: kMainDefaultHeightPadding,
          ),
          WhiteReusableContainer(
            horizontalMargin: kMainDefaultHeightPadding,
            containerChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('Tasks', style: kSubTitleTextStyle),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.restore,
                              size: 20.0,
                              color: Colors.blue[700],
                            ),
                            onPressed: onReset,
                          ),
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              FontAwesomeIcons.whatsapp,
                              size: 20.0,
                              color: Colors.green,
                            ),
                            onPressed: onShareToWhatsApp,
                          ),
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              FontAwesomeIcons.sms,
                              color: Colors.blue[700],
                              size: 15.0,
                            ),
                            onPressed: onShareSMS,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                    itemCount:
                        recentTasksList == null ? 2 : recentTasksList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await DialogUtils.showConfirmDeleteDialog(
                                context);
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd)
                            onTaskDelete(recentTasksList[index].id);
                        },
                        child: ExpandablePanel(
                          header: ListTile(
                            title: Text(recentTasksList[index].taskName),
                            subtitle: recentTasksList[index].taskType ==
                                    TaskTypes.StartEndTasks
                                ? Text(AppUtils.formatTimeToAndFrom(
                                    recentTasksList[index].startTime,
                                    recentTasksList[index].endTime))
                                : null,
                            leading: Icon(FontAwesomeIcons.dotCircle,
                                color: kTasksDateIconColor2),
                            trailing: Text(recentTasksList[index].duration),
                          ),
                          expanded: recentTasksList[index].expandedTasks != null
                              ? recentTasksList[index].expandedTasks.length <=
                                      20
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: recentTasksList[index]
                                                  .expandedTasks !=
                                              null
                                          ? (recentTasksList[index]
                                              .expandedTasks
                                              .length)
                                          : 0,
                                      itemBuilder:
                                          (BuildContext context, int ind) {
                                        if (ind >=
                                            recentTasksList[index]
                                                .expandedTasks
                                                .length)
                                          return SizedBox(
                                            width: 0.0,
                                          );
                                        return ListTile(
                                            leading: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Icon(
                                                  FontAwesomeIcons.dotCircle,
                                                  size: 20.0,
                                                  color: Colors.blue[700]),
                                            ),
                                            title: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text(
                                                recentTasksList[index]
                                                    .expandedTasks[ind],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                            ));
                                      })
                                  : Container()
                              : Container(),
                          theme: ExpandableThemeData(
                              iconColor: Colors.blue[700],
                              iconPadding:
                                  EdgeInsets.all(kMainDefaultHeightPadding)),
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
