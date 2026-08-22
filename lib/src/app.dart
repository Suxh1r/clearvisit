import 'package:flutter/material.dart';

import 'app_state.dart';
import 'data/clearvisit_repository.dart';
import 'notifications/notification_service.dart';
import 'screens/ai_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/health_log_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/measurement_screen.dart';
import 'screens/settings_screen.dart';

class ClearVisitApp extends StatefulWidget {
  const ClearVisitApp({
    required this.repository,
    this.notifications,
    super.key,
  });

  final ClearVisitRepository repository;
  final NotificationService? notifications;

  @override
  State<ClearVisitApp> createState() => _ClearVisitAppState();
}

class _ClearVisitAppState extends State<ClearVisitApp> {
  late final AppState state;

  @override
  void initState() {
    super.initState();
    state = AppState(widget.repository, notifications: widget.notifications)
      ..load();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        title: 'ClearVisit',
        debugShowCheckedModeBanner: false,
        themeMode: state.themeMode,
        theme: _clearVisitTheme(Brightness.light),
        darkTheme: _clearVisitTheme(Brightness.dark),
        home: HomeShell(state: state),
      ),
    );
  }

  ThemeData _clearVisitTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF02569B),
      brightness: brightness,
    );
    final scaffold = isDark ? const Color(0xFF06131F) : const Color(0xFFF4FAFF);
    final surface = isDark ? const Color(0xFF0D2233) : Colors.white;
    final surfaceVariant = isDark
        ? const Color(0xFF12324A)
        : const Color(0xFFE1F3FF);
    final outline = isDark ? const Color(0xFF284B63) : const Color(0xFFCFE8F8);
    final textColor = isDark
        ? const Color(0xFFEAF6FF)
        : const Color(0xFF0B1F33);

    return ThemeData(
      colorScheme: colors.copyWith(
        surface: surface,
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
      ),
      scaffoldBackgroundColor: scaffold,
      useMaterial3: true,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
          .apply(bodyColor: textColor, displayColor: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: surfaceVariant,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFF02569B), width: 2),
        ),
        alignLabelWithHint: true,
      ),
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
      AiScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ClearVisit',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.4),
        ),
      ),
      body: SafeArea(child: screens[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Visits'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Meds'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Log'),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart),
            label: 'Track',
          ),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
