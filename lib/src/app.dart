import 'package:flutter/material.dart';

import 'app_state.dart';
import 'data/clearvisit_repository.dart';
import 'screens/appointment_screen.dart';
import 'screens/health_log_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/measurement_screen.dart';
import 'screens/settings_screen.dart';

class ClearVisitApp extends StatefulWidget {
  const ClearVisitApp({required this.repository, super.key});

  final ClearVisitRepository repository;

  @override
  State<ClearVisitApp> createState() => _ClearVisitAppState();
}

class _ClearVisitAppState extends State<ClearVisitApp> {
  late final AppState state;

  @override
  void initState() {
    super.initState();
    state = AppState(widget.repository)..load();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearVisit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF146C60),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
      home: HomeShell(state: state),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({required this.state, super.key});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      AppointmentScreen(state: widget.state),
      MedicationScreen(state: widget.state),
      HealthLogScreen(state: widget.state),
      MeasurementScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClearVisit'),
        centerTitle: false,
      ),
      body: SafeArea(child: screens[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Visits'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Meds'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.monitor_heart), label: 'Track'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

