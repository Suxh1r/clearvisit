import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Text field with type-ahead suggestions. Suggestions come from
/// [optionsBuilder]; the user can always keep typing a custom value.
class AutocompleteEntry extends StatefulWidget {
  const AutocompleteEntry({
    required this.controller,
    required this.label,
    required this.optionsBuilder,
    this.onChanged,
    this.onSelected,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final List<String> Function(String query) optionsBuilder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSelected;

  @override
  State<AutocompleteEntry> createState() => _AutocompleteEntryState();
}

class _AutocompleteEntryState extends State<AutocompleteEntry> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LayoutBuilder(
          builder: (context, constraints) => RawAutocomplete<String>(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            optionsBuilder: (value) => widget.optionsBuilder(value.text),
            onSelected: widget.onSelected,
            fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
                TextField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: widget.label),
              onChanged: widget.onChanged,
              onSubmitted: (_) => onSubmit(),
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 220,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Dropdown for picking how far in advance a reminder should fire.
/// Value is minutes before the event; -1 means no reminder.
class ReminderDropdown extends StatelessWidget {
  const ReminderDropdown({
    required this.value,
    required this.onChanged,
    required this.choices,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  /// Map of minutes → label, e.g. {5: '5 minutes before'}.
  final Map<int, String> choices;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Remind me'),
          items: choices.entries
              .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (selected) => onChanged(selected ?? -1),
        ),
      );
}

/// Dropdown of preset options plus an "Other" choice that reveals a text
/// field for manual entry. The final value is written to [controller].
class DropdownEntry extends StatefulWidget {
  const DropdownEntry({
    required this.controller,
    required this.label,
    required this.options,
    this.otherHint,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final List<String> options;
  final String? otherHint;

  /// Called with the new value when a preset is picked, or '' for "Other".
  final ValueChanged<String>? onChanged;

  @override
  State<DropdownEntry> createState() => _DropdownEntryState();
}

class _DropdownEntryState extends State<DropdownEntry> {
  static const String _other = '__other__';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _syncFromController();
  }

  void _syncFromController() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      _selected = null;
    } else {
      _selected = widget.options.contains(text) ? text : _other;
    }
  }

  @override
  void didUpdateWidget(DropdownEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.options, widget.options)) {
      // Options changed (for example, a different medication was picked).
      // Keep "Other" selections; reset a preset that no longer exists.
      if (_selected != null &&
          _selected != _other &&
          !widget.options.contains(_selected)) {
        _selected = null;
        widget.controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No preset options: fall back to a plain text field.
    if (widget.options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: widget.label),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            // Recreate the field when the option list changes so the
            // displayed selection stays in sync.
            key: ValueKey(Object.hashAll(widget.options)),
            initialValue: _selected,
            isExpanded: true,
            decoration: InputDecoration(labelText: widget.label),
            items: [
              ...widget.options.map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              ),
              const DropdownMenuItem(
                value: _other,
                child: Text('Other (enter manually)'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selected = value;
                widget.controller.text = (value == null || value == _other) ? '' : value;
              });
              widget.onChanged?.call(widget.controller.text);
            },
          ),
          if (_selected == _other)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: widget.controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: widget.otherHint ?? 'Enter ${widget.label.toLowerCase()}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
