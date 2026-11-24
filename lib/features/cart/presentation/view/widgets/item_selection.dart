part of '../view.dart';

class _ItemSelection {
  final _items = <String, ValueNotifier<bool>>{};
  final hasSelection = ValueNotifier(false);

  Set<String> get selectedIds => Set.unmodifiable(_items.entries.where((entry) => entry.value.value).map((entry) => entry.key));

  Widget checkboxFor(String id) {
    final selected = _items.putIfAbsent(id, () => ValueNotifier(false));
    return ValueListenableBuilder<bool>(
      valueListenable: selected,
      builder: (context, value, _) => Checkbox(
        value: value,
        onChanged: (checked) {
          selected.value = checked ?? false;
          _updateHasSelection();
        },
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void retainItems(List<CartItem> items) {
    final ids = items.map((item) => item.product.id).toSet();
    _items.removeWhere((id, notifier) {
      if (ids.contains(id)) return false;
      notifier.dispose();
      return true;
    });
    _updateHasSelection();
  }

  void clear() {
    for (final selected in _items.values) {
      selected.value = false;
    }
    hasSelection.value = false;
  }

  void _updateHasSelection() {
    hasSelection.value = _items.values.any((selected) => selected.value);
  }

  void dispose() {
    for (final selected in _items.values) {
      selected.dispose();
    }
    hasSelection.dispose();
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({required this.countLabel, required this.selection, required this.onPressed, required this.icon, required this.actionLabel});

  final String countLabel;
  final _ItemSelection selection;
  final VoidCallback onPressed;
  final IconData icon;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(countLabel, style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.65))),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: selection.hasSelection,
          builder: (context, enabled, _) => FilledButton.tonalIcon(onPressed: enabled ? onPressed : null, icon: Icon(icon), label: Text(actionLabel)),
        ),
      ],
    );
  }
}
