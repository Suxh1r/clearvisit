import 'package:flutter/material.dart';

import 'app.dart';
import 'data/carecue_database.dart';
import 'data/sql_carecue_repository.dart';
import 'notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await CareCueDatabase.open();
  final repository = SqlCareCueRepository(database);
  final notifications = NotificationService();
  await notifications.init();
  runApp(CareCueApp(repository: repository, reminders: notifications));
}
