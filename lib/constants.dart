
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TaskTypes{DurationTasks,StartEndTasks}
enum TaskAction{TotalTime,TotalBalance}

final String kAppName='TIME TASKER';
final kTitleDefaultPaddingHorizontal=20.0;
final kTitleDefaultPaddingVertical=30.0;
final TextStyle kAppBarTextStyle= GoogleFonts.lato(fontWeight:FontWeight.bold,fontSize:20.0,color:kDefaultGrey);
final TextStyle kTitleTextStyle= GoogleFonts.quicksand(fontWeight:FontWeight.w500,fontSize:25.0,color:Colors.black);
final TextStyle kSubTitleTextStyle= kTitleTextStyle.copyWith(color:Colors.grey[700],fontSize:16.0);
final TextStyle kInputAddTaskLabelTextStyle=kAppBarTextStyle.copyWith(color:Colors.grey[600],fontSize:16.0);
final List<Color> blueGradient=[Color(0xff2193b0),Color(0xff6dd5ed)];
final Color kTasksDateContainerColor=Color(0xffFEF5E6);
final Color kTasksDateIconColor1=Color(0xffF9CA76);
final Color kTasksDateIconColor2=Color(0xffF77755);
final kMainDefaultHeightPadding=15.0;
final Color appBarColor=Color(0xffE0E3E9);
final Color kDefaultGrey=Colors.grey[700];
final kMainDefaultPadding=30.0;
final kTodayText='TODAY';
final kYourTotalTimeText='Your Total Time';
final kYourTotalBalanceText='Your Total Balance';
final Color kMainBlueColor=Colors.blue[500];