import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:time_tasker/services/local_notifications_helper.dart';

configureDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;
  GetIt.instance.allowReassignment = true;
  getIt.registerSingleton<LocalNotificationsHelper>(
      LocalNotificationsHelper.getInstance(FlutterLocalNotificationsPlugin()));
}
