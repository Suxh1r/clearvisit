import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.zero,
    children: [
      const ScreenIntro(
        title: 'Privacy and settings',
        body:
            'ClearVisit stores your entries in an encrypted database on this device.',
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const SummaryCard(
              icon: Icons.cloud_off,
              title: 'No cloud sync',
              subtitle:
                  'This version does not send your health entries to ClearVisit or GCP.',
            ),
            const SummaryCard(
              icon: Icons.medical_information_outlined,
              title: 'Personal organizer only',
              subtitle:
                  'ClearVisit does not provide medical advice, diagnosis, monitoring, or treatment.',
            ),
            const SummaryCard(
              icon: Icons.backup_outlined,
              title: 'Encrypted backup',
              subtitle:
                  'Planned: user-controlled encrypted export and restore.',
            ),
            SummaryCard(
              icon: Icons.delete_forever,
              title: 'Delete everything',
              subtitle:
                  'Permanently removes all ClearVisit records from this device.',
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () => _confirmDelete(context),
            ),
            const SizedBox(height: 8),
            Text(
              'If you may be having a medical emergency, contact local emergency services. Do not rely on ClearVisit.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This cannot be undone unless you previously created a backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) await state.deleteEverything();
  }
}
