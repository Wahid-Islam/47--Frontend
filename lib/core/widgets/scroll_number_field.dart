import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

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
    this.hint,
    this.decimals = 0,
    this.validator,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String? suffix;
  final String? hint;
  final int decimals;
  final ValueChanged<double> onChanged;
  final String? Function(double value)? validator;

  @override
  State<ScrollNumberField> createState() => _ScrollNumberFieldState();
}

class _ScrollNumberFieldState extends State<ScrollNumberField> {
  static const double _chipWidth = 64;
  late final ScrollController _scrollController;
  late List<double> _values;
  String? _error;

  @override
  void initState() {
    super.initState();
    _values = _buildValues();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(jump: true));
  }

  @override
  void didUpdateWidget(covariant ScrollNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min ||
        oldWidget.max != widget.max ||
        oldWidget.step != widget.step) {
      _values = _buildValues();
    }
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void _scrollToSelected({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final index = _indexFor(widget.value);
    final viewport = _scrollController.position.viewportDimension;
    final target = (index * _chipWidth) - (viewport - _chipWidth) / 2;
    final offset = target.clamp(0.0, _scrollController.position.maxScrollExtent);
    if (jump) {
      _scrollController.jumpTo(offset);
    } else {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  void _setValue(double next) {
    final clamped = next.clamp(widget.min, widget.max);
    final snapped = _values[_indexFor(clamped)];
    _error = widget.validator?.call(snapped);
    widget.onChanged(snapped);
    setState(() {});
  }

  void _nudge(int delta) {
    final index = (_indexFor(widget.value) + delta).clamp(0, _values.length - 1);
    HapticFeedback.selectionClick();
    _setValue(_values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _indexFor(widget.value);
    final canDecrease = selectedIndex > 0;
    final canIncrease = selectedIndex < _values.length - 1;
    final display = widget.suffix == null
        ? _format(widget.value)
        : '${_format(widget.value)} ${widget.suffix}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _error != null ? AppTheme.riskHigh : const Color(0xFFDFE7E3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    enabled: canDecrease,
                    onPressed: () => _nudge(-1),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          display,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.hint != null)
                          Text(
                            widget.hint!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    enabled: canIncrease,
                    onPressed: () => _nudge(1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _values.length,
                  itemExtent: _chipWidth,
                  itemBuilder: (context, index) {
                    final selected = index == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: selected ? AppTheme.softGreen : const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _setValue(_values[index]),
                          child: Center(
                            child: Text(
                              _format(_values[index]),
                              style: TextStyle(
                                fontSize: selected ? 16 : 13,
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? AppTheme.primaryDark : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
        icon: Icon(icon, size: 24),
      ),
    );
  }
}
