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
        Expanded(
          flex: 6,
          child: Center(
              child: Image.asset(
            'images/timmi_2.png',
            width: MediaQuery.of(context).size.width * 0.85,
          )),
        ),
        Flexible(
            child: Text(
          'No $taskType Tasks For Today',
          textAlign: TextAlign.center,
          style: kSubTitleTextStyle.copyWith(
              fontSize: MediaQuery.of(context).size.width * 0.04),
          softWrap: true,
        )),
        SizedBox(height: kMainDefaultHeightPadding),
        Flexible(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: kMainDefaultPadding),
          child: Text(
            'Kickstart your day and start adding new tasks!',
            textAlign: TextAlign.center,
            softWrap: true,
            style: kSubTitleTextStyle.copyWith(
                color: Colors.grey[400],
                fontSize: MediaQuery.of(context).size.width * 0.035),
          ),
        )),
        SizedBox(height: kMainDefaultHeightPadding),
      ],
    );
  }
}
