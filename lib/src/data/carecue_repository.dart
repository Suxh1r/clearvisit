import '../models/models.dart';

abstract interface class CareCueRepository {
  Future<List<Appointment>> appointments();

  Future<List<Medication>> medications();

  Future<List<HealthLogEntry>> healthLog();

  Future<List<Measurement>> measurements();

  Future<void> saveAppointment(Appointment value);

  Future<void> saveMedication(Medication value);

  Future<void> saveHealthLogEntry(HealthLogEntry value);

  Future<void> saveMeasurement(Measurement value);

  Future<void> deleteAppointment(String id);

  Future<void> deleteMedication(String id);

  Future<void> deleteHealthLogEntry(String id);

  Future<void> deleteMeasurement(String id);

  Future<String?> setting(String key);

  Future<void> saveSetting(String key, String value);

  Future<void> deleteEverything();
}
