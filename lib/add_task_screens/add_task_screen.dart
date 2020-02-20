import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/home_screens/main_home_screen.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

class AddTaskScreen extends StatefulWidget {
  final bool navigateToHome;
  AddTaskScreen(this.navigateToHome);
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
//      appBar: AppBar(
//        centerTitle: true,
//        backgroundColor: appBarColor,
//        title:Text('Choose Method',style:kAppBarTextStyle),),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kMainDefaultPadding),
              child: Text(
                'Choose\nHow To Calculate The Time',
                softWrap: true,
                style: kTitleTextStyle.copyWith(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              )),
          Expanded(
            child: Align(
              alignment:Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:kMainDefaultHeightPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    AddTaskReusableCard(
                      cardText: 'Start And End Dates',
                      color: Colors.white70,
                      iconData: FontAwesomeIcons.clock,
                      onTap: () {
                        widget.navigateToHome?
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                            builder: (context) => HomeScreen(TaskTypes.StartEndTasks)),(route)=>false):
                            Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddStartEndTaskScreen()));
                      },
                    ),
                    SizedBox(
                      width: kTitleDefaultPaddingHorizontal,
                    ),
                    AddTaskReusableCard(
                      cardText: 'Duration',
                      color: Colors.white70,
                      iconData: FontAwesomeIcons.stopwatch,
                      onTap: () {
                        widget.navigateToHome?
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                            builder: (context) => HomeScreen(TaskTypes.DurationTasks)),(route)=>false):
                            Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddDurationTask()));
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
