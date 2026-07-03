import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => Column(
        children: [
          const ScreenIntro(
            title: 'Prepare for a visit',
            body: 'Keep the important details together so they are easier to remember.',
          ),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.appointments.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_available,
                        title: 'No visits yet',
                        body: 'Add an upcoming appointment and the questions you want to ask.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.appointments.length,
                        itemBuilder: (context, index) {
                          final value = state.appointments[index];
                          return Card(
                            child: ListTile(
                              minVerticalPadding: 16,
                              title: Text(value.reason),
                              subtitle: Text('${shortDate(value.date)}${value.provider.isEmpty ? '' : ' • ${value.provider}'}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showSummary(context, value),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add),
                label: const Text('Add appointment'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final reason = TextEditingController();
    final provider = TextEditingController();
    final documents = TextEditingController();
    final symptoms = TextEditingController();
    final questions = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New appointment'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextEntry(controller: reason, label: 'Reason for visit'),
                TextEntry(controller: provider, label: 'Provider or clinic'),
                TextEntry(controller: documents, label: 'Documents to bring', lines: 2),
                TextEntry(controller: symptoms, label: 'Symptoms or concerns', lines: 3),
                TextEntry(controller: questions, label: 'Questions to ask', lines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true && reason.text.trim().isNotEmpty) {
      await state.addAppointment(Appointment(
        id: newId(),
        date: DateTime.now(),
        reason: reason.text.trim(),
        provider: provider.text.trim(),
        documents: documents.text.trim(),
        symptoms: symptoms.text.trim(),
        questions: questions.text.trim(),
      ));
    }
  }

  void _showSummary(BuildContext context, Appointment value) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(value.reason, style: Theme.of(context).textTheme.headlineSmall),
          Text('${shortDate(value.date)} • ${value.provider}'),
          const Divider(height: 32),
          _section('Bring', value.documents),
          _section('Mention', value.symptoms),
          _section('Ask', value.questions),
        ],
      ),
    );
  }

  Widget _section(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Nothing added' : value),
        ]),
      );
}

