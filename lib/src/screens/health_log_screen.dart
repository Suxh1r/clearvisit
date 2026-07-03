import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class HealthLogScreen extends StatelessWidget {
  const HealthLogScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (context, _) => Column(children: [
          const ScreenIntro(
            title: 'Health log',
            body: 'Write down what happened and flag anything you want to mention at your next visit.',
          ),
          Expanded(
            child: state.healthLog.isEmpty
                ? const EmptyState(icon: Icons.edit_note, title: 'Your log is empty', body: 'Add a short note whenever something feels worth remembering.')
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: state.healthLog.map((value) => Card(child: ListTile(
                      minVerticalPadding: 14,
                      leading: Icon(value.flagged ? Icons.flag : Icons.notes, color: value.flagged ? Theme.of(context).colorScheme.error : null),
                      title: Text(value.text),
                      subtitle: Text(shortDate(value.occurredAt)),
                    ))).toList(),
                  ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(
            width: double.infinity, height: 52,
            child: FilledButton.icon(onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('Add log entry')),
          )),
        ]),
      );

  Future<void> _add(BuildContext context) async {
    final text = TextEditingController();
    var flagged = false;
    final saved = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('New log entry'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextEntry(controller: text, label: 'What do you want to remember?', lines: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: flagged,
            onChanged: (value) => setDialogState(() => flagged = value ?? false),
            title: const Text('Raise at my next visit'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    ));
    if (saved == true && text.text.trim().isNotEmpty) {
      await state.addLog(HealthLogEntry(id: newId(), occurredAt: DateTime.now(), text: text.text.trim(), flagged: flagged));
    }
  }
}

