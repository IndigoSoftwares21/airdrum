import 'package:flutter/material.dart';
import 'ad_text.dart';

class AdStatusChip extends StatelessWidget {
  final String label;
  final bool isConnected;
  final bool isTrailing;

  const AdStatusChip({
    super.key,
    required this.label,
    this.isConnected = false,
    this.isTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pure Material 3 InputChip styling
    final avatarWidget = isConnected
        ? const _PulseDot()
        : Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          );

    return InputChip(
      onPressed: () {}, // No-op, just to keep the M3 interactive styling
      avatar: isTrailing ? null : avatarWidget,
      deleteIcon: isTrailing ? avatarWidget : null,
      onDeleted: isTrailing ? () {} : null, // Required to show deleteIcon
      label: AdText.label(label),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.greenAccent.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.6),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
