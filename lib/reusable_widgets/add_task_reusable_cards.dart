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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2.0,
          child: Container(
            height: 300.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  size: 100,
                  color: color,
                ),
                SizedBox(
                  height: kMainDefaultPadding,
                ),
                Text(
                  cardText,
                  style: kSubTitleTextStyle,
                  textAlign: TextAlign.center,
                  softWrap: true,
                )
              ],
            ),
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
  DateInputField({this.icon,this.text,this.onDateChanged,this.containerColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0.0),
      title:Text(text,style:kSubTitleTextStyle,),
      leading:Container(
        decoration:BoxDecoration(
          color:containerColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        width:30.0,
        height:30.0,
        child:Center(child: icon),
      ),
      onTap:onDateChanged,
    );
  }
}
