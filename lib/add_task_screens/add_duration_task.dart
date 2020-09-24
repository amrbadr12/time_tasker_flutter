import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/providers/add_new_task_provider.dart';
import 'package:time_tasker/reusable_widgets/add_new_task._input.dart';
import 'package:time_tasker/utils/dialog_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';

import '../constants.dart';

class AddDurationTask extends StatefulWidget {
  final List totalDurationTime;
  AddDurationTask(this.totalDurationTime);
  @override
  _AddDurationTaskState createState() => _AddDurationTaskState();
}

class _AddDurationTaskState extends State<AddDurationTask> {
  MaskTextInputFormatter mask;
  TextEditingController _multiplesController = TextEditingController();
  @override
  void initState() {
    mask = MaskTextInputFormatter(mask: '##:##');
    super.initState();
  }

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
                        TaskTypes.DurationTasks,
                        TextEditingController(),
                        TextEditingController(),
                        null,
                        ExpandableController(),
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
                                'Add the duration\nof your task',
                                softWrap: true,
                                style: kTitleTextStyle.copyWith(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          AddNewTaskInputWidget(
                            includeStartEndDate: false,
                            maskTextInputFormatter: mask,
                            nameController: snapshot.nameController,
                            durationController: snapshot.durationController,
                            previousTasks: snapshot.previousTasks,
                            onTaskNameSubmitted: (String data) {
                              snapshot.onTaskNameSubmitted(data);
                            },
                            onTaskDurationSubmitted: (DurationTask date) {
                              snapshot.onDurationSubmitted(date);
                            },
                            onDurationDateChanged: (String date) {
                              snapshot.setPickedDuration(date);
                            },
                            errorText: snapshot.errorText,
                            durationText: snapshot.getDuration(),
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
                                      sharedPreferencesUtils:
                                          SharedPerferencesUtils(
                                              await SharedPreferences
                                                  .getInstance()),
                                      onSuccess: () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      },
                                      onExceedTimeFrameDialog: (errorText) {
                                        DialogUtils.showDurationExceedDialog(
                                            context, errorText);
                                      });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: kMainDefaultPadding,
                          ),
                          Divider(
                            height: 1.0,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: kMainDefaultPadding,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: kMainDefaultPadding),
                              child: TextField(
                                style: kInputAddTaskLabelTextStyle,
                                controller: _multiplesController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  suffix: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      FontAwesomeIcons.check,
                                      color: Colors.blue,
                                      size: 15,
                                    ),
                                    onPressed: () {
                                      snapshot.setMultipleTimes(
                                          _multiplesController.text.trim());
                                    },
                                  ),
                                  hintText: 'Multiples times of the same task',
                                  hintStyle: kInputAddTaskLabelTextStyle,
                                ),
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: kMainDefaultPadding),
                              child: ExpandablePanel(
                                  theme: ExpandableThemeData(
                                      expandIcon: Icons.visibility,
                                      collapseIcon: Icons.visibility_off,
                                      iconColor: Colors.red,
                                      iconPadding: EdgeInsets.all(0.0),
                                      iconSize: 16.0),
                                  header: Text(
                                    'Multiple Tasks',
                                    style: kInputAddTaskLabelTextStyle.copyWith(
                                        color: Colors.black),
                                  ),
                                  controller: snapshot.expandableController,
                                  expanded: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.expandedTasks.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          title: TextFormField(
                                            decoration: InputDecoration(),
                                            controller: snapshot
                                                .expandedTasks[index].task,
                                          ),
                                          // trailing: IconButton(
                                          //   icon: Icon(
                                          //     snapshot
                                          //         .expandedTasks[index].icon,
                                          //     color: Colors.lightBlue,
                                          //     size: 15.0,
                                          //   ),
                                          //   onPressed: () {
                                          //     //snapshot.addNewExpandedTask();
                                          //     snapshot.expandedTasks[index]
                                          //         .addOrRemoveTask();
                                          //   },
                                          // ),
                                        );
                                      }))),
                          SizedBox(
                            height: kMainDefaultPadding,
                          ),
                        ],
                      );
                    })))));
  }
}
