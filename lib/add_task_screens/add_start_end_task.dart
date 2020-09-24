import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/providers/add_new_task_provider.dart';
import 'package:time_tasker/reusable_widgets/add_new_task._input.dart';
import 'package:time_tasker/utils/app_utils.dart';
import 'package:time_tasker/utils/dialog_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../constants.dart';
import '../db_helper.dart';
import '../utils/dialog_utils.dart';

class AddStartEndTaskScreen extends StatefulWidget {
  final List prefillCalendarEvent;
  final List totalDurationTime;
  AddStartEndTaskScreen({this.prefillCalendarEvent, this.totalDurationTime});
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
                    create: (context) => AddNewTaskProvider(
                        DBHelper(),
                        TaskTypes.StartEndTasks,
                        TextEditingController(),
                        null,
                        widget.prefillCalendarEvent,
                        null,
                        widget.totalDurationTime),
                    child: Consumer<AddNewTaskProvider>(
                        builder: (context, snapshot, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: kMainDefaultPadding),
                              child: Text(
                                'Add task\nstart and end time',
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
                                  await AppUtils.showTimePickerDialog(context),
                                  () async {
                                snapshot.setSleepTask(
                                    await DialogUtils.showBedSleepTasksDialog(
                                        context));
                              });
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
                                onPressed: () async {
                                  snapshot.addNewTaskToDB(
                                      onSuccess: () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        // AppUtils.showFlushBar(
                                        //     'Success',
                                        //     'Your Task was added successfully!',
                                        //     context);
                                      },
                                      sharedPreferencesUtils:
                                          SharedPerferencesUtils(
                                              await SharedPreferences
                                                  .getInstance()),
                                      onOverlappingTask: () {
                                        AppUtils.showFlushBar(
                                            'Task Already Exists',
                                            'Your already have a task set between this period.',
                                            context);
                                      },
                                      onExceedTimeFrameDialog: (errorText) {
                                        DialogUtils.showDurationExceedDialog(
                                            context, errorText);
                                      },
                                      onAddingTaskToCalendar: () async =>
                                          await DialogUtils
                                              .showAddTaskToCalendarDialog(
                                                  context));
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    })))));
  }
}
