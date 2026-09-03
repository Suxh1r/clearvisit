import 'package:flutter/material.dart';

import 'data/clearvisit_repository.dart';
import 'models/models.dart';
import 'notifications/reminder_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository, {this.reminders});

  final ClearVisitRepository repository;
  final ReminderService? reminders;
  bool loading = true;
  ThemeMode themeMode = ThemeMode.system;
  List<Appointment> appointments = [];
  List<Medication> medications = [];
  List<HealthLogEntry> healthLog = [];
  List<Measurement> measurements = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();
    final values = await Future.wait([
      repository.appointments(),
      repository.medications(),
      repository.healthLog(),
      repository.measurements(),
      repository.setting('theme_mode'),
    ]);
    appointments = values[0] as List<Appointment>;
    medications = values[1] as List<Medication>;
    healthLog = values[2] as List<HealthLogEntry>;
    measurements = values[3] as List<Measurement>;
    themeMode = _themeModeFromName(values[4] as String?);
    loading = false;
    notifyListeners();
    await reminders?.sync(appointments, medications);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await repository.saveSetting('theme_mode', value.name);
  }

  Future<void> addAppointment(Appointment value) async {
    await repository.saveAppointment(value);
    await load();
  }

  Future<void> addMedication(Medication value) async {
    await repository.saveMedication(value);
    await load();
  }

  Future<void> addLog(HealthLogEntry value) async {
    await repository.saveHealthLogEntry(value);
    await load();
  }

  Future<void> addMeasurement(Measurement value) async {
    await repository.saveMeasurement(value);
    await load();
  }

  Future<void> deleteEverything() async {
    await repository.deleteEverything();
    await load();
  }

  ThemeMode _themeModeFromName(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
