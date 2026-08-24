import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/entry_fields.dart';

class HealthLogScreen extends StatelessWidget {
  const HealthLogScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => Column(
      children: [
        const ScreenIntro(
          title: 'Health log',
          body:
              'Write down what happened and flag anything you want to mention at your next visit.',
        ),
        Expanded(
          child: state.healthLog.isEmpty
              ? const EmptyState(
                  icon: Icons.edit_note,
                  title: 'Your log is empty',
                  body:
                      'Add a short note whenever something feels worth remembering.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  children: state.healthLog
                      .map(
                        (value) => SummaryCard(
                          icon: value.flagged
                              ? Icons.flag_outlined
                              : Icons.notes_outlined,
                          title: value.text,
                          subtitle:
                              '${weekdayName(value.occurredAt)}, ${shortDate(value.occurredAt)}${value.flagged ? ' • Raise at next visit' : ''}',
                        ),
                      )
                      .toList(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton.icon(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: const Text('Add log entry'),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _add(BuildContext context) async {
    final text = TextEditingController();
    var occurredAt = DateTime.now();
    var flagged = false;
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('New log entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DateDropdownEntry(
                    value: occurredAt,
                    label: 'When did this happen?',
                    yearCount: 3,
                    onChanged: (value) =>
                        setDialogState(() => occurredAt = value),
                  ),
                  TextEntry(
                    controller: text,
                    label: 'What do you want to remember?',
                    lines: 4,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: flagged,
                    onChanged: (value) =>
                        setDialogState(() => flagged = value ?? false),
                    title: const Text('Raise at my next visit'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
      if (saved == true && text.text.trim().isNotEmpty) {
        await state.addLog(
          HealthLogEntry(
            id: newId(),
            occurredAt: occurredAt,
            text: text.text.trim(),
            flagged: flagged,
          ),
        );
      }
    } finally {
      text.dispose();
    }
  }
}
