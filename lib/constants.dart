
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

enum TaskTypes{DurationTasks,StartEndTasks}
enum TaskAction{TotalTime,TotalBalance}

final String kAppName='TimeTasker';
final String kShowIntroScreenKey='show_intro_screen_key';
final String kTotalBalanceKey='total_balance_key';
final kTitleDefaultPaddingHorizontal=20.0;
final kTitleDefaultPaddingVertical=30.0;
final TextStyle kAppBarTextStyle= GoogleFonts.lato(fontWeight:FontWeight.bold,fontSize:18.0,color:kDefaultGrey);
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
final String firstTitleText='Never be late again!';
final String secondBodyText='Have you ever underestimated how long your daily chores take for you to do and then end up late to a dinner or event?';
final String secondTitleText='TimeTasker is here to help!';
final String thirdBodyText='you can manage and understand how you use your time, by two methods. You can leave the 24 hour default timer or set a certain period, like at work and then record a start or end date or how long an individual task takes.';
final String thirdTitleText=secondTitleText;
final String firstBodyText='Have you ever had a whole day flash past and you only achieved half of what you wanted to do?';
final String fourthTitleText='TimeTasker';
final String fourthBodyText='TimeTasker is a revolutionary way to put more time in your day!';
final PageDecoration introPageDecoration=
PageDecoration(titleTextStyle:kTitleTextStyle,bodyTextStyle:kSubTitleTextStyle);
final introScreenImagesSize=700.0;