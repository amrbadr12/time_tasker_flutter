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
  final List<UITask> recentTasksList;

  MainScreenReusableTab(
      {this.date,
      this.mainTitle,
      this.circularCenterText,
      this.circlePercent,
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
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: CircularPercentIndicator(
                  radius: 200.0,
                  lineWidth: 5.0,
                  percent: circlePercent,
                  animation: true,
                  animationDuration: 1200,
                  center: Text(
                    circularCenterText,
                    style: kTitleTextStyle.copyWith(color: kDefaultGrey),
                  ),
                  progressColor: blueGradient[0],
                  backgroundColor: blueGradient[1]),
            ),
          ),
          SizedBox(
            height: kMainDefaultHeightPadding,
          ),
          Divider(
            thickness: 2.0,
          ),
          WhiteReusableContainer(
            verticalMargin: kMainDefaultHeightPadding,
            horizontalMargin: kMainDefaultHeightPadding,
            containerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: kTitleDefaultPaddingVertical,
                          left: kTitleDefaultPaddingHorizontal,
                        ),
                        child: Text('Recorded Tasks', style: kSubTitleTextStyle),
                      ),
                    ),
                    FlatButton(
                        padding: EdgeInsets.symmetric(
                            vertical: kTitleDefaultPaddingVertical),
                        child: Text('View All'),
                        textColor: kMainBlueColor,
                        onPressed: () {}),
                  ],
                ),
                ListView.builder(
                    itemCount:
                        recentTasksList == null ? 2 : recentTasksList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      if (recentTasksList == null) {
                        return ListTile(
                          title: Text('General Training'),
                          subtitle: Text('Yesterday'),
                          leading: Icon(FontAwesomeIcons.dotCircle,
                              color: kMainBlueColor),
                          trailing: Text('2h 45m'),
                        );
                      } else{
                        return Dismissible(
                          onDismissed: (direction){
                            print(recentTasksList[index].id);
                            onTaskDelete(recentTasksList[index].id);
                          },
                            child: ListTile(
                            title: Text(recentTasksList[index].taskName),
                            subtitle: Text(recentTasksList[index].date),
                            leading: Icon(FontAwesomeIcons.dotCircle,
                                color:kTasksDateIconColor2),
                            trailing: Text(recentTasksList[index].duration),
                          ), key: UniqueKey(),
                        );
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
