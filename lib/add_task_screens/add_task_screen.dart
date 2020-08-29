import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/home_screens/main_home_screen.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

import '../settings_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final bool navigateToHome;
  final durationTotalTime;
  AddTaskScreen({this.navigateToHome, this.durationTotalTime});
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
        title: Text('Choose a task type',
            textAlign: TextAlign.center, style: kAppBarTextStyle),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.solidClock,
              color: Colors.blueGrey[700],
              size: 15.0,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: kMainDefaultHeightPadding),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset(
                  'images/timmi_5.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: kMainDefaultHeightPadding),
              child: Column(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AddTaskReusableCard(
                    cardText: 'Duration',
                    color: Colors.white70,
                    iconData: FontAwesomeIcons.stopwatch,
                    onTap: () {
                      widget.navigateToHome
                          ? Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(TaskTypes.DurationTasks)),
                              (route) => false)
                          : Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  AddDurationTask(widget.durationTotalTime)));
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  AddTaskReusableCard(
                    cardText: 'Start and End Times',
                    color: Colors.white70,
                    iconData: FontAwesomeIcons.clock,
                    onTap: () {
                      widget.navigateToHome
                          ? Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(TaskTypes.StartEndTasks)),
                              (route) => false)
                          : Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddStartEndTaskScreen()));
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
