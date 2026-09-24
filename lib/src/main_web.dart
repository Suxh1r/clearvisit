import 'package:flutter/material.dart';

import 'app.dart';
import 'data/browser_carecue_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = BrowserCareCueRepository();
  runApp(CareCueApp(repository: repository));
}
