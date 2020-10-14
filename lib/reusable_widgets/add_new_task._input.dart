import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/models/task.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

class AddNewTaskInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController durationController;
  final bool includeStartEndDate;
  final Function onStartDateChanged;
  final String startDateText;
  final Function onEndDateChanged;
  final String endDateText;
  final String errorText;
  final Function onDurationDateChanged;
  final String durationText;
  final List previousTasks;
  final Function onTaskNameSubmitted;
  final Function onTaskDurationSubmitted;
  final Function onFilterItems;
  final Function resetTime;
  final MaskTextInputFormatter maskTextInputFormatter;

  AddNewTaskInputWidget(
      {this.nameController,
      this.durationController,
      this.onTaskNameSubmitted,
      this.includeStartEndDate,
      this.onTaskDurationSubmitted,
      this.errorText,
      this.previousTasks,
      this.onFilterItems,
      this.onStartDateChanged,
      this.startDateText,
      this.onEndDateChanged,
      this.endDateText,
      this.onDurationDateChanged,
      this.resetTime,
      this.durationText,
      this.maskTextInputFormatter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      padding: EdgeInsets.all(kMainDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoCompleteTextField<Task>(
            suggestions: previousTasks,
            style: kInputAddTaskLabelTextStyle,
            itemFilter: (Task item, query) {
              return item.taskName
                  .toLowerCase()
                  .startsWith(query.toLowerCase());
            },
            controller: nameController,
            decoration: InputDecoration(
              labelStyle: kInputAddTaskLabelTextStyle,
              hintText: 'Task Name',
            ),
            clearOnSubmit: false,
            itemBuilder: (BuildContext context, Task suggestion) {
              return Padding(
                  padding: EdgeInsets.all(kMainDefaultPadding),
                  child: Text(
                    suggestion.taskName,
                    style: kInputAddTaskLabelTextStyle.copyWith(
                        fontSize: 12.0, color: Colors.black),
                  ));
            },
            itemSorter: (Task a, Task b) {
              return a.taskName.compareTo(b.taskName);
            },
            itemSubmitted: (Task data) {
              onTaskNameSubmitted(data.taskName);
              if (data is DurationTask) {
                DurationTask temp = data;
                onTaskDurationSubmitted(temp);
              }
            },
            key: GlobalKey<AutoCompleteTextFieldState<Task>>(),
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
            visible: !includeStartEndDate ?? false,
            child: TextField(
              onChanged: onDurationDateChanged,
              controller: durationController,
              style: kInputAddTaskLabelTextStyle,
              maxLength: 5,
              inputFormatters: [maskTextInputFormatter],
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                errorText: errorText,
                prefixIcon: Icon(
                  FontAwesomeIcons.stopwatch,
                  color: kTasksDateIconColor2,
                ),
                // suffixText: 'HH:MM',
                labelStyle: kInputAddTaskLabelTextStyle,
                hintText: 'Duration in HH:MM or in minutes',
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
