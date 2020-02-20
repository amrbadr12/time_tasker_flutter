import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/add_task_screens/add_task_screen.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/providers/home_screen_provider.dart';
import 'package:time_tasker/reusable_widgets/main_screen_reusable_tab.dart';
import 'package:time_tasker/reusable_widgets/no_tasks_today.dart';
import 'package:time_tasker/settings_screen.dart';
import 'package:time_tasker/utils/dialog_utils.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  final TaskTypes defaultTaskType;
  HomeScreen(this.defaultTaskType);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          HomeScreenProvider(DBHelper(), widget.defaultTaskType),
      child: Consumer<HomeScreenProvider>(builder: (context, snapshot, _) {
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  FontAwesomeIcons.solidClock,
                  color: Colors.blueGrey[700],
                  size: 15.0,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsScreen()));
                },
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'TT',
                    style: kAppBarTextStyle.copyWith(
                        color: Colors.blue[700], fontSize: 16.0),
                  ),
                  textColor: Colors.lightBlue,
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => AddTaskScreen(false)))
                        .then((onValue) {
                      try {
                        if (snapshot != null) snapshot.refreshMainScreen();
                      } catch (e) {}
                    });
                  },
                ),
              ],
              centerTitle: true,
              title: Text(kAppName,
                  textAlign: TextAlign.center, style: kAppBarTextStyle),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: kMainBlueColor,
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
                snapshot.onBottomNavBarTap(value, () {
                  DialogUitls.showResetTasksDialog(
                      snapshot.selectedTaskType, context, () {
                    snapshot.displayResetDialog(() {
                      DialogUitls.showResetTasksDialog(
                          snapshot.selectedTaskType, context, () {
                        snapshot.deleteAllTodaysTasksForTaskType();
                      });
                    });
                  });
                });
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
                            onReset: () {
                              snapshot.displayResetDialog(() {
                                DialogUitls.showResetTasksDialog(
                                    snapshot.selectedTaskType, context, () {
                                  snapshot.deleteAllTodaysTasksForTaskType();
                                });
                              });
                            },
                            circularCenterText:
                                snapshot.currentTabModel.circularCenterText,
                            circlePercent:
                                snapshot.currentTabModel.circlePercent,
                            recentTasksList: snapshot.recentTasks,
                            onTaskDelete: snapshot.onTaskDelete,
                            onAddButtonTap: () {
                              snapshot.onTaskAddButtonTap(() {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddDurationTask()));
                              }, () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AddStartEndTaskScreen()));
                              });
                            })));
      }),
    );
  }
}
