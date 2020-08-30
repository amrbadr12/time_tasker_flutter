import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

class AddTaskReusableCard extends StatelessWidget {
  final IconData iconData;
  final String cardText;
  final Color color;
  final Function onTap;

  AddTaskReusableCard({this.iconData, this.cardText, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: blueGradient),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                size: MediaQuery.of(context).size.width * 0.1,
                color: color,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Flexible(
                child: Text(
                  cardText,
                  style: kAppBarTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateInputField extends StatelessWidget {
  final Icon icon;
  final String text;
  final Color containerColor;
  final Function onDateChanged;
  DateInputField(
      {this.icon, this.text, this.onDateChanged, this.containerColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0.0),
      title: Text(
        text,
        style: kSubTitleTextStyle,
      ),
      leading: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: 30.0,
        height: 30.0,
        child: Center(child: icon),
      ),
      onTap: onDateChanged,
    );
  }
}
