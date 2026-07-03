import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (context, _) => Column(children: [
          const ScreenIntro(
            title: 'Medication list',
            body: 'Record exactly what the label says. ClearVisit does not check medications or doses.',
          ),
          Expanded(
            child: state.medications.isEmpty
                ? const EmptyState(icon: Icons.medication, title: 'No medications yet', body: 'Add each medication from its label.')
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: state.medications.map((value) => Card(
                      child: ListTile(
                        minVerticalPadding: 14,
                        leading: const CircleAvatar(child: Icon(Icons.medication_outlined)),
                        title: Text('${value.name}${value.strength.isEmpty ? '' : ' ${value.strength}'}'),
                        subtitle: Text([value.dose, value.schedule].where((part) => part.isNotEmpty).join(' • ')),
                      ),
                    )).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(
              onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('Add medication'),
            )),
          ),
        ]),
      );

  Future<void> _add(BuildContext context) async {
    final name = TextEditingController();
    final strength = TextEditingController();
    final dose = TextEditingController();
    final schedule = TextEditingController();
    final notes = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Add medication'),
      content: SingleChildScrollView(child: Column(children: [
        TextEntry(controller: name, label: 'Medication name'),
        TextEntry(controller: strength, label: 'Strength (for example, 10 mg)'),
        TextEntry(controller: dose, label: 'Dose (for example, 1 tablet)'),
        TextEntry(controller: schedule, label: 'When you take it'),
        TextEntry(controller: notes, label: 'Notes', lines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
      ],
    ));
    if (saved == true && name.text.trim().isNotEmpty) {
      await state.addMedication(Medication(
        id: newId(), name: name.text.trim(), strength: strength.text.trim(), dose: dose.text.trim(),
        schedule: schedule.text.trim(), notes: notes.text.trim(),
      ));
    }
  }
}

