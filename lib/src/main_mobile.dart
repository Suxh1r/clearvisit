import 'package:flutter/material.dart';

import 'app.dart';
import 'data/clearvisit_database.dart';
import 'data/sql_clearvisit_repository.dart';
import 'notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await ClearVisitDatabase.open();
  final repository = SqlClearVisitRepository(database);
  final notifications = NotificationService();
  await notifications.init();
  runApp(ClearVisitApp(repository: repository, reminders: notifications));
}
