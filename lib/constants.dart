import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

enum TaskTypes { DurationTasks, StartEndTasks }
enum TaskAction { TotalTime, TotalBalance }

final String kAppName = 'TimeTasker';
final String kShowIntroScreenKey = 'show_intro_screen_key';
final String kTotalBalanceHoursKey = 'total_balance_hours_key';
final String kTotalBalanceMinutesKey = 'total_balance_minutes_key';
final String kResetDialogSettingsOption = 'reset_settings_key';
final String kSavedCalendarKey = 'user_saved_calendar_key';
final String kTimeSelectedSettingsKey = 'time_selected_key';
final kTitleDefaultPaddingHorizontal = 20.0;
final kTitleDefaultPaddingVertical = 30.0;
final TextStyle kAppBarTextStyle = GoogleFonts.lato(
    fontWeight: FontWeight.bold, fontSize: 18.0, color: kDefaultGrey);
final TextStyle kTitleTextStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500, fontSize: 25.0, color: Colors.black);
final TextStyle kSubTitleTextStyle =
    kTitleTextStyle.copyWith(color: Colors.grey[700], fontSize: 16.0);
final TextStyle kInputAddTaskLabelTextStyle =
    kAppBarTextStyle.copyWith(color: Colors.grey[600], fontSize: 16.0);
final List<Color> blueGradient = [Color(0xff2193b0), Color(0xff6dd5ed)];
final Color kTasksDateContainerColor = Color(0xffFEF5E6);
final Color kTasksDateIconColor1 = Color(0xffF9CA76);
final Color kTasksDateIconColor2 = Color(0xffF77755);
final kMainDefaultHeightPadding = 15.0;
final Color appBarColor = Color(0xffE0E3E9);
final Color kDefaultGrey = Colors.grey[700];
final kMainDefaultPadding = 30.0;
final kTodayText = 'TODAY';
final kYourTotalTimeText = 'Total Time';
final kYourTotalBalanceText = 'Time Remaining';
final Color kMainBlueColor = Colors.blue[500];
final String firstTitleText =
    'Are you ever late because you underestimated how long things take?';
final String firstBodyText =
    'Select a time frame for up to 24 hours OR set a time you need to be somewhere be on time!';
final String secondTitleText =
    'You can calculate your time by using two methods.';
final String thirdBodyText = """
• Add the time you need to be
somewhere or a time period you
have; OR\n
• Use TimeTasker® as a time and task
calculator; and\n
• Add your tasks with a start and end
time OR using duration of a task;\n
• See your time used and remaining
instantly!
""";
final String thirdTitleText = 'TimeTasker® is just simple!';
final String secondBodyText =
    'Use a start and end time or the duration of your task\n\nYou can just toggle between the two!';
final String fourthTitleText = 'TimeTasker';
final String fourthBodyText = """
TimeTasker® can be used by anyone that
underestimates how much time they
have and are frequently late.\n
TimeTasker ® will help you manage your
distractions by setting out how much
time you have today based on the tasks
you record.
That’s it!\n
Lets get
TimeTasking!
""";
final String timeMoreThan24Hours = """
The duration of this task exceeds the amount of time you have available. You can not have tasks set for more than 24 hours. 

Please return to your Total Time summary without adding this task and review your Total Time, your Time Balance and tasks. 
""";
final String timeLessThan24Hours = """
The duration of this task exceeds the amount of time you have available. Please re-set your TimeTasker time frame or review your Total Time summary tasks. 
""";
final PageDecoration introPageDecoration = PageDecoration(
    titleTextStyle: kTitleTextStyle,
    bodyTextStyle: kSubTitleTextStyle,
    imagePadding: EdgeInsets.all(0),
    footerPadding: EdgeInsets.all(0),
    bodyFlex: 4,
    imageFlex: 3);
final introScreenImagesSize = 200.0;
