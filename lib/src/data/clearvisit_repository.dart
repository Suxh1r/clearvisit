import '../models/models.dart';
import 'clearvisit_database.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class ClearVisitRepository {
  ClearVisitRepository(this.database);

  final ClearVisitDatabase database;

  Future<List<Appointment>> appointments() async {
    final rows = await database.db.query('appointments', orderBy: 'date ASC');
    return rows.map(Appointment.fromMap).toList();
  }

  Future<List<Medication>> medications() async {
    final rows = await database.db.query(
      'medications',
      orderBy: 'active DESC, name COLLATE NOCASE ASC',
    );
    return rows.map(Medication.fromMap).toList();
  }

  Future<List<HealthLogEntry>> healthLog() async {
    final rows = await database.db.query(
      'health_log_entries',
      orderBy: 'occurred_at DESC',
    );
    return rows.map(HealthLogEntry.fromMap).toList();
  }

  Future<List<Measurement>> measurements() async {
    final rows = await database.db.query(
      'measurements',
      orderBy: 'measured_at DESC',
    );
    return rows.map(Measurement.fromMap).toList();
  }

  Future<void> saveAppointment(Appointment value) => database.db.insert(
        'appointments',
        value.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveMedication(Medication value) => database.db.insert(
        'medications',
        value.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveHealthLogEntry(HealthLogEntry value) => database.db.insert(
        'health_log_entries',
        value.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveMeasurement(Measurement value) => database.db.insert(
        'measurements',
        value.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> delete(String table, String id) =>
      database.db.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<void> deleteEverything() => database.db.transaction((txn) async {
        for (final table in [
          'appointments',
          'medications',
          'health_log_entries',
          'measurements',
        ]) {
          await txn.delete(table);
        }
      });
}
