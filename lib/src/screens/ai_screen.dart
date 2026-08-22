import 'package:flutter/material.dart';

import '../ai/ai_assistant_service.dart';
import '../app_state.dart';
import '../widgets/common.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({required this.state, super.key});

  final AppState state;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiAssistantService _assistant = const AiAssistantService();
  final TextEditingController _explainController = TextEditingController();
  final TextEditingController _draftController = TextEditingController();
  AiExplanation? _explanation;
  List<AiDraft> _drafts = const [];
  bool _explaining = false;
  bool _drafting = false;

  @override
  void dispose() {
    _explainController.dispose();
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const ScreenIntro(
        title: 'AI helper',
        body:
            'Explain confusing text and turn notes into reviewable ClearVisit entries. Nothing is sent to a cloud AI in this local preview.',
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            _SafetyCard(),
            _ExplainCard(
              controller: _explainController,
              explanation: _explanation,
              loading: _explaining,
              onExplain: _explain,
            ),
            _DraftCard(
              controller: _draftController,
              drafts: _drafts,
              loading: _drafting,
              onDraft: _draftEntries,
              onSaveDraft: _saveDraft,
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _explain() async {
    if (_explainController.text.trim().isEmpty) return;
    setState(() => _explaining = true);
    try {
      final result = await _assistant.explain(_explainController.text);
      if (!mounted) return;
      setState(() => _explanation = result);
      await _showExplanationDialog(result);
    } catch (_) {
      if (!mounted) return;
      _showError('Could not explain that text. Please try again.');
    } finally {
      if (mounted) setState(() => _explaining = false);
    }
  }

  Future<void> _draftEntries() async {
    if (_draftController.text.trim().isEmpty) return;
    setState(() => _drafting = true);
    try {
      final result = await _assistant.createDrafts(_draftController.text);
      if (!mounted) return;
      setState(() => _drafts = result);
      await _showDraftsDialog(result);
    } catch (_) {
      if (!mounted) return;
      _showError('Could not create drafts from that text. Please try again.');
    } finally {
      if (mounted) setState(() => _drafting = false);
    }
  }

  Future<bool> _saveDraft(AiDraft draft) async {
    try {
      switch (draft.type) {
        case AiDraftType.appointment:
          final value = draft.appointment;
          if (value != null) await widget.state.addAppointment(value);
          break;
        case AiDraftType.medication:
          final value = draft.medication;
          if (value != null) await widget.state.addMedication(value);
          break;
        case AiDraftType.healthLog:
          final value = draft.healthLogEntry;
          if (value != null) await widget.state.addLog(value);
          break;
        case AiDraftType.measurement:
          final value = draft.measurement;
          if (value != null) await widget.state.addMeasurement(value);
          break;
      }
    } catch (_) {
      if (!mounted) return false;
      _showError('Could not save that draft. Please try again.');
      return false;
    }
    if (!mounted) return true;
    setState(() => _drafts = _drafts.where((item) => item != draft).toList());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added ${draft.title}')));
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showExplanationDialog(AiExplanation explanation) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome),
        title: const Text('AI explanation ready'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultSection(
                title: 'Plain-language summary',
                values: [explanation.summary],
              ),
              _ResultSection(
                title: 'Important details',
                values: explanation.importantDetails,
              ),
              _ResultSection(
                title: 'Questions to ask',
                values: explanation.questionsToAsk,
              ),
              _ResultSection(
                title: 'Safety notes',
                values: explanation.cautions,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDraftsDialog(List<AiDraft> drafts) {
    final visibleDrafts = [...drafts];
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: const Icon(Icons.playlist_add_check_circle_outlined),
          title: const Text('AI drafts ready'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    visibleDrafts.isEmpty
                        ? 'All suggested entries have been added.'
                        : 'Review each suggestion before adding it to ClearVisit.',
                  ),
                  const SizedBox(height: 16),
                  for (final draft in visibleDrafts)
                    _DraftTile(
                      draft: draft,
                      onSave: () async {
                        final saved = await _saveDraft(draft);
                        if (context.mounted) {
                          if (saved) {
                            setDialogState(() => visibleDrafts.remove(draft));
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SummaryCard(
    icon: Icons.privacy_tip_outlined,
    title: 'Review before saving',
    subtitle:
        'AI suggestions are drafts. ClearVisit does not diagnose, treat, check medication safety, or replace professional advice.',
  );
}

class _ExplainCard extends StatelessWidget {
  const _ExplainCard({
    required this.controller,
    required this.explanation,
    required this.loading,
    required this.onExplain,
  });

  final TextEditingController controller;
  final AiExplanation? explanation;
  final bool loading;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) => _Panel(
    icon: Icons.article_outlined,
    title: 'Explain pasted text',
    subtitle:
        'For letters, insurance notices, appointment instructions, or billing text.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 9,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Paste confusing text',
            hintText: 'Paste the paragraph or notice you want explained.',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: loading ? null : onExplain,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(loading ? 'Explaining...' : 'Explain'),
          ),
        ),
        if (explanation != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: loading
                  ? null
                  : () => _showExplanationFromCard(context, explanation!),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View last explanation'),
            ),
          ),
      ],
    ),
  );

  Future<void> _showExplanationFromCard(
    BuildContext context,
    AiExplanation explanation,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome),
        title: const Text('AI explanation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultSection(
                title: 'Plain-language summary',
                values: [explanation.summary],
              ),
              _ResultSection(
                title: 'Important details',
                values: explanation.importantDetails,
              ),
              _ResultSection(
                title: 'Questions to ask',
                values: explanation.questionsToAsk,
              ),
              _ResultSection(
                title: 'Safety notes',
                values: explanation.cautions,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.controller,
    required this.drafts,
    required this.loading,
    required this.onDraft,
    required this.onSaveDraft,
  });

  final TextEditingController controller;
  final List<AiDraft> drafts;
  final bool loading;
  final VoidCallback onDraft;
  final Future<bool> Function(AiDraft draft) onSaveDraft;

  @override
  Widget build(BuildContext context) => _Panel(
    icon: Icons.playlist_add_check_circle_outlined,
    title: 'Create entries from text',
    subtitle:
        'Paste a note like “appointment 9/12 at 2 PM” or “blood sugar 120 mg/dL before breakfast.”',
    child: Column(
      children: [
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Paste or type details',
            hintText:
                'Example: Follow-up visit 9/12 at 2 PM, remind me 1 day before.',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: loading ? null : onDraft,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(loading ? 'Creating drafts...' : 'Create drafts'),
          ),
        ),
        if (drafts.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => _showDraftsFromCard(context, drafts, onSaveDraft),
            icon: const Icon(Icons.open_in_new),
            label: Text(
              'View ${drafts.length} draft${drafts.length == 1 ? '' : 's'}',
            ),
          ),
        ],
      ],
    ),
  );

  Future<void> _showDraftsFromCard(
    BuildContext context,
    List<AiDraft> drafts,
    Future<bool> Function(AiDraft draft) onSaveDraft,
  ) {
    final visibleDrafts = [...drafts];
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: const Icon(Icons.playlist_add_check_circle_outlined),
          title: const Text('AI drafts'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    visibleDrafts.isEmpty
                        ? 'All suggested entries have been added.'
                        : 'Review each suggestion before adding it to ClearVisit.',
                  ),
                  const SizedBox(height: 16),
                  for (final draft in visibleDrafts)
                    _DraftTile(
                      draft: draft,
                      onSave: () async {
                        final saved = await onSaveDraft(draft);
                        if (context.mounted && saved) {
                          setDialogState(() => visibleDrafts.remove(draft));
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(icon, color: colors.onPrimaryContainer),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $value'),
          ),
      ],
    ),
  );
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.draft, required this.onSave});

  final AiDraft draft;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final icon = switch (draft.type) {
      AiDraftType.appointment => Icons.event_note_outlined,
      AiDraftType.medication => Icons.medication_outlined,
      AiDraftType.healthLog => Icons.notes_outlined,
      AiDraftType.measurement => Icons.monitor_heart_outlined,
    };
    final label = switch (draft.type) {
      AiDraftType.appointment => 'Visit',
      AiDraftType.medication => 'Medication',
      AiDraftType.healthLog => 'Log',
      AiDraftType.measurement => 'Measurement',
    };
    return SummaryCard(
      icon: icon,
      title: '$label: ${draft.title}',
      subtitle: '${draft.subtitle}\nWhy: ${draft.reason}',
      trailing: FilledButton(onPressed: onSave, child: const Text('Add')),
    );
  }
}
