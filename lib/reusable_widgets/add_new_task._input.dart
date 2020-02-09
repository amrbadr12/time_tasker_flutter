import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

class AddNewTaskInputWidget extends StatelessWidget {
  final Function onTaskNameChanged;
  final bool includeStartEndDate;
  final Function onStartDateChanged;
  final String startDateText;
  final Function onEndDateChanged;
  final String endDateText;
  final String errorText;
  final Function onDurationDateChanged;
  final String durationText;
  final Function resetTime;

  AddNewTaskInputWidget(
      {this.onTaskNameChanged,
      this.includeStartEndDate,
      this.errorText,
      this.onStartDateChanged,
      this.startDateText,
      this.onEndDateChanged,
      this.endDateText,
      this.onDurationDateChanged,
      this.resetTime,
      this.durationText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      padding: EdgeInsets.all(kMainDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            onChanged: onTaskNameChanged,
            style: kInputAddTaskLabelTextStyle,
            maxLength: 50,
            decoration: InputDecoration(
              labelStyle: kInputAddTaskLabelTextStyle,
              hintText: 'Task Name',
            ),
          ),
          SizedBox(
            height: kMainDefaultHeightPadding,
          ),
          Visibility(
              visible: includeStartEndDate ?? true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DateInputField(
                    icon: Icon(
                      FontAwesomeIcons.clock,
                      size: 20.0,
                      color: kTasksDateIconColor1,
                    ),
                    containerColor: kTasksDateContainerColor,
                    text: startDateText ?? 'Enter Start Time',
                    onDateChanged: onStartDateChanged,
                  ),
                  SizedBox(
                    height: kMainDefaultHeightPadding,
                  ),
                  DateInputField(
                    icon: Icon(
                      FontAwesomeIcons.solidClock,
                      size: 20.0,
                      color: kTasksDateIconColor1,
                    ),
                    containerColor: kTasksDateContainerColor,
                    text: endDateText ?? 'Enter End Time',
                    onDateChanged: onEndDateChanged,
                  ),
                  SizedBox(
                    height: kMainDefaultHeightPadding,
                  ),
                  DateInputField(
                    icon: Icon(
                      FontAwesomeIcons.stopwatch,
                      size: 20.0,
                      color: kTasksDateIconColor2,
                    ),
                    containerColor: kTasksDateContainerColor,
                    text: durationText ?? '',
                    onDateChanged: onDurationDateChanged,
                  ),
                ],
              )),
          Visibility(
            visible:!includeStartEndDate??false,
            child: TextField(
            onChanged: onDurationDateChanged,
            style: kInputAddTaskLabelTextStyle,
            maxLength: 5,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              errorText: errorText,
              prefixIcon: Icon(FontAwesomeIcons.stopwatch,color:kTasksDateIconColor2,),
              labelStyle: kInputAddTaskLabelTextStyle,
              hintText: 'Duration in HH:MM',
            ),
          ),
          ),
          Visibility(
            visible: includeStartEndDate ?? true,
            child: Align(
              alignment: Alignment.topRight,
              child: FlatButton(
                child: Text('Reset Time'),
                textColor: Colors.lightBlue,
                onPressed: resetTime,
              ),
            ),
          )
        ],
      ),
    );
  }
}
