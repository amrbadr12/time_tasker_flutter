import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsHelper {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  NotificationDetails _platformChannelSpecifics;
  static LocalNotificationsHelper _localNotificationsHelper;

  static LocalNotificationsHelper getInstance(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      {Function(String) onSelectedNotifications}) {
    if (_localNotificationsHelper == null) {
      _localNotificationsHelper = LocalNotificationsHelper._(
          flutterLocalNotificationsPlugin, onSelectedNotifications);
    }
    return _localNotificationsHelper;
  }

  LocalNotificationsHelper._(this._flutterLocalNotificationsPlugin,
      Function(String) onSelectedNotification) {
    _platformChannelSpecifics = NotificationDetails(
        AndroidNotificationDetails(
          'time_tasker_1',
          'time_tasker',
          'time_tasker_1',
          importance: Importance.Max,
          priority: Priority.High,
          ongoing: false,
          playSound: true,
        ),
        IOSNotificationDetails());
    _initLocalNotificationsPlugin(onSelectNotification: onSelectedNotification);
  }

  void _initLocalNotificationsPlugin({Function onSelectNotification}) async {
    if (onSelectNotification == null) onSelectNotification = (payload) {};
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) {
          return;
        });

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  scheduleNotification({
    @required DateTime dateTime,
    @required String scheduledTitle,
    @required String scheduledBody,
  }) async {
    if (dateTime == null || scheduledTitle == '' || scheduledBody == '') return;
    await _flutterLocalNotificationsPlugin.schedule(
        0, scheduledTitle, scheduledBody, dateTime, _platformChannelSpecifics);
    print('scheduled');
  }

  cancelAllNotifications() {
    _flutterLocalNotificationsPlugin.cancelAll();
  }

  cancelANotifications(int id) {
    _flutterLocalNotificationsPlugin.cancel(id);
  }
}
