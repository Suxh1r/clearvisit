import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/entry_fields.dart';

const Map<String, List<String>> _measurementUnits = {
  'Blood sugar': ['mg/dL', 'mmol/L'],
  'Blood pressure': ['mmHg'],
  'Weight': ['lb', 'kg'],
  'Temperature': ['°F', '°C'],
  'Heart rate': ['bpm'],
  'Oxygen saturation': ['%'],
};

const List<String> _measurementContexts = [
  'Before breakfast',
  'After breakfast',
  'Before lunch',
  'After lunch',
  'Before dinner',
  'After dinner',
  'Bedtime',
  'After exercise',
  'When symptoms happened',
];

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => Column(
      children: [
        const ScreenIntro(
          title: 'Measurements',
          body:
              'Record values without interpretation. Ask a healthcare professional what your values mean.',
        ),
        Expanded(
          child: state.measurements.isEmpty
              ? const EmptyState(
                  icon: Icons.monitor_heart_outlined,
                  title: 'No measurements yet',
                  body:
                      'You can manually record blood sugar, blood pressure, weight, or another value.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  children: state.measurements
                      .map(
                        (value) => SummaryCard(
                          icon: Icons.monitor_heart_outlined,
                          title: value.type,
                          subtitle:
                              '${weekdayName(value.measuredAt)}, ${shortDate(value.measuredAt)}${value.context.isEmpty ? '' : ' • ${value.context}'}',
                          trailing: Text(
                            '${value.value} ${value.unit}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
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
              label: const Text('Add measurement'),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _add(BuildContext context) async {
    final type = TextEditingController();
    final value = TextEditingController();
    final unit = TextEditingController();
    final measurementContext = TextEditingController();
    var measuredAt = DateTime.now();
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            final units =
                _measurementUnits[type.text] ??
                const ['mg/dL', 'mmHg', 'lb', 'kg', 'bpm', '%'];
            return AlertDialog(
              title: const Text('Add measurement'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DateDropdownEntry(
                      value: measuredAt,
                      label: 'Measurement date',
                      yearCount: 3,
                      onChanged: (date) =>
                          setDialogState(() => measuredAt = date),
                    ),
                    DropdownEntry(
                      controller: type,
                      label: 'Type',
                      options: _measurementUnits.keys.toList(),
                      otherHint: 'Enter measurement type',
                      onChanged: (_) => setDialogState(() => unit.clear()),
                    ),
                    TextEntry(
                      controller: value,
                      label: 'Value',
                      keyboardType: TextInputType.number,
                    ),
                    DropdownEntry(
                      controller: unit,
                      label: 'Unit',
                      options: units,
                    ),
                    DropdownEntry(
                      controller: measurementContext,
                      label: 'Context',
                      options: _measurementContexts,
                      otherHint: 'Enter context',
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
            );
          },
        ),
      );
      if (saved == true &&
          type.text.trim().isNotEmpty &&
          value.text.trim().isNotEmpty) {
        await state.addMeasurement(
          Measurement(
            id: newId(),
            measuredAt: measuredAt,
            type: type.text.trim(),
            value: value.text.trim(),
            unit: unit.text.trim(),
            context: measurementContext.text.trim(),
          ),
        );
      }
    } finally {
      type.dispose();
      value.dispose();
      unit.dispose();
      measurementContext.dispose();
    }
  }
}
