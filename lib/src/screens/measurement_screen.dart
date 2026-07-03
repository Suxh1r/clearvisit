import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (context, _) => Column(children: [
          const ScreenIntro(
            title: 'Measurements',
            body: 'Record values without interpretation. Ask a healthcare professional what your values mean.',
          ),
          Expanded(
            child: state.measurements.isEmpty
                ? const EmptyState(icon: Icons.monitor_heart_outlined, title: 'No measurements yet', body: 'You can manually record blood sugar, blood pressure, weight, or another value.')
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: state.measurements.map((value) => Card(child: ListTile(
                      minVerticalPadding: 14,
                      title: Text(value.type),
                      subtitle: Text('${shortDate(value.measuredAt)}${value.context.isEmpty ? '' : ' • ${value.context}'}'),
                      trailing: Text('${value.value} ${value.unit}', style: Theme.of(context).textTheme.titleMedium),
                    ))).toList(),
                  ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(
            width: double.infinity, height: 52,
            child: FilledButton.icon(onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('Add measurement')),
          )),
        ]),
      );

  Future<void> _add(BuildContext context) async {
    final type = TextEditingController();
    final value = TextEditingController();
    final unit = TextEditingController();
    final measurementContext = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Add measurement'),
      content: SingleChildScrollView(child: Column(children: [
        TextEntry(controller: type, label: 'Type (for example, blood sugar)'),
        TextEntry(controller: value, label: 'Value'),
        TextEntry(controller: unit, label: 'Unit'),
        TextEntry(controller: measurementContext, label: 'Context (optional)'),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
      ],
    ));
    if (saved == true && type.text.trim().isNotEmpty && value.text.trim().isNotEmpty) {
      await state.addMeasurement(Measurement(
        id: newId(), measuredAt: DateTime.now(), type: type.text.trim(), value: value.text.trim(),
        unit: unit.text.trim(), context: measurementContext.text.trim(),
      ));
    }
  }
}

