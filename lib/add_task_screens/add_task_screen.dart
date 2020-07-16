import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/home_screens/main_home_screen.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

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
        title: Text(kAppName,
            textAlign: TextAlign.center, style: kAppBarTextStyle),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: kMainDefaultHeightPadding),
            child: Row(
              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.center, // This is needed
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    'images/timmi_5.png',
                    fit: BoxFit.contain,
                  ),
                )),
                Flexible(
                  child: Text(
                    'Choose how you want to calculate your time',
                    softWrap: true,
                    style: kTitleTextStyle.copyWith(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
