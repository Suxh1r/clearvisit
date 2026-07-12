import 'package:flutter/material.dart';

String shortDate(DateTime value) =>
    '${value.month}/${value.day}/${value.year}';

String formatTimeOfDay(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.period == DayPeriod.am ? 'AM' : 'PM'}';
}

/// Converts a [TimeOfDay] to a 24-hour "HH:mm" storage string.
String timeToStorage(TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

/// Parses a 24-hour "HH:mm" storage string, or null if invalid.
TimeOfDay? timeFromStorage(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.icon, required this.title, required this.body, super.key});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ScreenIntro extends StatelessWidget {
  const ScreenIntro({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}

class TextEntry extends StatelessWidget {
  const TextEntry({required this.controller, required this.label, this.lines = 1, super.key});

  final TextEditingController controller;
  final String label;
  final int lines;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          maxLines: lines,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
        ),
      );
}

