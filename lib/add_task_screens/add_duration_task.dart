import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:time_tasker/db_helper.dart';
import 'package:time_tasker/providers/add_new_task_provider.dart';
import 'package:time_tasker/reusable_widgets/add_new_task._input.dart';
import 'package:time_tasker/utils/app_utils.dart';

import '../constants.dart';

class AddDurationTask extends StatefulWidget {
  @override
  _AddDurationTaskState createState() => _AddDurationTaskState();
}

class _AddDurationTaskState extends State<AddDurationTask> {
  MaskTextInputFormatter mask;
  @override
  void initState() {
    mask= MaskTextInputFormatter(mask: '##:##');
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
                    create: (context) =>
                        AddNewTaskProvider(DBHelper(), TaskTypes.DurationTasks,TextEditingController()),
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
                            maskTextInputFormatter:mask,
                            nameController:snapshot.nameController,
                            previousTasks:snapshot.previousTasks,
                            onTaskNameSubmitted: (String data){
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
                                onPressed: () {
                                  snapshot.addNewTaskToDB(() {
                                    Navigator.of(context).popUntil((route)=>route.isFirst);
                                    AppUtils.showFlushBar(
                                        'Success',
                                        'Your Task was added successfully!',
                                        context);
                                  },(){});
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    })))));
  }
}
