import 'package:flutter/material.dart';
import 'ad_text.dart';

class AdStatusChip extends StatelessWidget {
  final String label;
  final bool isConnected;

  const AdStatusChip({
    super.key,
    required this.label,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pure Material 3 InputChip styling
    return InputChip(
      onPressed: () {}, // No-op, just to keep the M3 interactive styling
      avatar: Icon(
        isConnected ? Icons.check_circle : Icons.error_outline,
        color: isConnected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      label: AdText.label(label),
    );
  }
}
