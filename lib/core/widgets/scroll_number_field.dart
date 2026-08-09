import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Scrollable numeric picker with + / − controls for questionnaire fields.
class ScrollNumberField extends StatefulWidget {
  const ScrollNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.suffix,
    this.decimals = 0,
    this.validator,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String? suffix;
  final int decimals;
  final ValueChanged<double> onChanged;
  final String? Function(double value)? validator;

  @override
  State<ScrollNumberField> createState() => _ScrollNumberFieldState();
}

class _ScrollNumberFieldState extends State<ScrollNumberField> {
  static const double _itemExtent = 40;
  late FixedExtentScrollController _controller;
  late List<double> _values;
  String? _error;

  @override
  void initState() {
    super.initState();
    _values = _buildValues();
    _controller = FixedExtentScrollController(initialItem: _indexFor(widget.value));
  }

  @override
  void didUpdateWidget(covariant ScrollNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min ||
        oldWidget.max != widget.max ||
        oldWidget.step != widget.step) {
      _values = _buildValues();
    }
    final nextIndex = _indexFor(widget.value);
    if (_controller.hasClients && _controller.selectedItem != nextIndex) {
      _controller.jumpToItem(nextIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _buildValues() {
    final values = <double>[];
    for (var v = widget.min; v <= widget.max + 1e-9; v += widget.step) {
      values.add(double.parse(v.toStringAsFixed(widget.decimals)));
    }
    return values;
  }

  int _indexFor(double value) {
    final clamped = value.clamp(widget.min, widget.max);
    var best = 0;
    var bestDelta = double.infinity;
    for (var i = 0; i < _values.length; i++) {
      final delta = (_values[i] - clamped).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = i;
      }
    }
    return best;
  }

  String _format(double value) {
    if (widget.decimals <= 0) return value.round().toString();
    return value.toStringAsFixed(widget.decimals);
  }

  void _setIndex(int index, {bool notify = true}) {
    final next = _values[index.clamp(0, _values.length - 1)];
    _error = widget.validator?.call(next);
    if (notify) widget.onChanged(next);
    setState(() {});
  }

  void _nudge(int delta) {
    if (!_controller.hasClients) return;
    final next = (_controller.selectedItem + delta).clamp(0, _values.length - 1);
    _controller.animateToItem(
      next,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDecrease = _indexFor(widget.value) > 0;
    final canIncrease = _indexFor(widget.value) < _values.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _error != null ? AppTheme.riskHigh : const Color(0xFFDFE7E3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: canDecrease,
                onPressed: () => _nudge(-1),
              ),
              Expanded(
                child: SizedBox(
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: _itemExtent,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      ListWheelScrollView.useDelegate(
                        controller: _controller,
                        itemExtent: _itemExtent,
                        physics: const FixedExtentScrollPhysics(),
                        diameterRatio: 1.35,
                        perspective: 0.003,
                        onSelectedItemChanged: (index) => _setIndex(index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _values.length,
                          builder: (context, index) {
                            final selected = _indexFor(widget.value) == index;
                            final text = _format(_values[index]);
                            final label = widget.suffix == null ? text : '$text ${widget.suffix}';
                            return Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: selected ? 22 : 16,
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                                  color: selected ? AppTheme.primaryDark : AppTheme.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                enabled: canIncrease,
                onPressed: () => _nudge(1),
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(_error!, style: const TextStyle(color: AppTheme.riskHigh, fontSize: 13)),
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: enabled ? AppTheme.softGreen : const Color(0xFFF3F5F4),
          foregroundColor: enabled ? AppTheme.primaryDark : AppTheme.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, size: 22),
      ),
    );
  }
}
