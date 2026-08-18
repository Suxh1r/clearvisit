import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class ClearVisitDatabase {
  ClearVisitDatabase._(this.db);

  final Database db;

  static const _keyName = 'clearvisit.database.key.v1';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(migrateWithBackup: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  static Future<ClearVisitDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    final key = await _getOrCreateKey();
    final database = await openDatabase(
      p.join(directory.path, 'clearvisit.db'),
      password: key,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE appointments ADD COLUMN reminder_minutes INTEGER NOT NULL DEFAULT -1',
          );
          await db.execute(
            "ALTER TABLE medications ADD COLUMN times TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE medications ADD COLUMN reminder_minutes INTEGER NOT NULL DEFAULT -1',
          );
        }
        if (oldVersion < 3) {
          await _createSettingsTable(db);
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE appointments (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            reason TEXT NOT NULL,
            provider TEXT NOT NULL,
            documents TEXT NOT NULL,
            symptoms TEXT NOT NULL,
            questions TEXT NOT NULL,
            reminder_minutes INTEGER NOT NULL DEFAULT -1
          )
        ''');
        await db.execute('''
          CREATE TABLE medications (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            strength TEXT NOT NULL,
            dose TEXT NOT NULL,
            schedule TEXT NOT NULL,
            notes TEXT NOT NULL,
            active INTEGER NOT NULL CHECK(active IN (0, 1)),
            times TEXT NOT NULL DEFAULT '',
            reminder_minutes INTEGER NOT NULL DEFAULT -1
          )
        ''');
        await db.execute('''
          CREATE TABLE health_log_entries (
            id TEXT PRIMARY KEY,
            occurred_at TEXT NOT NULL,
            text TEXT NOT NULL,
            flagged INTEGER NOT NULL CHECK(flagged IN (0, 1))
          )
        ''');
        await db.execute('''
          CREATE TABLE measurements (
            id TEXT PRIMARY KEY,
            measured_at TEXT NOT NULL,
            type TEXT NOT NULL,
            value TEXT NOT NULL,
            unit TEXT NOT NULL,
            context TEXT NOT NULL
          )
        ''');
        await _createSettingsTable(db);
      },
    );
    return ClearVisitDatabase._(database);
  }

  static Future<void> _createSettingsTable(DatabaseExecutor db) =>
      db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

  static Future<String> _getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _keyName);
    if (existing != null) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    await _secureStorage.write(key: _keyName, value: key);
    return key;
  }
}
