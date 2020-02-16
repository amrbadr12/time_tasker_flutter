import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

class AddTaskScreen extends StatefulWidget {
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
                      cardText: 'Use Start And End Dates',
                      color: Colors.grey[700],
                      iconData: FontAwesomeIcons.clock,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddStartEndTaskScreen()));
                      },
                    ),
                    SizedBox(
                      width: kTitleDefaultPaddingHorizontal,
                    ),
                    AddTaskReusableCard(
                      cardText: 'Use Duration',
                      color: Colors.grey[600],
                      iconData: FontAwesomeIcons.stopwatch,
                      onTap: () {
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
