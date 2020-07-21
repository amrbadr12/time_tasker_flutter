import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share/social_share.dart';
import 'package:time_tasker/add_task_screens/add_duration_task.dart';
import 'package:time_tasker/add_task_screens/add_start_end_task.dart';
import 'package:time_tasker/add_task_screens/add_task_screen.dart';
import 'package:time_tasker/constants.dart';
import 'package:time_tasker/providers/home_screen_provider.dart';
import 'package:time_tasker/reusable_widgets/main_screen_reusable_tab.dart';
import 'package:time_tasker/reusable_widgets/no_tasks_today.dart';
import 'package:time_tasker/settings_screen.dart';
import 'package:time_tasker/utils/dialog_utils.dart';
import 'package:time_tasker/utils/shared_preferences_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  final TaskTypes defaultTaskType;

  HomeScreen(this.defaultTaskType);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPerferencesUtils _sharedPreferences;
  bool _showResetDialog = false;
  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenProvider(
          DBHelper(), widget.defaultTaskType, DeviceCalendarPlugin(),
          (events) async {
//        final result =
//            await DialogUtils.showTasksFromCalendarDialog(context, events);
//        if (result) {
//          await Navigator.of(context).push(MaterialPageRoute(
//              builder: (context) => AddStartEndTaskScreen(
//                    prefillCalendarEvent: events,
//                  )));
//        }
//        return result;
      }, (data) async {
//        return await DialogUtils.showAvailableCalendarsDialog(context, data);
      }, () {
//        DialogUtils.showCalendarTasksNotFoundDialog(context);
      }),
      child: Consumer<HomeScreenProvider>(builder: (context, snapshot, _) {
        return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidClock,
                    color: Colors.blueGrey[700],
                    size: 15.0,
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingsScreen()));
                    getSharedPrefs();
                  },
                ),
//                snapshot.selectedTask == TaskTypes.StartEndTasks
//                    ? IconButton(
//                        icon: Icon(
//                          FontAwesomeIcons.calendar,
//                          color: Colors.blueGrey[700],
//                          size: 15.0,
//                        ),
//                        padding: EdgeInsets.all(0.0),
//                        onPressed: () async {
//                          await snapshot.getDefaultCalendar(repeat: false);
//                        })
//                    : SizedBox(
//                        width: 0.0,
//                      ),
//                FlatButton(
//                  child: Text(
//                    'TT',
//                    style: kAppBarTextStyle.copyWith(
//                        color: Colors.blue[700], fontSize: 16.0),
//                  ),
//                  textColor: Colors.lightBlue,
//                  onPressed: () async {
//                    await Navigator.of(context)
//                        .push(MaterialPageRoute(
//                            builder: (context) => AddTaskScreen(
//                                  navigateToHome: false,
//                                  durationTotalTime: snapshot.durationTotalTime,
//                                )))
//                        .then((onValue) {
//                      try {
//                        if (snapshot != null) snapshot.refreshMainScreen();
//                      } catch (e) {}
//                    });
//                  },
//                ),
              ],
              centerTitle: true,
              title: FlatButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => AddTaskScreen(
                                navigateToHome: false,
                                durationTotalTime: snapshot.durationTotalTime,
                              )))
                      .then((onValue) {
                    try {
                      if (snapshot != null) snapshot.refreshMainScreen();
                    } catch (e) {}
                  });
                },
                child: Text(kAppName,
                    textAlign: TextAlign.center, style: kAppBarTextStyle),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                snapshot.onTaskAddButtonTap(() async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AddDurationTask(snapshot.durationTotalTime)));
                  snapshot.refreshMainScreen();
                }, () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddStartEndTaskScreen(
                            totalDurationTime: snapshot.startEndTotalTime,
                          )));
                  snapshot.refreshMainScreen();
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
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
                  title: Text('Time Remaining'),
                ),
              ],
              currentIndex: snapshot.currentBottomNavBarIndex,
              onTap: (value) {
                snapshot.onBottomNavBarTap(
                    value,
                    _showResetDialog
                        ? () {
                            DialogUtils.showResetTasksDialog(
                                snapshot.selectedTaskType, context, () {
                              snapshot.deleteAllTodaysTasksForTaskType();
                            });
                          }
                        : () {});
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
                                DialogUtils.showResetTasksDialog(
                                    snapshot.selectedTaskType, context, () {
                                  snapshot.deleteAllTodaysTasksForTaskType();
                                });
                              });
                            },
                            onShareToWhatsApp: () async {
                              print(
                                  'whatsapp list is ${snapshot.getShareableWhatsAppList()}');
                              print(await SocialShare
                                  .checkInstalledAppsForShare());
                              SocialShare.shareWhatsapp(
                                  snapshot.getShareableWhatsAppList());
                              //_launchURL(snapshot.getShareableWhatsAppList());
                            },
                            circularCenterText:
                                snapshot.currentTabModel.circularCenterText,
                            circlePercent:
                                snapshot.currentTabModel.circlePercent,
                            recentTasksList: snapshot.recentTasks,
                            onTaskDelete: snapshot.onTaskDelete,
                            onAddButtonTap: () {
                              snapshot.onTaskAddButtonTap(() async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => AddDurationTask(
                                            snapshot.durationTotalTime)));
                                snapshot.refreshMainScreen();
                              }, () async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddStartEndTaskScreen(
                                              totalDurationTime:
                                                  snapshot.startEndTotalTime,
                                            )));
                                snapshot.refreshMainScreen();
                              });
                            })));
      }),
    );
  }

  void getSharedPrefs() async {
    _sharedPreferences =
        SharedPerferencesUtils(await SharedPreferences.getInstance());
    setState(() {
      _showResetDialog = _sharedPreferences
          .getBoolFromSharedPreferences(kResetDialogSettingsOption);
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        final bool nativeAppLaunchSucceeded =
            await launch(url, forceSafariVC: false, universalLinksOnly: true);
        if (nativeAppLaunchSucceeded != null) {
          if (!nativeAppLaunchSucceeded) {
            await launch(url, forceSafariVC: true);
          }
        }
      } else {
        await launch(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }
}
