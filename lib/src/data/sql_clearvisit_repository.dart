import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/models.dart';
import 'clearvisit_database.dart';
import 'clearvisit_repository.dart';

class SqlClearVisitRepository implements ClearVisitRepository {
  SqlClearVisitRepository(this.database);

  final ClearVisitDatabase database;

  @override
  Future<List<Appointment>> appointments() async {
    final rows = await database.db.query('appointments', orderBy: 'date ASC');
    return rows.map(Appointment.fromMap).toList();
  }

  @override
  Future<List<Medication>> medications() async {
    final rows = await database.db.query(
      'medications',
      orderBy: 'active DESC, name COLLATE NOCASE ASC',
    );
    return rows.map(Medication.fromMap).toList();
  }

  @override
  Future<List<HealthLogEntry>> healthLog() async {
    final rows = await database.db.query(
      'health_log_entries',
      orderBy: 'occurred_at DESC',
    );
    return rows.map(HealthLogEntry.fromMap).toList();
  }

  @override
  Future<List<Measurement>> measurements() async {
    final rows = await database.db.query(
      'measurements',
      orderBy: 'measured_at DESC',
    );
    return rows.map(Measurement.fromMap).toList();
  }

  @override
  Future<void> saveAppointment(Appointment value) => database.db.insert(
    'appointments',
    value.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
  Future<void> saveMedication(Medication value) => database.db.insert(
    'medications',
    value.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
  Future<void> saveHealthLogEntry(HealthLogEntry value) => database.db.insert(
    'health_log_entries',
    value.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
  Future<void> saveMeasurement(Measurement value) => database.db.insert(
    'measurements',
    value.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
  Future<String?> setting(String key) async {
    final rows = await database.db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  @override
  Future<void> saveSetting(String key, String value) => database.db.insert(
    'settings',
    {'key': key, 'value': value},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
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
