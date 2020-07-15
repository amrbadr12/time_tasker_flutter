import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

class NoTasksTodayWidget extends StatelessWidget {
  final String taskType;
  NoTasksTodayWidget({this.taskType});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Image.asset('images/timmi_2.png', width: 400, height: 400)),
        Flexible(
            child: Text(
          'No $taskType Tasks For Today',
          textAlign: TextAlign.center,
          style: kSubTitleTextStyle,
          softWrap: true,
        )),
        SizedBox(height: kMainDefaultHeightPadding),
        Flexible(
            child: Text(
          'Kickstart your day and start adding new tasks!',
          textAlign: TextAlign.center,
          softWrap: true,
          style: kSubTitleTextStyle.copyWith(color: Colors.grey[400]),
        )),
        SizedBox(height: kMainDefaultHeightPadding),
      ],
    );
  }
}
