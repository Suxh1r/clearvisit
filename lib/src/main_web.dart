import 'package:flutter/material.dart';

import 'app.dart';
import 'data/browser_clearvisit_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = BrowserClearVisitRepository();
  runApp(ClearVisitApp(repository: repository));
}
