 import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/reusable_widgets/add_task_reusable_cards.dart';


class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title:Text('Choose Method',style:kAppBarTextStyle),),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical:50.0),
            child: Center(child:Text('Choose How To Calculate The Time',textAlign:TextAlign.center
            ,style:kTitleTextStyle.copyWith(color:Colors.grey[800],fontWeight: FontWeight.bold,
            fontSize:30.0)),),
          ),
          Padding(
            padding: EdgeInsets.all(kMainDefaultHeightPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AddTaskReusableCard(cardText:'Use Start And End Dates',color:Colors.grey[700],iconData:FontAwesomeIcons.clock,
                onTap:(){
                  Navigator.of(context).push(MaterialPageRoute(builder:(context)=>AddStartEndTaskScreen()));
                },),
                SizedBox(width:kTitleDefaultPaddingHorizontal,),
                AddTaskReusableCard(cardText:'Use Duartion',color:Colors.grey[600],
                iconData:FontAwesomeIcons.stopwatch,
                onTap:(){
                  Navigator.of(context).push(MaterialPageRoute(builder:(context)=>AddDurationTask()));
                },)
            ],),
          )
        ],
      ),
    );
  }
}