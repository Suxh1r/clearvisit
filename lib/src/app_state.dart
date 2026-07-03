import 'package:flutter/foundation.dart';

import 'data/clearvisit_repository.dart';
import 'models/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final ClearVisitRepository repository;
  bool loading = true;
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
    ]);
    appointments = values[0] as List<Appointment>;
    medications = values[1] as List<Medication>;
    healthLog = values[2] as List<HealthLogEntry>;
    measurements = values[3] as List<Measurement>;
    loading = false;
    notifyListeners();
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
}

