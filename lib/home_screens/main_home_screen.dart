import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:time_tasker/add_task_screens/add_task_screen.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/providers/home_screen_provider.dart';
import 'package:time_tasker/reusable_widgets/main_screen_reusable_tab.dart';
import 'package:time_tasker/reusable_widgets/no_tasks_today.dart';
import 'package:time_tasker/settings_screen.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenProvider(DBHelper()),
      child: Consumer<HomeScreenProvider>(builder: (context, snapshot, _) {
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  FontAwesomeIcons.userCog,
                  color: Colors.blueGrey[700],
                  size: 15.0,
                ),
                onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingsScreen()));
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidCalendarPlus,
                    color: Colors.blue[700],
                    size: 15.0,
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddTaskScreen())).then((onValue){
                          snapshot.refreshMainScreen();
                        });
                  },
                ),
              ],
              centerTitle: true,
              title: Text(kAppName,
                  textAlign: TextAlign.center, style: kAppBarTextStyle),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor:kMainBlueColor,
              unselectedItemColor: kTasksDateIconColor2,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.tasks),
                  title: Text(snapshot.firstNavBarItemName),
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.solidClock),
                  title: Text('Total Time'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.stopwatch),
                  title: Text('Total Balance'),
                ),
              ],
              currentIndex: snapshot.currentBottomNavBarIndex,
              onTap: (value) {
                snapshot.onBottomNavBarTap(value);
              },
            ),
            body: Container(
                child: snapshot.noTodayTasks == null
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ))
                    : snapshot.noTodayTasks
                        ? NoTasksTodayWidget(
                            taskType: snapshot.selectedTaskType)
                        : MainScreenReusableTab(
                            date: snapshot.currentTabModel.currentDate,
                            mainTitle: snapshot.currentTabModel.mainTitle,
                            upcomingTask: snapshot.upcomingTask,
                            taskType: snapshot.selectedTaskType,
                            circularCenterText:
                                snapshot.currentTabModel.circularCenterText,
                            circlePercent:
                                snapshot.currentTabModel.circlePercent,
                            recentTasksList: snapshot.recentTasks,
                            onTaskDelete: snapshot.onTaskDelete,
                          )));
      }),
    );
  }
}
