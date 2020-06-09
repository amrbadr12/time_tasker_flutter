import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/providers/add_new_task_provider.dart';
import 'package:time_tasker/reusable_widgets/add_new_task._input.dart';
import 'package:time_tasker/utils/app_utils.dart';
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
                            previousTasks: snapshot.previousTasks,
                            onTaskNameSubmitted: (String data) {
                              snapshot.onTaskNameSubmitted(data);
                            },
                            onDurationDateChanged: (value) {
                              snapshot.setPickedDuration(value);
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
                                        AppUtils.showFlushBar(
                                            'Success',
                                            'Your Task was added successfully!',
                                            context);
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
                              child: ExpandablePanel(
                                  theme: ExpandableThemeData(
                                      expandIcon: FontAwesomeIcons.plus,
                                      collapseIcon: FontAwesomeIcons.minus,
                                      iconColor: Colors.lightBlue,
                                      iconPadding: EdgeInsets.all(0.0),
                                      iconSize: 14.0),
                                  header: Text(
                                    'Add more than one task of this type',
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
                                          trailing: IconButton(
                                            icon: Icon(
                                              snapshot
                                                  .expandedTasks[index].icon,
                                              color: Colors.lightBlue,
                                              size: 15.0,
                                            ),
                                            onPressed: () {
                                              //snapshot.addNewExpandedTask();
                                              snapshot.expandedTasks[index]
                                                  .addOrRemoveTask();
                                            },
                                          ),
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
