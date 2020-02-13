import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';

class AddNewTaskInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final bool includeStartEndDate;
  final Function onStartDateChanged;
  final String startDateText;
  final Function onEndDateChanged;
  final String endDateText;
  final String errorText;
  final Function onDurationDateChanged;
  final String durationText;
  final List<String> previousTasks;
  final Function onTaskNameSubmitted;
  final Function onFilterItems;
  final Function resetTime;

  AddNewTaskInputWidget(
      {this.nameController,
      this.onTaskNameSubmitted,
      this.includeStartEndDate,
      this.errorText,
      this.previousTasks,
      this.onFilterItems,
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
          AutoCompleteTextField<String>(
            suggestions: previousTasks,
            style: kInputAddTaskLabelTextStyle,
            itemFilter: (item, query) {
              return item
                  .toLowerCase()
                  .startsWith(query.toLowerCase());
            },
            controller:nameController,
            decoration: InputDecoration(
              labelStyle: kInputAddTaskLabelTextStyle,
              hintText: 'Task Name',
            ),
            clearOnSubmit: false,
            itemBuilder: (BuildContext context, String suggestion) {
              return Padding(padding:EdgeInsets.all(kMainDefaultPadding),
                child: Text(suggestion,style:kInputAddTaskLabelTextStyle.copyWith(fontSize:12.0,color:Colors.black),));
            },
            itemSorter: (String a, String b) {
              return a.compareTo(b);
            },
            itemSubmitted: (String data) {
             onTaskNameSubmitted(data);
            },
            key: GlobalKey<AutoCompleteTextFieldState<String>>(),
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
              style: kInputAddTaskLabelTextStyle,
              maxLength: 5,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                errorText: errorText,
                prefixIcon: Icon(
                  FontAwesomeIcons.stopwatch,
                  color: kTasksDateIconColor2,
                ),
                suffixText:'HH:MM',
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
