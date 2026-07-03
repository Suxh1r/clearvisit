import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const ScreenIntro(
            title: 'Privacy and settings',
            body: 'ClearVisit stores your entries in an encrypted database on this device.',
          ),
          const ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('No cloud sync'),
            subtitle: Text('This version does not send your health entries to ClearVisit or GCP.'),
          ),
          const ListTile(
            leading: Icon(Icons.medical_information_outlined),
            title: Text('Personal organizer only'),
            subtitle: Text('ClearVisit does not provide medical advice, diagnosis, monitoring, or treatment.'),
          ),
          const ListTile(
            leading: Icon(Icons.backup_outlined),
            title: Text('Encrypted backup'),
            subtitle: Text('Planned: user-controlled encrypted export and restore.'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: const Text('Delete everything'),
            subtitle: const Text('Permanently removes all ClearVisit records from this device.'),
            onTap: () => _confirmDelete(context),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('If you may be having a medical emergency, contact local emergency services. Do not rely on ClearVisit.'),
          ),
        ],
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete all data?'),
      content: const Text('This cannot be undone unless you previously created a backup.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete everything'),
        ),
      ],
    ));
    if (confirmed == true) await state.deleteEverything();
  }
}

