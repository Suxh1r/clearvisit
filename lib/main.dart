import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/data/clearvisit_database.dart';
import 'src/data/clearvisit_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await ClearVisitDatabase.open();
  final repository = ClearVisitRepository(database);
  runApp(ClearVisitApp(repository: repository));
}

