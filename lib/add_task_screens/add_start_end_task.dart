import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/providers/add_new_task_provider.dart';
import 'package:time_tasker/reusable_widgets/add_new_task._input.dart';
import 'package:time_tasker/utils/app_utils.dart';

import '../constants.dart';

class AddStartEndTaskScreen extends StatefulWidget {
  @override
  _AddStartEndTaskScreenState createState() => _AddStartEndTaskScreenState();
}

class _AddStartEndTaskScreenState extends State<AddStartEndTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
            child: Container(
                child: ChangeNotifierProvider<AddNewTaskProvider>(
                    create: (context) => AddNewTaskProvider(DBHelper(),
                        TaskTypes.StartEndTasks, TextEditingController()),
                    child: Consumer<AddNewTaskProvider>(
                        builder: (context, snapshot, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: kMainDefaultPadding),
                              child: Text(
                                'Create\nnew task\nby adding a start and end time',
                                softWrap: true,
                                style: kTitleTextStyle.copyWith(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          AddNewTaskInputWidget(
                            includeStartEndDate: true,
                            nameController: snapshot.nameController,
                            previousTasks: snapshot.previousTasks,
                            onTaskNameSubmitted: (String data) {
                              snapshot.onTaskNameSubmitted(data);
                            },
                            onStartDateChanged: () async {
                              snapshot.setPickedStartTime(
                                  await AppUtils.showTimePickerDialog(context));
                            },
                            startDateText: snapshot.getStartTime(),
                            onEndDateChanged: () async {
                              snapshot.setPickedEndTime(
                                  await AppUtils.showTimePickerDialog(context));
                            },
                            endDateText: snapshot.getEndTime(),
                            durationText: snapshot.getCalculatedDuration(),
                            resetTime: () {
                              snapshot.resetTime();
                            },
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: kMainDefaultPadding),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  gradient:
                                      LinearGradient(colors: blueGradient)),
                              width: double.infinity,
                              child: FlatButton(
                                child: Text('Add Task',
                                    style: kAppBarTextStyle.copyWith(
                                        color: Colors.white)),
                                onPressed: () {
                                  snapshot.addNewTaskToDB(() {
                                     Navigator.of(context).popUntil((route)=>route.isFirst);
                                    AppUtils.showFlushBar(
                                        'Success',
                                        'Your Task was added successfully!',
                                        context);
                                  },(){
                                     AppUtils.showFlushBar(
                                        'Task Already Exists',
                                        'Your already have a task set between this period.',
                                        context);
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    })))));
  }
}
