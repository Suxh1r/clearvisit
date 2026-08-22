import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/data/clearvisit_database.dart';
import 'src/data/clearvisit_repository.dart';
import 'src/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await ClearVisitDatabase.open();
  final repository = ClearVisitRepository(database);
  final notifications = NotificationService();
  await notifications.init();
  runApp(ClearVisitApp(repository: repository, notifications: notifications));
}
